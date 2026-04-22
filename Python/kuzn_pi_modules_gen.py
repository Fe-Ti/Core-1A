# Copyright 2026 Fe-Ti aka Tim Kravchenko
#
# Kuznyechik Pi module generator script
# 
# Nonlinear bijection
# Version:  1
#

fwdpi_mod_name = "forward_pi"
invpi_mod_name = "inverse_pi"

# Wire array variant
KISS_pi_template = """
`timescale 1ns/1ns

module {mod_name} (
    input wire [8:1] byte_in,
    output wire [8:1] byte_out
);
    wire [8:1] pi_table [0:255];

{table_contents}

    assign byte_out = pi_table[byte_in];
endmodule
"""
KISS_table_entry = """    assign pi_table[{num}] = 8'd{val};
"""

# Case variant
KISS_pi_template = """
module {mod_name} (
    input wire [8:1] byte_in,
    output wire [8:1] byte_out
);
    reg [8:1] piresult;

always @* begin
    case(byte_in)
{table_contents}
    endcase
end

    assign byte_out = piresult;
endmodule
"""
KISS_table_entry = """        8'd{num} : piresult = 8'd{val};
"""



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

fwd_mod_table_entries = ""
inv_mod_table_entries = ""
for i in range(256):
    fwd_mod_table_entries += KISS_table_entry.format(num=i, val=pi[i])
    inv_mod_table_entries += KISS_table_entry.format(num=i, val=inverse_pi[i])


fwd_file_contents = KISS_pi_template.format(
        mod_name=fwdpi_mod_name,
        table_contents=fwd_mod_table_entries
        )

inv_file_contents = KISS_pi_template.format(
        mod_name=invpi_mod_name,
        table_contents=inv_mod_table_entries
        )

with open(fwdpi_mod_name+".v",'w') as ofile:
    ofile.write(fwd_file_contents)

with open(invpi_mod_name+".v",'w') as ofile:
    ofile.write(inv_file_contents)

