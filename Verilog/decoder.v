// Copyright 2024-2026 Fe-Ti aka Tim Kravchenko
//
// Main CPU module
// Version:  1
// Codename: Shikra (lat: Tachyspiza badia)

`include "constants.v"

module decoder(
    input wire [`XLEN:1] instruction,
    output wire [`REG_SELECT_WIDTH:1] rs1_addr, rs2_addr, rd_addr,
    output wire [`CONTROL_BUS_WIDTH:1] control_bus,
    output wire [`XLEN:1] imm
);
// Here is full opcode map (sorry for people without wide screens)
// opcode[4:2]
//  000      001      010       011      100      101   110             111 (>32)   // opcode[6:5]
reg LOAD,    LOAD_FP, custom0,  MISC_MEM,OP_IMM,  AUIPC,OP_IMM_32,      wide48b,    //00
    STORE,   STORE_FP,custom1,  AMO,     OP,      LUI,  OP_32,          wide64b,    //01
    MADD,    MSUB,    NMSUB,    NMADD,   OP_FP,   OP_V, custom2rv128,   //wide48b2,    //10
    BRANCH,  JALR,    reserved, JAL,     SYSTEM,  OP_VE,custom3rv128,   widemore80b;//11

    // Cutting instruction into parts
    wire [6:0] opcode, func7;
    wire [2:0] func3;
    wire [10:0] imm11IS;
    wire [31:0] imm20J, imm20U, imm20, imm12IS, imm12B, imm12, imm32;

    wire immsign;

    // Common assignments
    assign opcode[6:0] = instruction[7:1];
    assign func3[2:0] = instruction[15:13];
    assign func7[6:0] = instruction[32:26];

    wire is_type_R, is_type_I;
    assign is_type_R = OP | OP_32 | OP_FP;
    assign is_type_I = JALR | OP_IMM | LOAD | OP_IMM_32 | LOAD_FP;

    wire is_type_B, is_type_J, is_type_S, is_type_U;
    assign is_type_J = JAL;
    assign is_type_B = BRANCH;
    assign is_type_S = STORE | STORE_FP;
    assign is_type_U = LUI | AUIPC;
    // Getting constant
    assign immsign = instruction[32];
    assign imm20U = {instruction[32:13], 12'b0};
    assign imm20J = {{12{immsign}}, instruction[20:13], instruction[21], instruction[31:22], 1'b0};
    assign imm11IS = is_type_S ? {instruction[31:26], instruction[12:8]} : instruction[31:21];
    assign imm12IS = {{21{immsign}}, imm11IS};
    assign imm12B = {{20{immsign}}, instruction[8], instruction[31:26], instruction[12:9], 1'b0};

    assign imm12 = is_type_B ? imm12B : imm12IS;
    assign imm20 = is_type_J ? imm20J : imm20U;
    assign imm32 = (is_type_J | is_type_U) ? imm20 : imm12;
    assign imm = {{32{imm32[31]}}, imm32};


    // Opcode decoding procedure
    // Sets corresponding flags from the map
    always @(*) begin
        // Zero out mapping
        LOAD=0;    LOAD_FP=0; custom0=0;  MISC_MEM=0;OP_IMM=0;  AUIPC=0;OP_IMM_32=0;      wide48b=0;
        STORE=0;   STORE_FP=0;custom1=0;  AMO=0;     OP=0;      LUI=0;  OP_32=0;          wide64b=0;
        MADD=0;    MSUB=0;    NMSUB=0;    NMADD=0;   OP_FP=0;   OP_V=0; custom2rv128=0;  //wide48b=0;
        BRANCH=0;  JALR=0;    reserved=0; JAL=0;     SYSTEM=0;  OP_VE=0;custom3rv128=0;  widemore80b=0;
        // First decode 2 MSB and then decode the rest (3 opcode bits)
        // Compressed instructions are ignored in decoding scheme (external
        // decoder is required for them)
        case (opcode[6:5])
        2'b00 : case (opcode[4:2])
                0: LOAD     =1;
                1: LOAD_FP  =1;
                2: custom0  =1;
                3: MISC_MEM =1;
                4: OP_IMM   =1;
                5: AUIPC    =1;
                6: OP_IMM_32=1;
                7: wide48b  =1;
                endcase
        2'b01 : case (opcode[4:2])
                0: STORE    =1;
                1: STORE_FP =1;
                2: custom1  =1;
                3: AMO      =1;
                4: OP       =1;
                5: LUI      =1;
                6: OP_32    =1;
                7: wide64b  =1;
                endcase
        2'b10 : case (opcode[4:2])
                0: MADD     =1;
                1: MSUB     =1;
                2: NMSUB    =1;
                3: NMADD    =1;
                4: OP_FP    =1;
                5: OP_V     =1;
                6: custom2rv128=1;
                7: wide48b  =1;
                endcase
        2'b11 : case (opcode[4:2])
                0: BRANCH   =1;
                1: JALR     =1;
                2: reserved =1;
                3: JAL      =1;
                4: SYSTEM   =1;
                5: OP_VE    =1;
                6: custom3rv128=1;
                7: widemore80b=1;
                endcase
        endcase
    end
    /// End of procedural decoding block.
    /// Below should be placed assignments for control wires.

    // Control pins (for MUX-es)
    assign control_bus[`do_test_branch] = BRANCH;
    assign control_bus[`do_jump] = JAL | JALR;
    assign control_bus[`is_JALR] = JALR;

    assign control_bus[`select_arg1] = JAL | AUIPC | BRANCH;
    assign control_bus[`select_arg2] = ~is_type_R;
    //~ assign control_bus[`] = ;

    // Flag selector
    // func3 bits:
    // 2 1 0
    // | | |
    // | | +--> inverse ? yes : no
    // | +----> unsigned? yes : no
    // +------> cmp_fun ? lt  : eq
    assign control_bus[`select_flag_start+`select_flag_bitcnt-1:`select_flag_start] = func3;

    // ALU operation selector
    // Consider func7[:] == 0, except for specified modifiers from
    // func3 for I extension and Zbkb:
    // 0x0 --- ADD/SUB (func7[5] modifies to SUB when is_type_R)
    // 0x1 --- SLL                  (ROL* if func7[5] and func7[4])
    // 0x2 --- SLT (set less than)
    // 0x3 --- SLTU (set less than, as unsigned)
    // 0x4 --- XOR                  (XNOR if func7[5]), (PACK if func7[2] or PACKW if 32-bit op)
    // 0x5 --- SRL/SRA if func7[5]  (ROR* if func7[5] and func7[4]) (REV8 and BREV8 see below)
    // 0x6 --- OR                   (ORN if func7[5])
    // 0x7 --- AND                  (PACKH if func7[2])
    // Plus 64-bit addon with same func3, but modifier for 32-bit ops.
    // Plus brev8 and rev8 have special imm as follows (func7 = 011010x):
    //      brev8   --- 0110100 00111 (both) func3=0x5
    //      rev8    --- 0110100 11000 (rv32) or 0110101 11000 (rv64) func3=0x5
    // thus func7[0] can be used as indicator for rv64
    //
    // My additional commands are as follows (tables from Report):
    // opcode = custom1
    //  Мнемоника    Команда                                           RV32  RV64
    //  >>> Zkkuznk
    //  kuznk32ellh  Старшая часть суммы \(\ell(a)\)                   +            func3=0x0
    //  kuznk32elll  Младшая часть суммы \(\ell(a)\)                   +            func7[5]=1 func3=0x0
    //  kuznk32bssr  Сдвиг вправо c подстановкой старшего байта        +            func3=0x1
    //  kuznk32bssl  Сдвиг влево c подстановкой младшего байта         +            func7[5]=1 func3=0x1
    //  kuznk64rfwd  Преобразование \(R_{64}'(a)\)                           +      func3=0x0 
    //  kuznk64rinv  Преобразование \(R_{64}'^{-1}(a)\)                      +      func3=0x1
    //  kuznksboxfwd Преобразование \(S_{XLEN}\)                       +     +  (I) imm=0x0 func3=0x2
    //  kuznksboxinv Преобразование \(S_{XLEN}^{-1}\)                  +     +  (I) imm=0x0 func3=0x3
    //  kuznkdblsrl  Двойной сдвиг вправо на байт                      +     +      func3=0x4
    //  kuznkdblsll  Двойной сдвиг влево на байт                       +     +      func3=0x5
    //  >>> Zkmagma
    //  magma32edf   Преобразование \(g[k](a_0)\)                      +            func3=0x6
    //  magma64edrl  Преобразование \(G[k](a_1, a_0)\) (младший ключ)        +      func3=0x6
    //  magma64edrh  Преобразование \(G[k](a_1, a_0)\) (старший ключ)        +      func3=0x7
    // two are of type I with ignored constant and the latter are R-type ones
    assign control_bus[`select_aluop_start+`select_aluop_bitcnt-1:`select_aluop_start] =
        {custom1, is_type_R, OP_32|OP_IMM_32, func7[5],func7[4],func7[2], func7[0], func3};

    // We don't want to write anything into RD when branching or writing to mem
    assign control_bus[`regfile_we] = ~|{BRANCH, STORE, STORE_FP};

    // We need to supress rs1, rs2 and rd, when we don't want them to activate
    wire enable_rs1 = ~|{is_type_J, is_type_U}; // no RS1 when JAL and LUI/AUIPC
    wire enable_rs2 = ~|{is_type_I, is_type_J, is_type_U}; // same plus I-type
    wire enable_rd  = control_bus[`regfile_we];
    assign rs1_addr = instruction[20:16] & {`REG_SELECT_WIDTH{enable_rs1}};
    assign rs2_addr = instruction[25:21] & {`REG_SELECT_WIDTH{enable_rs2}};
    assign rd_addr  = instruction[12:8] & {`REG_SELECT_WIDTH{enable_rd}};

    // Memory operations
    assign control_bus[`mem_w] = STORE | STORE_FP;
    assign control_bus[`mem_r] = LOAD | LOAD_FP;
    // Mem size selector
    // func3 bits:
    // 2 1 0
    // | | |
    // | | +--+-> 2^x bytes to be stored or loaded from memory (1 to 8 bytes)
    // | +---/
    // +--------> unsigned? yes : no
    assign control_bus[`select_mem_size_start+`select_mem_size_bitcnt-1:`select_mem_size_start] = func3;

    // Cache syncing. Really simplified, i.e. ignoring rw/io parameters and fm field
    // Also func3 is different only in 1 bit, so using only it as an indicator.
    assign control_bus[`mem_sync_cache_data] = MISC_MEM & ~func3[0];
    // FENCE.I is from Zifencei, but let's say its just another base command :)
    assign control_bus[`mem_sync_cache_instruction] = MISC_MEM & func3[0];


    // Todo: system ops, these wires currently don't go anywhere
    wire sys_op = SYSTEM;
    wire priv_op = SYSTEM & ( (~|func3) | ~(~func3[0] | func3[1] | func3[2]) );

    // Todo: decoding atomic ops
    //~ assign amo_signaling_bus[`bit_amoop] = AMO;
    //~ assign amo_signaling_bus[`bit_amorl] = func7[`bit_amorl];
    //~ assign amo_signaling_bus[`bit_amoaq] = func7[`bit_amoaq];
endmodule

