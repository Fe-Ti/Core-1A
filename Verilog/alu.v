// Copyright 2024-2026 Fe-Ti aka Tim Kravchenko
//
// Main CPU module
// Version:  1
// Codename: Shikra (lat: Tachyspiza badia)
`default_nettype none


`include "constants.v"
`include "lib-kuznk/libtop.v"
`include "lib-magma/libtop.v"


module alu(
    input wire [`XLEN:1] arg1, arg2,
    input wire [`CONTROL_BUS_WIDTH:1] control_bus,
    output wire [`XLEN:1] result
);
    // ALU operation selector
    // Consider func7[:] == 0, except for specified modifiers from
    // func3 for I extension and Zbkb:
    // 0x0 --- ADD/SUB (func7[5] modifies to SUB when is_type_R)
    // 0x1 --- SLL                  (ROL(W) if func7[5] and func7[4])
    // 0x2 --- SLT (set less than)
    // 0x3 --- SLTU (set less than, as unsigned)
    // 0x4 --- XOR                  (XNOR if func7[5]), (PACK if func7[2] or PACKW if 32-bit op)
    // 0x5 --- SRL/SRA if func7[5]  (ROR(W) if func7[5] and func7[4]) (REV8 and BREV8 see below)
    // 0x6 --- OR                   (ORN if func7[5])
    // 0x7 --- AND                  (ANDN if func7[5]) (PACKH if func7[2])
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
    //  kuznksboxfwd Преобразование \(S_{XLEN}\)         (rs1)         +     +  (I) imm=0x0 func3=0x2
    //  kuznksboxinv Преобразование \(S_{XLEN}^{-1}\)    (rs1)         +     +  (I) imm=0x0 func3=0x3
    //  kuznkdblsrl  Двойной сдвиг вправо на байт                      +     +      func3=0x4
    //  kuznkdblsll  Двойной сдвиг влево на байт                       +     +      func3=0x5
    //  >>> Zkmagma
    //  magma32edf   Преобразование \(g[k](a_0)\)                      +            func3=0x7
    //  magma64edrl  Преобразование \(G[k](a_1, a_0)\) (младший ключ)        +      func3=0x7
    //  magma64edrh  Преобразование \(G[k](a_1, a_0)\) (старший ключ)        +      func3=0x7 (func7[5])
    // two are of type I with ignored constant and the latter are R-type ones
    /// assign control_bus[`select_aluop_start+`select_aluop_bitcnt-1:`select_aluop_start] =
    /// {custom1, is_type_R, OP_32|OP_IMM_32, func7[5],func7[4],func7[2], func7[0], func3};

    /// Shitty multiplexing is going on :-D
    wire [`select_aluop_bitcnt:1] select_alu_op = 
        control_bus[`select_aluop_start+`select_aluop_bitcnt-1:`select_aluop_start];

    wire is_custom1 = select_alu_op[`select_aluop_bitcnt];
    wire is_type_R  = select_alu_op[7];
    wire is_32_bit  = select_alu_op[6];

    wire func3 = select_alu_op[3:1];

    wire func7_5 = select_alu_op[5];
    wire func7_4 = select_alu_op[4];
    wire func7_2 = select_alu_op[3];
    wire func7_0 = select_alu_op[2];

    reg [`XLEN:1] op_result;
    assign result = op_result;

    // ALU operation selector
    // Consider func7[:] == 0, except for specified modifiers from
    // func3 for I extension and Zbkb:
    // 0x0 --- ADD, SUB (R_type & func7[5]), 
    // 0x1 --- SLL, ROL(W) if func7[5] and func7[4], 
    // 0x2 --- SLT,
    // 0x3 --- SLTU,
    // 0x4 --- XOR, XNOR (func7[5]), PACK(W) (func7[2]),
    // 0x5 --- SRL, SRA (func7[5]),  ROR(W) (func7[5, 4]), BREV8 (func7[5,4,2,0]), REV8 (func7[5,4,2,0])
    // 0x6 --- OR,  ORN (func7[5])
    // 0x7 --- AND  ANDN (func7[5]), PACKH (func7[2])
    // Plus 64-bit addon with same func3, but modifier for 32-bit ops.
    //
    // func3 for Zkkuznk and Zkmagma:
    // 0x0 --- kuznk32ellh, kuznk32elll (func7[5]) || kuznk64rfwd
    // 0x1 --- kuznk32bssr, kuznk32bssl (func7[5]) || kuznk64rinv
    // 0x2 --- kuznksboxfwd
    // 0x3 --- kuznksboxinv
    // 0x4 --- kuznkdblsrl
    // 0x5 --- kuznkdblsll
    // 0x6 --- >> no
    // 0x7 --- magma32edf || magma64edrl, magma64edrh (func7[5])
    //
    // Currently forgetting about kuznk32 and magma32
    //TODO: Implement switch to get XLEN=32

    /// Just XD how stupid is this thing, VKR they said :-D
    wire [`XLEN:1] add_sub64 = arg1 + (is_sub? ~arg2: arg2) + is_sub;
    wire [32:1] add_sub32 = arg1[32:1] + (is_sub? ~arg2[32:1]: arg2[32:1]) + is_sub;
    wire [`XLEN:1] add_sub = is_32_bit? add_sub32 : add_sub64;

    wire [128:1] r_fwd_result;
    wire [128:1] r_inv_result;
    wire [`XLEN:1] sbox_fwd_result;
    wire [`XLEN:1] sbox_inv_result;

    // Those are for 64 bit system
    sbox64 sboxfwd (
        .data_block_in (arg1),
        .data_block_out (sbox_fwd_result)
    );
    sbox64_inverse sboxinv (
        .data_block_in (arg1),
        .data_block_out (sbox_inv_result)
    );

    forward_R r_fwd (
        .data_block_in ({arg2, arg1}),
        .data_block_out (r_fwd_result)
    );
    inverse_R r_inv (
        .data_block_in ({arg2, arg1}),
        .data_block_out (r_inv_result)
    );

    wire [`XLEN:1] r64_fwd = r_fwd_result[128:65];
    wire [`XLEN:1] r64_fwd_dblsrl = r_fwd_result[64:1];
    wire [`XLEN:1] r64_inv = r_inv_result[128:65];
    wire [`XLEN:1] r64_inv_dblsll = r_inv_result[64:1];;

    
    wire [`XLEN:1] magma_result;

    wire [32:1] magma_high_key = arg2[64:33];
    wire [32:1] magma_low_key = arg[32:1];

    wire [32:1] magma_key = func7_5 ? magma_high_key : magma_low_key;

    gk_magma64 Gk_magma (
        .data_block_in (arg1),
        .key_in (magma_key),
        .data_block_out (magma_result)
    );



    wire [`XLEN:1] add_sub_ell_rfwd         = is_custom1? ell_rfwd : add_sub;
    wire [`XLEN:1] sll_rol_bss_rinv         = is_custom1? bss_rinv : sll_rol;
    wire [`XLEN:1] slt_sboxfwd              = is_custom1? sboxfwd : slt;
    wire [`XLEN:1] sltu_sboxinv             = is_custom1? sboxinv : sltu;
    wire [`XLEN:1] xor_xnor_pack_dblsrl     = is_custom1? dblsrl : xor_xnor;
    wire [`XLEN:1] sr_ror_rev_dblsll        = is_custom1? dblsll : sr_ror_rev;
    wire [`XLEN:1] or_orn                   = func7_5 ? (arg1 | ~arg2) : (arg1 | arg2);
    wire [`XLEN:1] and_packh_edf_edrl_edrh  = is_custom1 ? edf_edrl_edrh : and_packh;

    always @* begin
        op_result = 0;
        case (func3)
            'd0 : op_result = add_sub_ell_rfwd;
            'd1 : op_result = sll_rol_bss_rinv;
            'd2 : op_result = slt_sboxfwd;
            'd3 : op_result = sltu_sboxinv;
            'd4 : op_result = xor_xnor_pack_dblsrl;
            'd5 : op_result = sr_ror_rev_dblsll;
            'd6 : op_result = or_orn;
            'd7 : op_result = and_packh_edf_edrl_edrh;
        endcase
    end

endmodule
