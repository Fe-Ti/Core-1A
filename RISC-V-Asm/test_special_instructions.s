entry:
    addi    x1, x0, 0x100 # x1 = x0 + 0x100
    addi    x2, x0, 0x0 # x2 = x1  -33
    kuznksboxfwd x1, x1
    kuznksboxinv x1, x1
    kuznk64rfwd x3, x1, x2 # R half result
    kuznkdblsrl x1, x1, x2 # R shift in second half result
go_back:
    jal     x0, entry
    
    

