# Copyright 2026 Fe-Ti
# C_i constant to scheme generator

import numpy as np

# Ell(a) = sum_i^15 (c_i * a_i)
# c0    1   
# c1    148 
# c2    32  
# c3    133 
# c4    16  
# c5    194 
# c6    192 
# c7    1   
# c8    251 
# c9    1   
# c10   192 
# c11   194 
# c12   16  
# c13   133 
# c14   32  
# c15   148 

C = [
    1   ,
    148 ,
    32  ,
    133 ,
    16  ,
    194 ,
    192 ,
    1   ,
    251 ,
    1   ,
    192 ,
    194 ,
    16  ,
    133 ,
    32  ,
    148 ,
]
# 111000011
p = np.array([1,1,1,0,0,0,0,1,1], dtype=np.int8)

a = np.array([1,0,1,1,1,0,0,0], dtype=np.int8)

def polymul_ref(a, c_i):
    r = np.zeros(8, dtype=np.int8)
    for j in range(8):
        if (c_i[-1] == 1): # looking at lsbit
            r ^= a # if it's 1 then XOR result with a

        msbit = a[0] # saving msbit
        a[:-1] = a[1:] # shifting left logically
        a[-1]   = 0x0 # lsb set to 0
        # print(a)
        
        if (msbit == 1) : # if overflow occured then
            a ^= p[1:] # subtract (xor) the primitive poly

        c_i[1:] = c_i[:-1]
        c_i[0] = 0x0 # shift right logically
    return r



# for c_i in C:
with open("tb_polymul_results.txt", 'w') as ofile:
    for a in range(256):
        # print(bin(c_i)[2:].zfill(8))
        c_i = C[8]
        c_i = np.array([int(i) for i in bin(c_i)[2:].zfill(8)], dtype=np.int8)
        a_ = np.array([int(i) for i in bin(a)[2:].zfill(8)], dtype=np.int8)
        # algorithm from https://habr.com/ru/articles/871092/
        print(f"c_i = {c_i}, a = {a_}")
        r = polymul_ref(a_, c_i)
        print(f"result = {r}\n")
        ofile.write(str(r)[1:-1].replace(' ','')+'\n')







