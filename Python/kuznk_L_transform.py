import R_reference_gen as rlib

def calculate_L(data_block):
    for i in range(16):
        data_block = rlib.calculate_R(data_block=data_block)
    return data_block

if __name__ == "__main__":
    sample = "64a59400000000000000000000000000"
    control = "d456584dd0e3e84cc3166e4b7fa2890d"

    sample = rlib.get_binary_numpy_array_from_hex_str(sample)
    control = rlib.get_binary_numpy_array_from_hex_str(control)

    res = calculate_L(sample)
    err = control ^ res

    print("SMPL:",sample)
    print("CTRL:",control)
    print("RES:",res)
    print(err, '\n', sum(err))
