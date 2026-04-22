# Copyright 2026 Fe-Ti
# R-transform reference values generator

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


def calculate_ell(data_block):
    r = np.zeros(8, dtype=np.int8)
    for i in range(16):
        a = data_block[128-(i+1)*8:128-i*8] # in hardware smth like data_block[(i+1)*8-1:i*8]
        c_i = C[i]
        c_i = np.array([int(i) for i in bin(c_i)[2:].zfill(8)], dtype=np.int8)

        mul_res = polymul_ref(a, c_i)
        # print(f"{a} ---> {mul_res}")
        # print(f"c_i = {c_i}, a = {a_}")
        r ^= mul_res
        # print(f"result = {r}\n")
    return r

# reference R transforms
def calculate_R(data_block):
    ell_res = calculate_ell(data_block=data_block.copy())
    return np.concatenate([ell_res, data_block[:120]])


def calculate_iR(data_block):
    ell_res = calculate_ell(data_block=np.concatenate([data_block[8:],data_block[:8]]).copy())
    return np.concatenate([data_block[8:], ell_res])


### Helper functions
def convert_hex_to_bit_string(hex_string):
    bin_string = ''
    for h in hex_string:
        bin_string += bin(int(h,16))[2:].zfill(4)
    return bin_string

def get_binary_numpy_array_from_hex_str(hex_string):
    bin_string = convert_hex_to_bit_string(hex_string)
    return np.array([int(i) for i in bin_string], dtype=np.int8)

def write_bin_line(ofile, np_bin_array):
    ofile.write(str(np_bin_array.tolist())[1:-1].replace(' ','').replace(',','')+'\n')


# ITER_COUNT = 5
ITER_COUNT = 20
# DO_RANDOM = False # check up with gost samlples
DO_RANDOM = True
CONTROL_SAMPLE = get_binary_numpy_array_from_hex_str(
    "00000000000000000000000000000100"
)
CONTROL_REF = [get_binary_numpy_array_from_hex_str(i) for i in [
    "",
    "94000000000000000000000000000001",
    "a5940000000000000000000000000000",
    "64a59400000000000000000000000000",
    "0d64a594000000000000000000000000"
]]

print("R(a) transform tests")
# for c_i in C:
# with open("tb_polymul_results.txt", 'w') as ofile:
source_data_ofile = open("tb_r-transform_source_blocks.txt", 'w')
fwd_results_ofile = open("tb_r-transform_fwdR_results.txt", 'w')
# inv_results_ofile = open("tb_r-transform_invR_results.txt", 'w')
try:
    first_run = True
    for i in range(ITER_COUNT):
        # print(bin(c_i)[2:].zfill(8))
        print()
        if DO_RANDOM:
            data_block = np.random.randint(0, 2, size=128, dtype=np.int8)
        else:
            if first_run:
                print("Using control samples from GOST 34.12-2018...")
                data_block = CONTROL_SAMPLE
                first_run = False
            else:
                fail_cnt = int(sum(CONTROL_REF[i] != result))
                inverse_fail_cnt = int(sum(inv_result != data_block))
                if fail_cnt > 0:
                    print("Control REF", CONTROL_REF[i] )
                    print("R result:", result)
                print(f"Test #{i}. Fail count:", fail_cnt, "and", inverse_fail_cnt, "Congrats! :)"*((fail_cnt + inverse_fail_cnt) == 0) )
                # break
                data_block = result
        # print("Source data block:", data_block)
        result = np.int8(calculate_R(data_block))
        inv_result = calculate_iR(result)

        # Save data to files
        write_bin_line(source_data_ofile, data_block)
        write_bin_line(fwd_results_ofile, result)
        # write_bin_line(inv_results_ofile, inv_result)
        # print("R(a) Result: ", result)

        # ofile.write(str(r)[1:-1].replace(' ','')+'\n')
finally:
    source_data_ofile.close()
    fwd_results_ofile.close()
    # inv_results_ofile.close()






