// Copyright 2024-2025 Fe-Ti aka Tim Kravchenko
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
`include "polymul.v"

module elll (
    input wire [64:1] ls_block_half,
    output wire [8:1] elll_result,
);
// c0 1     
// c1 148   
// c2 32    
// c3 133   
// c4 16    
// c5 194   
// c6 192   
// c7 1     
wire [8:1] ca_0 = 1;
wire [8:1] ca_1 = 148;
wire [8:1] ca_2 = 32;
wire [8:1] ca_3 = 133;
wire [8:1] ca_4 = 16;
wire [8:1] ca_5 = 194;
wire [8:1] ca_6 = 192;
wire [8:1] ca_7 = 1;



assign elll_result = mul_0 ^ mul_1 ^ mul_2 ^ mul_3 ^ mul_4 ^ mul_5 ^ mul_6 ^ mul_7;

endmodule

module ellh ();

endmodule

