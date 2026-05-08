# Copyright 2026 Fe-Ti aka Tim Kravchenko
#
# Kuznyechik programming
# 
# Key scheduling template generator
# Version:  1
#

import kuznk_L_transform as ltlib
import numpy as np

# Registers to be used in templates
C_upper = 'x17'
C_lower = 'x18'
Key_1_h = 'x4'
Key_1_l = 'x5'
Key_2_h = 'x6'
Key_2_l = 'x7'

LSX_K_h = C_upper
LSX_K_l = C_lower
LSX_a_h = 'x15'
LSX_a_l = 'x16'

RA_save_reg = 'x31'


def bin_arr_to_num(arr):
    num = 0
    for i in range(len(arr)):
        num += arr[len(arr)-i-1] * 2**i
    return num



def bin_array_to_hex_string(arr):
    hex_str = ""
    head_len = len(arr) - (len(arr) // 4) * 4
    for i in range(len(arr)//4):
        arr_slice = arr[len(arr)-(i+1)*4:len(arr)-i*4]
        hex_str = f"{bin_arr_to_num(arr_slice):x}" + hex_str
    if head_len > 0:
        hex_str = f"{bin_arr_to_num(arr[:head_len]):x}" + hex_str
    return(hex_str)

# print(bin_array_to_hex_string(np.array([1,0,0,0,1,0,0,1,1,1,0])))
do_load_cconst_from_mem = True
cconsts_verilog_mem_string = ""
for i in range(4):
    print(f"Key_schedule_{i+1}:")
    print(f"    mv {RA_save_reg}, x1")
    for k in range(0, 8, 2):
        # Two Feistel steps per iteration
        C_i = ltlib.calculate_L(
            np.array(
                [int(j) for j in bin(i*8+k+1)[2:].zfill(128)], dtype=np.int8
            )
        )
        cconsts_verilog_mem_string = bin_array_to_hex_string(C_i[:64]) + " " + cconsts_verilog_mem_string
        cconsts_verilog_mem_string = bin_array_to_hex_string(C_i[64:]) + "\n" + cconsts_verilog_mem_string
        # print("    li C_upper,", "0x"+bin_array_to_hex_string(C_i), "# Load C_{i} into C_upper")
        # print(i+1, ':', '0x'+bin_array_to_hex_string(C_i))
        print(f"    li {C_upper}, 0x{bin_array_to_hex_string(C_i[:64])} # Load high part of C_{i*8+k+1} into {C_upper}")
        print(f"    li {C_lower}, 0x{bin_array_to_hex_string(C_i[64:])} # Load low  part of C_{i*8+k+1} into {C_lower}")
        print(f"    mv {LSX_a_h}, {Key_1_h}")
        print(f"    mv {LSX_a_l}, {Key_1_l}")
        print(f"    jal ra, LSX_K_a")
        print(f"    xor {Key_2_h}, {Key_2_h}, {LSX_a_h}")
        print(f"    xor {Key_2_l}, {Key_2_l}, {LSX_a_l}")

        C_i = ltlib.calculate_L(
            np.array(
                [int(j) for j in bin(i*8+k+2)[2:].zfill(128)], dtype=np.int8
            )
        )
        cconsts_verilog_mem_string = bin_array_to_hex_string(C_i[:64]) + " " + cconsts_verilog_mem_string
        cconsts_verilog_mem_string = bin_array_to_hex_string(C_i[64:]) + "\n" + cconsts_verilog_mem_string
        # print(i+1, ':', '0x'+bin_array_to_hex_string(C_i))
        # print("    li C_upper,", "0x"+bin_array_to_hex_string(C_i), "# Load C_{i} into C_upper")
        print(f"    li {C_upper}, 0x{bin_array_to_hex_string(C_i[:64])} # Load high part of C_{i*8+k+2} into {C_upper}")
        print(f"    li {C_lower}, 0x{bin_array_to_hex_string(C_i[64:])} # Load low  part of C_{i*8+k+2} into {C_lower}")
        print(f"    mv {LSX_a_h}, {Key_2_h}")
        print(f"    mv {LSX_a_l}, {Key_2_l}")
        print(f"    jal ra, LSX_K_a")
        print(f"    xor {Key_1_h}, {Key_1_h}, {LSX_a_h}")
        print(f"    xor {Key_1_l}, {Key_1_l}, {LSX_a_l}")

    print(f"    mv x1, {RA_save_reg}")
    print(f"    ret\n")


if do_load_cconst_from_mem:
    print(cconsts_verilog_mem_string)