// Copyright 2024-2025 Fe-Ti aka Tim Kravchenko
//
// Main CPU module
// Version:  1
// Codename: Shikra (lat: Tachyspiza badia)


`include "lib-kuznk/libtop.v"


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
    //  kuznksboxfwd Преобразование \(S_{XLEN}\)                       +     +  (I) imm=0x0 func3=0x2
    //  kuznksboxinv Преобразование \(S_{XLEN}^{-1}\)                  +     +  (I) imm=0x0 func3=0x3
    //  kuznkdblsrl  Двойной сдвиг вправо на байт                      +     +      func3=0x4
    //  kuznkdblsll  Двойной сдвиг влево на байт                       +     +      func3=0x5
    //  >>> Zkmagma
    //  magma32edf   Преобразование \(g[k](a_0)\)                      +            func3=0x6
    //  magma64edrl  Преобразование \(G[k](a_1, a_0)\) (младший ключ)        +      func3=0x6
    //  magma64edrh  Преобразование \(G[k](a_1, a_0)\) (старший ключ)        +      func3=0x7
    // two are of type I with ignored constant and the latter are R-type ones
    /// assign control_bus[`select_aluop_start+`select_aluop_bitcnt-1:`select_aluop_start] =
        /// {custom1, is_type_R, OP_32|OP_IMM_32, func7[5],func7[4],func7[2], func7[0], func3};
    wire [`select_aluop_bitcnt:1] select_alu_op = 
        control_bus[`select_aluop_start+`select_aluop_bitcnt-1:`select_aluop_start];

    wire is_custom1 = select_alu_op[`select_aluop_bitcnt];
    wire is_type_R  = select_alu_op[7];
    wire is_32_bit  = select_alu_op[6];

    wire func3 = select_alu_op[3:1];

    /// Shitty multiplexing is going on :-D
    //~ wire func7_5 = select_alu_op[5];
    //~ wire func7_4 = select_alu_op[4];
    //~ wire func7_2 = select_alu_op[3];
    //~ wire func7_0 = select_alu_op[2];
    wire is_sub_rol_xorn_sra_ror_orn_andn = select_alu_op[5];
    wire is_ror_rol_rev = select_alu_op[4];
    wire is_pack_rev = select_alu_op[3];
    wire is_rev8 = select_alu_op[2];

    reg [`XLEN:1] op_result;
    assign result = op_result;

    /// Just XD how stupid is this thing, VKR they said :-D
    wire is_sub = is_sub_rol_xorn_sra_ror_orn_andn & is_type_R;
    wire is_rol = is_sub_rol_xorn_sra_ror_orn_andn & is_ror_rol_rev;
    wire is_xorn = is_sub_rol_xorn_sra_ror_orn_andn;
    wire is_sra = is_sub_rol_xorn_sra_ror_orn_andn;
    wire is_ror = is_sub_rol_xorn_sra_ror_orn_andn & is_ror_rol_rev;
    wire is_orn = is_sub_rol_xorn_sra_ror_orn_andn;
    wire is_andn = is_sub_rol_xorn_sra_ror_orn_andn;

    wire [`XLEN:1] add_sub64 = arg1 + (is_sub? ~arg2: arg2) + is_sub;
    wire [32:1] add_sub32 = arg1[32:1] + (is_sub? ~arg2[32:1]: arg2[32:1]) + is_sub;
    wire [`XLEN:1] add_sub = is_32_bit? add_sub32 : add_sub64;

    wire [`XLEN:1] rfwd;


    wire [`XLEN:1]  = ;
    wire [`XLEN:1] add_sub = ;

    wire [`XLEN:1] add_sub_ell_rfwd;
    wire [`XLEN:1] sll_rol_bss_rinv;
    wire [`XLEN:1] slt_sboxfwd;
    wire [`XLEN:1] sltu_sboxinv;
    wire [`XLEN:1] xor_xnor_pack_dblsrl;
    wire [`XLEN:1] sr_ror_rev_dblsll;
    wire [`XLEN:1] or_orn_edf_edrl;
    wire [`XLEN:1] and_packh_edrh;

    always @* begin
        op_result = 0;
        case (func3)
            0x0 : op_result = add_sub_ell_rfwd;
            0x1 : op_result = sll_rol_bss_rinv;
            0x2 : op_result = slt_sboxfwd;
            0x3 : op_result = sltu_sboxinv;
            0x4 : op_result = xor_xnor_pack_dblsrl;
            0x5 : op_result = sr_ror_rev_dblsll;
            0x6 : op_result = or_orn_edf_edrl;
            0x7 : op_result = and_packh_edrh;
        endcase
    end

endmodule
