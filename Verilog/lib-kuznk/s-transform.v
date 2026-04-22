// Copyright 2024-2026 Fe-Ti aka Tim Kravchenko
//
// Kuznyechik hardware blocks lib
// 
// S-box transform blocks
// Version:  1
//
// S(a) = pi(a_15)||...||pi(a_0)
//  

//// TODO: implement sbox better
// `define FALLBACK_SBOX

// `ifdef FALLBACK_SBOX
// `include "forward_pi.v"
// // `include "inverse_pi.v"
// `else
// `include "clever_sbox.v"
// // `include "clever_sbox_inv.v"
// `endif

module sbox32 (
    input wire [32:1] data_block_in,
    output wire [32:1] data_block_out
);
genvar i;
generate
    for (i = 0; i < 4; i = i + 1) begin : pi_byte_transformers
        forward_pi pibyte_transformer (
            .byte_in(data_block_in[(i+1)*8:i*8+1]),
            .byte_out(data_block_out[(i+1)*8:i*8+1])
        );
    end
endgenerate
endmodule

module sbox64 (
    input wire [64:1] data_block_in,
    output wire [64:1] data_block_out
);
sbox32 ms_half_transformer (
    .data_block_in (data_block_in[64:33]),
    .data_block_out (data_block_out[64:33])
);
sbox32 ls_half_transformer (
    .data_block_in (data_block_in[32:1]),
    .data_block_out (data_block_out[32:1])
);
endmodule

