# Copyright 2026 Fe-Ti aka Tim Kravchenko
#
# Magma Pi module generator script
# 
# Nonlinear bijection
# Version:  1
#

file_header = """
// Copyright 2026 Fe-Ti aka Tim Kravchenko
//
// Magma hardware blocks lib
// 
// Nonlinear bijection
// Version:  1
//

// Pi'_i = (Pi'_i(0), Pi'_i(1), ... , Pi'_i(15)), i = 0, 1, ..., 7:

// Pi'_0 = (12, 4, 6, 2, 10, 5, 11, 9, 14, 8, 13, 7, 0, 3, 15, 1);
// Pi'_1 = (6, 8, 2, 3, 9, 10, 5, 12, 1, 14, 4, 7, 11, 13, 0, 15);
// Pi'_2 = (11, 3, 5, 8, 2, 15, 10, 13, 14, 1, 7, 4, 12, 9, 6, 0);
// Pi'_3 = (12, 8, 2, 1, 13, 4, 15, 6, 7, 0, 10, 5, 3, 14, 9, 11);
// Pi'_4 = (7, 15, 5, 10, 8, 1, 6, 13, 0, 9, 3, 14, 11, 4, 2, 12);
// Pi'_5 = (5, 13, 15, 6, 9, 2, 12, 10, 11, 7, 8, 1, 4, 3, 14, 0);
// Pi'_6 = (8, 14, 2, 5, 6, 9, 1, 12, 15, 4, 11, 0, 13, 10, 3, 7);
// Pi'_7 = (1, 7, 14, 13, 0, 5, 8, 3, 4, 15, 10, 6, 9, 12, 11, 2);

`timescale 1ns/1ns

"""
module_filename = "magma_pi"
pi_mod_name_template = "magma_pi_{num}"

KISS_pi_template = """
module {mod_name} (
    input wire [4:1] hex_in,
    output wire [4:1] hex_out
);
    reg [4:1] piresult;
    assign hex_out = piresult;

always @* begin
    case(hex_in)
{table_contents}    endcase
end
endmodule
"""
KISS_table_entry = """        4'd{num} : piresult = 4'd{val};
"""



# From RFC 8891

Pi = [  (12, 4, 6, 2, 10, 5, 11, 9, 14, 8, 13, 7, 0, 3, 15, 1),
        (6, 8, 2, 3, 9, 10, 5, 12, 1, 14, 4, 7, 11, 13, 0, 15),
        (11, 3, 5, 8, 2, 15, 10, 13, 14, 1, 7, 4, 12, 9, 6, 0),
        (12, 8, 2, 1, 13, 4, 15, 6, 7, 0, 10, 5, 3, 14, 9, 11),
        (7, 15, 5, 10, 8, 1, 6, 13, 0, 9, 3, 14, 11, 4, 2, 12),
        (5, 13, 15, 6, 9, 2, 12, 10, 11, 7, 8, 1, 4, 3, 14, 0),
        (8, 14, 2, 5, 6, 9, 1, 12, 15, 4, 11, 0, 13, 10, 3, 7),
        (1, 7, 14, 13, 0, 5, 8, 3, 4, 15, 10, 6, 9, 12, 11, 2),
        ]

mod_table_entries = ["" for i in range(8)]
for i in range(16):
    for k in range(8):
       mod_table_entries[k] += KISS_table_entry.format(num=i, val=Pi[k][i])


for k in range(8):
    file_header += KISS_pi_template.format(
            mod_name=pi_mod_name_template.format(num=k),
            table_contents=mod_table_entries[k] 
            )

with open(module_filename+".v",'w') as ofile:
    ofile.write(file_header)

