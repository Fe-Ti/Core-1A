entry:
    addi    x1, x0, 0x100 # x1 = x0 + 0x100
    addi    x2, x1, 0x0 # x2 = x1  -33
    sub     x3, x1, x2 # x3 = x1 - x2 == 33
    sb      x1, 0(x2) # Storing x1 at x2+0 as byte (8 bits)
    sd      x1, 0(x2) # Storing x1 at x2+0 as double word (64 bits)
    lui     x4, 2 # x4 = 2<<12 (upper immediate)
    sd      x4, 0(x1)
    auipc   x5, 4 # x5 = PC + 4<<12
    sd      x5, 0(x1)
    jal     x31, some_point  # jump to some_point and save position to x31
    lb      x20, 0(x3)
    lbu     x21, 0(x3)
    ld      x22, 0(x3)
    ld      x23, 0(x3)
    addi    x7, x0, -1009  
    slt     x9, x1, x7
    sltu    x9, x1, x7
    slli    x9, x9, 10
    slli    x9, x9, 21
    srai    x9, x9, 5
    srli    x9, x9, 5
    ori     x9, x9, 1
    xori    x9, x9, 1
    beq     x9, x4, target_eq
    bne     x9, x5, target_neq   
target_eq:
    fence
    jal     x0, go_back
target_neq:
    fence.i
go_back:
    jal     x0, entry
some_point:
    jalr    x31, x31, 0 # return back where we jumped 
    
    

