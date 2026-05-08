# Copyright 2026 Fe-Ti aka Tim Kravchenko
#
# Magma programming
# 
# Magma base encryption
# Version:  1
#
load_keys:
    # Using sample key
    # ffeeddccbbaa9988
    # 7766554433221100
    # f0f1f2f3f4f5f6f7
    # f8f9fafbfcfdfeff
    # Two iteration keys per register
    li x4, 0xffeeddccbbaa9988
    li x5, 0x7766554433221100
    li x6, 0xf0f1f2f3f4f5f6f7
    li x7, 0xf8f9fafbfcfdfeff
load_sample:
    # load control sample block
    li x1, 3
    li x2, 0xfedcba9876543210
fwd_run:
    addi x1, x1, -1 # x1 = x1 - 1
    magma64edrh x2, x2, x4
    magma64edrl x2, x2, x4
    magma64edrh x2, x2, x5
    magma64edrl x2, x2, x5
    magma64edrh x2, x2, x6
    magma64edrl x2, x2, x6
    magma64edrh x2, x2, x7
    magma64edrl x2, x2, x7
    bne x1, x0, fwd_run # if x1 != x0 then fwd_run
    magma64edrl x2, x2, x7
    magma64edrh x2, x2, x7
    magma64edrl x2, x2, x6
    magma64edrh x2, x2, x6
    magma64edrl x2, x2, x5
    magma64edrh x2, x2, x5
    magma64edrl x2, x2, x4
    magma64edrh x2, x2, x4
    rori x2, x2, 32
    li x8, 0x4ee901e5c2d8ca3d
    xor x9, x2, x8

    j load_keys # jump to load_keys
