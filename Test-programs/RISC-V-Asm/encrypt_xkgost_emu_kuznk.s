# Copyright 2026 Fe-Ti aka Tim Kravchenko
#
# Kuznyechik programming
# 
# Kuznyechik base encryption
# Version:  1
#
# Register map (sort of):
#   - x1 is used as ra (Return Address reg)
#   - block is in x2,x3 (upper, lower)
#   - Keys are placed in x4...x7
#   - iter variable in x8
#   - C_i is in x10, x11
#   - Checkup sample is in x24, x25
#   - XORred checkup with result is in x26, x27
#
# Other regs may contain some temp data (look for comments with ###)

# Algorithm is as follows
#   Load initial data
#   main:
#       LSX[K1](a)
#       LSX[K2](a)
#       call key round 1
#       LSX[K3](a)
#       LSX[K4](a)
#       call key round 2
#       ...
#       LSX[K9](a)
#       X[K10](a)
#       goto halt

.global _start
_start:
# load_up_main_key:
    # Using sample key: MSB in x4, LSB in x7 :)
    # 8899aabbccddeeff
    # 0011223344556677
    # fedcba9876543210
    # 0123456789abcdef
    li x4, 0x8899aabbccddeeff # K1 upper half
    li x5, 0x0011223344556677 # K1 lower
    li x6, 0xfedcba9876543210 # K2 upper
    li x7, 0x0123456789abcdef # K2 lower

load_up_block:
    li x2, 0x1122334455667700 # upper half
    li x3, 0xffeeddccbbaa9988 # lower half

main:
    addi x8, zero, 64
loop_me_please:
    # mv  x15, x2 # moving block into LSX reserved regs (x15, x16)
    # mv  x16, x3
    # mv  x17, x4 # moving K1 into LSX regs
    # mv  x18, x5
    jal ra, LSX_K_odd_a # calling LSX[K1](a)
    # mv  x17, x6 # moving K2 into LSX regs
    # mv  x18, x7
    jal ra, LSX_K_even_a
    # mv  x2, x15 # save registers
    # mv  x3, x16

    jal ra, Key_go_round
    bne x8, zero, loop_me_please # if x8 is not zero goto loop_me_please

    # mv  x15, x2 # moving block into LSX reserved regs (x15, x16)
    # mv  x16, x3
    # mv  x17, x4 # moving K9 into LSX regs
    # mv  x18, x5
    jal ra, LSX_K_odd_a # calling LSX[K1](a)
    # mv  x2, x15 # save registers
    # mv  x3, x16
    xor x2, x2, x6
    xor x3, x3, x7

check_up_result:
    li x24, 0x7f679d90bebc2430
    li x25, 0x5a468d42b9d4edcd
    xor x26, x2, x24
    xor x27, x3, x25

halt:
    j halt  # jump to halt



### LSX k_even a procedure (K2, ...)
# Registers:
#   - block (h, l): x2, x3
#   - key k (h, l): x6, x7
#   - Clobbered: x19, x28
LSX_K_even_a:
    # do X[k](a)
    # xor x2, x2, x6
    # xor x3, x3, x7
    # jal x0, LSX_K_a_common_part  # jump to LSX_K_a_common_part

### LSX k_odd a procedure (K1, ...)
# Registers:
#   - block (h, l): x2, x3
#   - key k (h, l): x4, x5
#   - Clobbered: x19, x28
LSX_K_odd_a:
    # do X[k](a)
    # xor x2, x2, x4
    # xor x3, x3, x5
    # jump to common part === just go fwd :)

LSX_K_a_common_part:
    # do S(a)
    kuznksboxfwd x2, x2
    kuznksboxfwd x3, x3
    # Oh, yeah, babe! 16 R transforms :)
    li x28, 0x8
LSX_K_a_double_r_trans:
    kuznk64rfwd x19, x3, x2 # L half result
    kuznk64rfwd x3, x2, x19
    ret

## Key scheduling procs

### LSX for odd key procedure
# Registers:
#   - odd key (h, l): x4, x5
#   - constant c_i (h, l): x17, x18
#   - result in (h, l): x15, x16
#   - Clobbered: x19, x28, x15, x16
key_LSX_high_128bit:
    # do X[k](a)
    # xor x15, x4, x17
    # xor x16, x5, x18
    # jal x0, key_LSX_common_part  # jump to common part

### LSX for odd key procedure
# Registers:
#   - even key (h, l):  x6, x7
#   - constant c_i (h, l): x17, x18
#   - result in (h, l): x15, x16
#   - Clobbered: x19, x28, x15, x16
key_LSX_low_128bit:
    # do X[k](a)
    # xor x15, x6, x17
    # xor x16, x7, x18
    # now go to common part
key_LSX_common_part:
    # do S(a)
    kuznksboxfwd x15, x15
    kuznksboxfwd x16, x16
    kuznk64rfwd x19, x16, x15 # L half result
    kuznk64rfwd x16, x15, x19
    ret

Key_go_round:
    mv x31, x1
    ld x17, -1(x8) # Load high part of C_i1 into x17
    ld x18, -2(x8) # Load low  part of C_i1 into x18
    # mv x15, x4
    # mv x16, x5
    jal ra, key_LSX_high_128bit
    xor x6, x6, x15
    xor x7, x7, x16
    ld x17, -3(x8) # Load high part of C_i2 into x17
    ld x18, -4(x8) # Load low  part of C_i2 into x18
    # mv x15, x6
    # mv x16, x7
    jal ra, key_LSX_low_128bit
    xor x4, x4, x15
    xor x5, x5, x16
    ld x17, -5(x8) # Load high part of C_i3 into x17
    ld x18, -6(x8) # Load low  part of C_i3 into x18
    # mv x15, x4
    # mv x16, x5
    jal ra, key_LSX_high_128bit
    xor x6, x6, x15
    xor x7, x7, x16
    ld x17, -7(x8) # Load high part of C_i4 into x17
    ld x18, -8(x8) # Load low  part of C_i4 into x18
    # mv x15, x6
    # mv x16, x7
    jal ra, key_LSX_low_128bit
    xor x4, x4, x15
    xor x5, x5, x16
    ld x17, -9(x8) # Load high part of C_i5 into x17
    ld x18, -10(x8) # Load low  part of C_i5 into x18
    # mv x15, x4
    # mv x16, x5
    jal ra, key_LSX_high_128bit
    xor x6, x6, x15
    xor x7, x7, x16
    ld x17, -11(x8) # Load high part of C_i6 into x17
    ld x18, -12(x8) # Load low  part of C_i6 into x18
    # mv x15, x6
    # mv x16, x7
    jal ra, key_LSX_low_128bit
    xor x4, x4, x15
    xor x5, x5, x16
    ld x17, -13(x8) # Load high part of C_i7 into x17
    ld x18, -14(x8) # Load low  part of C_i7 into x18
    # mv x15, x4
    # mv x16, x5
    jal ra, key_LSX_high_128bit
    xor x6, x6, x15
    xor x7, x7, x16
    ld x17, -15(x8) # Load high part of C_i8 into x17
    ld x18, -16(x8) # Load low  part of C_i8 into x18
    # mv x15, x6
    # mv x16, x7
    jal ra, key_LSX_low_128bit
    xor x4, x4, x15
    xor x5, x5, x16
    addi x8, x8, -16 # x8 = x8 - 16
    
    mv x1, x31
    ret
