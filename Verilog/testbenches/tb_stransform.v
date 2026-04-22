// Copyright 2024-2026 Fe-Ti aka Tim Kravchenko
//
// Kuznyechik hardware blocks lib
// 
// Linear transform test bench
// Version:  1
//

`timescale 1ns/1ns

`include "../lib-kuznk/s-transform.v"
`include "../lib-kuznk/s-transform-inverse.v"
`default_nettype none

module tb_rtransform;

wire [127:0] ref_data_blocks [0:19];
wire [127:0] ref_s_res [0:19];

wire [127:0] result, result_inv;
reg [127:0] curr_datablock;

sbox64 fwd_rtransformer0 (
    .data_block_in (curr_datablock[63:0]),
    .data_block_out (result[63:0])
);
sbox64 fwd_rtransformer1 (
    .data_block_in (curr_datablock[127:64]),
    .data_block_out (result[127:64])
);

sbox64_inverse inv_rtransformer0 (
    .data_block_in (result[63:0]),
    .data_block_out (result_inv[63:0])
);
sbox64_inverse inv_rtransformer1 (
    .data_block_in (result[127:64]),
    .data_block_out (result_inv[127:64])
);

integer i, failures, failures_inverse;
initial begin
    $readmemb("tb_s-transform_source_blocks.txt", ref_data_blocks);
    $readmemb("tb_s-transform_fwdR_results.txt", ref_s_res);
    $display("S-box testbench:");
    for (i = 0; i < 20; i = i+1) begin
        curr_datablock = ref_data_blocks[i];
        #10;
        if (result != ref_s_res[i]) begin
            $display("FWD: Error %b ---> %b, but expected %b", curr_datablock, result, ref_s_res[i]);
            failures = failures + 1;
        end
        if (result_inv != curr_datablock) begin
            $display("INV: Error %b ---> %b, but expected %b", result, result_inv, curr_datablock);
            failures_inverse = failures_inverse + 1;
        end
    end
    $display("Failure count: fwd:%d,       inv:%d", failures, failures_inverse);
    $finish;
end


endmodule

