# ALU operation selector

Consider func7[:] == 0, except for specified modifiers.

func3 for I extension and Zbkb:
0x0 --- ADD/SUB (func7[5] modifies to SUB when is_type_R)
0x1 --- SLL                  (ROL(W) if func7[5] and func7[4])
0x2 --- SLT (set less than)
0x3 --- SLTU (set less than, as unsigned)
0x4 --- XOR                  (XNOR if func7[5]), (PACK if func7[2] or PACKW if 32-bit op)
0x5 --- SRL/SRA if func7[5]  (ROR(W) if func7[5] and func7[4]) (REV8 and BREV8 see below)
0x6 --- OR                   (ORN if func7[5])
0x7 --- AND                  (ANDN if func7[5]) (PACKH if func7[2])
Plus 64-bit addon with same func3, but modifier for 32-bit ops.
Plus brev8 and rev8 have special imm as follows (func7 = 011010x):
     brev8 (bit reversal)   --- 0110100 00111 (both) func3=0x5 
     rev8  (byte reversal)  --- 0110100 11000 (rv32) or 0110101 11000 (rv64) func3=0x5
thus func7[0] can be used as indicator for rv64

My additional commands are as follows (tables from Report):
opcode = custom1
 Мнемоника    Команда                                           RV32  RV64
 >>> Zkkuznk
 kuznk32ellh  Старшая часть суммы \(\ell(a)\)                   +            func3=0x0
 kuznk32elll  Младшая часть суммы \(\ell(a)\)                   +            func7[5]=1 func3=0x0
 kuznk32bssr  Сдвиг вправо c подстановкой старшего байта        +            func3=0x1
 kuznk32bssl  Сдвиг влево c подстановкой младшего байта         +            func7[5]=1 func3=0x1
 kuznk64rfwd  Преобразование \(R_{64}'(a)\)                           +      func3=0x0 
 kuznk64rinv  Преобразование \(R_{64}'^{-1}(a)\)                      +      func3=0x1
 kuznksboxfwd Преобразование \(S_{XLEN}\)         (rs1)         +     +  (I) imm=0x0 func3=0x2
 kuznksboxinv Преобразование \(S_{XLEN}^{-1}\)    (rs1)         +     +  (I) imm=0x0 func3=0x3
 kuznkdblsrl  Двойной сдвиг вправо на байт                      +     +      func3=0x4
 kuznkdblsll  Двойной сдвиг влево на байт                       +     +      func3=0x5
 >>> Zkmagma
 magma32edf   Преобразование \(g[k](a_0)\)                      +            func3=0x7
 magma64edrl  Преобразование \(G[k](a_1, a_0)\) (младший ключ)        +      func3=0x7
 magma64edrh  Преобразование \(G[k](a_1, a_0)\) (старший ключ)        +      func3=0x7 (func7[5])
two are of type I with ignored constant and the latter are R-type ones
 assign control_bus[`select_aluop_start+`select_aluop_bitcnt-1:`select_aluop_start] =
 {custom1, is_type_R, OP_32|OP_IMM_32, func7[5],func7[4],func7[2], func7[0], func3};
