# Copyright 2026 Fe-Ti aka Tim Kravchenko
#
# Kuznyechik programming
# 
# Generator of C_i as li instructions templates
# Version:  1
#

import kuznk_L_transform as ltlib
import numpy as np

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

for i in range(32):
    C_i = ltlib.calculate_L(
        np.array(
            [int(i) for i in bin(i+1)[2:].zfill(128)], dtype=np.int8
        )
    )
    # print(i+1, ':', '0x'+bin_array_to_hex_string(C_i))
    # print("    li XX,", "0x"+bin_array_to_hex_string(C_i), "# Load C_{i} into XX")
    print("    li XX,", "0x"+bin_array_to_hex_string(C_i[:64]), "# Load high part of C_{i} into XX")
    print("    li YY,", "0x"+bin_array_to_hex_string(C_i[64:]), "# Load low  part of C_{i} into YY")
