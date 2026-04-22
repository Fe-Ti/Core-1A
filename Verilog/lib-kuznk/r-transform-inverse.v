// Copyright 2024-2026 Fe-Ti aka Tim Kravchenko
//
// Kuznyechik hardware blocks lib
// 
// R-transform inverse
// Version:  1
//
// R^{-1}(a) = a_14 || ... || a_0 || ell(a_14,...,a_0, a_15) 
// 
`timescale 1ns/1ns
`include "ell.v"

module inverse_R (
    input wire [128:1] data_block_in,
    output wire [128:1] data_block_out
);

wire [8:1] ell_result;

ell ell_block (
    .data_block ({data_block_in[120:1], data_block_in[128:121]}),
    .ell_result (ell_result)
);

assign data_block_out = {data_block_in[120:1], ell_result};

endmodule


