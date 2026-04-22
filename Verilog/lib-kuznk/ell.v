// Copyright 2024-2026 Fe-Ti aka Tim Kravchenko
//
// Kuznyechik hardware blocks lib
// 
// Linear transform
// Version:  1
//
// Ell(a) = sum_i^15 (c_i * a_i);  a_i,c_i in V_8
// c0    1   
// c1    148 
// c2    32  
// c3    133 
// c4    16  
// c5    194 
// c6    192 
// c7    1   
// c8    251 
// c9    1   
// c10   192 
// c11   194 
// c12   16  
// c13   133 
// c14   32  
// c15   148
`timescale 1ns/1ns
`include "polymul.v"

`ifndef KUZNK_ELL_TRANSFORM
`define KUZNK_ELL_TRANSFORM
`define PRIMITIVE_POLY_KUZNK 9'b111000011

module elll (
    input wire [64:1] ls_block_half,
    output wire [8:1] elll_result
);
wire [8:0] prim_poly = `PRIMITIVE_POLY_KUZNK; // Kuznyechik GF(2^8) primitive poly

wire [8:1] c[0:7];
assign c[0] = 1;
assign c[1] = 148;
assign c[2] = 32;
assign c[3] = 133;
assign c[4] = 16;
assign c[5] = 194;
assign c[6] = 192;
assign c[7] = 1;

wire [8:1] a[0:7];

wire [8:1] mul_result[0:7];

genvar i;
generate
    for (i = 0; i < 8; i = i+1) begin : ellh_polymuls_8
        assign a[i] = ls_block_half[(i+1)*8:i*8 + 1];
        polymul ca_pm8 (
            .a_in (a[i]),
            .b_in (c[i]),
            .prim_poly (prim_poly),
            .result_out (mul_result[i])
        );
    end
endgenerate

assign elll_result = 
        mul_result[0] ^ mul_result[1] ^ mul_result[2] ^ mul_result[3] ^ 
        mul_result[4] ^ mul_result[5] ^ mul_result[6] ^ mul_result[7];

endmodule

module ellh (
    input wire [64:1] ms_block_half,
    output wire [8:1] ellh_result
);
wire [8:0] prim_poly = `PRIMITIVE_POLY_KUZNK; // Kuznyechik GF(2^8) primitive poly
// c8    251 
// c9    1   
// c10   192 
// c11   194 
// c12   16  
// c13   133 
// c14   32  
// c15   148

wire [8:1] c[0:7]; // keep in mind that c[0] is actually c[8] and so on
assign c[0] = 251;
assign c[1] = 1  ;
assign c[2] = 192;
assign c[3] = 194;
assign c[4] = 16 ;
assign c[5] = 133;
assign c[6] = 32 ;
assign c[7] = 148;

wire [8:1] a[0:7];
wire [8:1] mul_result[0:7];

genvar i;
generate
    for (i = 0; i < 8; i = i+1) begin : ellh_polymuls_8
        assign a[i] = ms_block_half[(i+1)*8:i*8 + 1];
        polymul ca_pm8 (
            .a_in (a[i]),
            .b_in (c[i]),
            .prim_poly (prim_poly),
            .result_out (mul_result[i])
        );
    end
endgenerate

assign ellh_result = 
        mul_result[0] ^ mul_result[1] ^ mul_result[2] ^ mul_result[3] ^ 
        mul_result[4] ^ mul_result[5] ^ mul_result[6] ^ mul_result[7];

endmodule

module ell (
    input wire [128:1] data_block,
    output wire [8:1] ell_result
);

wire [8:1] high_part_sum, low_part_sum;

ellh ell_high_part (
    .ms_block_half (data_block[128:65]),
    .ellh_result (high_part_sum)
);
elll ell_low_part (
    .ls_block_half (data_block[64:1]),
    .elll_result (low_part_sum)
);

assign ell_result = high_part_sum ^ low_part_sum;

endmodule
`endif
