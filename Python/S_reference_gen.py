# Copyright 2026 Fe-Ti
# S-box reference values generator

import numpy as np


# From RFC 7801
pi = [252, 238, 221,  17, 207, 110,  49,  22, 251, 196, 250,
           218,  35, 197,   4,  77, 233, 119, 240, 219, 147,  46,
           153, 186,  23,  54, 241, 187,  20, 205,  95, 193, 249,
            24, 101,  90, 226,  92, 239,  33, 129,  28,  60,  66,
           139,   1, 142,  79,   5, 132,   2, 174, 227, 106, 143,
           160,   6,  11, 237, 152, 127, 212, 211,  31, 235,  52,
            44,  81, 234, 200,  72, 171, 242,  42, 104, 162, 253,
            58, 206, 204, 181, 112,  14,  86,   8,  12, 118,  18,
           191, 114,  19,  71, 156, 183,  93, 135,  21, 161, 150,
            41,  16, 123, 154, 199, 243, 145, 120, 111, 157, 158,
           178, 177,  50, 117,  25,  61, 255,  53, 138, 126, 109,
            84, 198, 128, 195, 189,  13,  87, 223, 245,  36, 169,
            62, 168,  67, 201, 215, 121, 214, 246, 124,  34, 185,
             3, 224,  15, 236, 222, 122, 148, 176, 188, 220, 232,
            40,  80,  78,  51,  10,  74, 167, 151,  96, 115,  30,
             0,  98,  68,  26, 184,  56, 130, 100, 159,  38,  65,
           173,  69,  70, 146,  39,  94,  85,  47, 140, 163, 165,
           125, 105, 213, 149,  59,   7,  88, 179,  64, 134, 172,
            29, 247,  48,  55, 107, 228, 136, 217, 231, 137, 225,
            27, 131,  73,  76,  63, 248, 254, 141,  83, 170, 144,
           202, 216, 133,  97,  32, 113, 103, 164,  45,  43,   9,
            91, 203, 155,  37, 208, 190, 229, 108,  82,  89, 166,
           116, 210, 230, 244, 180, 192, 209, 102, 175, 194,  57,
            75,  99, 182]

# As it's bijection the inverse table is as follows
inverse_pi = [0 for i in range(256)]
for i, e in enumerate(pi):
    inverse_pi[e] = i

def arr_to_num(arr):
    num = 0
    for i in range(len(arr)):
        num += arr[len(arr)-i-1] * 2**i
    return num

def num_to_arr(num, arr_len):
    return np.array(list(bin(num)[2:].zfill(arr_len)), dtype=np.int8)

def calculate_S(data_block_in):
    data_block_out = np.array([], dtype=np.int8)
    for i in range(16):
        byte_val = pi[arr_to_num(data_block_in[i*8:(i+1)*8])]
        data_block_out = np.concatenate([data_block_out, num_to_arr(byte_val, 8)])
    return data_block_out

def calculate_iS(data_block_in):
    data_block_out = np.array([], dtype=np.int8)
    for i in range(16):
        byte_val = inverse_pi[arr_to_num(data_block_in[i*8:(i+1)*8])]
        data_block_out = np.concatenate([data_block_out, num_to_arr(byte_val, 8)], dtype=np.int8)
    return data_block_out


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
    "ffeeddccbbaa99881122334455667700"
)
CONTROL_REF = [get_binary_numpy_array_from_hex_str(i) for i in [
    "",
    "b66cd8887d38e8d77765aeea0c9a7efc",
    "559d8dd7bd06cbfe7e7b262523280d39",
    "0c3322fed531e4630d80ef5c5a81c50b",
    "23ae65633f842d29c5df529c13f5acda"
]]

print("S(a) transform tests")
# for c_i in C:
# with open("tb_polymul_results.txt", 'w') as ofile:
source_data_ofile = open("tb_s-transform_source_blocks.txt", 'w')
fwd_results_ofile = open("tb_s-transform_fwdR_results.txt", 'w')
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
                    print("S result:", result)
                print(f"Test #{i}. Fail count:", fail_cnt, "and", inverse_fail_cnt, "Congrats! :)"*((fail_cnt + inverse_fail_cnt) == 0) )
                # break
                data_block = result
        # print("Source data block:", data_block)
        result = np.int8(calculate_S(data_block))
        inv_result = calculate_iS(result)

        # Save data to files
        write_bin_line(source_data_ofile, data_block)
        write_bin_line(fwd_results_ofile, result)
        # print("S(a) Result: ", result)

        # ofile.write(str(r)[1:-1].replace(' ','')+'\n')
finally:
    pass
    source_data_ofile.close()
    fwd_results_ofile.close()






