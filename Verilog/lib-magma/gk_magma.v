// Copyright 2024-2025 Fe-Ti aka Tim Kravchenko
//
// Magma hardware blocks lib
// 
// T-transform:
// t(a) = pi_7(a_7) || ... || pi_0(a_0)
// 
// Version:  1
//

`include "magma_pi.v"

module t_transform (
    input wire [32:1] data_block_in,
    output wire [32:1] data_block_out
);

magma_pi_0 pi_transformer_0 (
    .hex_in (data_block_in[4 -:4]),
    .hex_out (data_block_out[4 -:4])
);
magma_pi_1 pi_transformer_1 (
    .hex_in (data_block_in[8 -:4]),
    .hex_out (data_block_out[8 -:4])
);
magma_pi_2 pi_transformer_2 (
    .hex_in (data_block_in[12 -:4]),
    .hex_out (data_block_out[12 -:4])
);
magma_pi_3 pi_transformer_3 (
    .hex_in (data_block_in[16 -:4]),
    .hex_out (data_block_out[16 -:4])
);
magma_pi_4 pi_transformer_4 (
    .hex_in (data_block_in[20 -:4]),
    .hex_out (data_block_out[20 -:4])
);
magma_pi_5 pi_transformer_5 (
    .hex_in (data_block_in[24 -:4]),
    .hex_out (data_block_out[24 -:4])
);
magma_pi_6 pi_transformer_6 (
    .hex_in (data_block_in[28 -:4]),
    .hex_out (data_block_out[28 -:4])
);
magma_pi_7 pi_transformer_7 (
    .hex_in (data_block_in[32 -:4]),
    .hex_out (data_block_out[32 -:4])
);

endmodule

module gk_magma32 (
    input wire [32:1] data_block_in,
    input wire [32:1] key_in,
    output wire [32:1] data_block_out
);

    wire [32:1] sum_data_key = data_block_in + key_in;
    wire [32:1] t_result;

    t_transform t_transformer (
        .data_block_in (sum_data_key),
        .data_block_out (t_result)
    );
    // Rotating by 11 bits to left
    assign data_block_out = t_result<<11 | t_result>>(32-11);
    // assign data_block_out = {t_result[21:1], t_result[32:22]};
endmodule

module gk_magma64(
    input wire [64:1] data_block_in,
    input wire [32:1] key_in,
    output wire [64:1] data_block_out
);
    wire [32:1] a_1 = data_block_in[64:33];
    wire [32:1] a_0 = data_block_in[32:1];
    wire [32:1] gk32_result;

    gk_magma32 gk32_transformer (
        .data_block_in (a_0),
        .key_in (key_in),
        .data_block_out (gk32_result)
    );

    assign data_block_out = {a_0, gk32_result ^ a_1}; 
endmodule

