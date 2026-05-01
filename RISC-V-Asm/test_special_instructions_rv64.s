entry:
    addi    x1, x0, 0x100 # x1 = x0 + 0x100
    addi    x2, x0, 0x0
    kuznk64rfwd x3, x1, x2 # R half result
    kuznkdblsrl x1, x1, x2 # R shift in second half result
    # kuznk64rfwd x3, x2, x1 # R half result
    # kuznkdblsrl x1, x2, x1 # R shift in second half result
    li x4, 0x9400000000000000
    li x5, 0x0000000000000001
    xor x8, x3, x4
    xor x9, x1, x5
    kuznk64rfwd x2, x1, x3 # R half result
    kuznkdblsrl x1, x1, x3 # R shift in second half result
    li x4, 0xa594000000000000
    li x5, 0x0000000000000000
    xor x8, x2, x4
    xor x9, x1, x5
    kuznk64rinv x3, x1, x2 # R half result
    kuznkdblsll x1, x1, x2 # R shift in second half result
    li x4, 0x9400000000000000
    li x5, 0x0000000000000001
    xor x8, x3, x4
    xor x9, x1, x5
    
sbox_testing: # Using gost control sample
    li x4, 0xffeeddccbbaa9988
    li x5, 0x1122334455667700
    kuznksboxfwd x4, x4
    kuznksboxfwd x5, x5
    li x6, 0xb66cd8887d38e8d7
    li x7, 0x7765aeea0c9a7efc
    xor x8, x6, x4
    xor x9, x7, x5
    kuznksboxinv x6, x6
    kuznksboxinv x7, x7
    li x4, 0xffeeddccbbaa9988
    li x5, 0x1122334455667700
    xor x8, x6, x4
    xor x9, x7, x5

magma_testing:
    # load up 2 Keys ffeeddcc (K1) and bbaa998 (K2)
    li x1, 0xffeeddccbbaa9988
    # load control sample block
    li x2, 0xfedcba9876543210
    magma64edrh x2, x2, x1
    li x3, 0x7654321028da3b14 # Check G[K1](a1,a0)
    xor x8, x2, x3
    magma64edrl x2, x2, x1
    li x3, 0x28da3b14b14337a5 # Check G[K2](a1,a0)
    xor x8, x2, x3
go_back:
    jal     x0, entry
    
    

