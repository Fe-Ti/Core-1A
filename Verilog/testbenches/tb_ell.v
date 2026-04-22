// Copyright 2024-2026 Fe-Ti aka Tim Kravchenko
//
// Kuznyechik hardware blocks lib
// 
// Linear transform test bench
// Version:  1
//

`include "../lib-kuznk/ell.v"
`default_nettype none

module tb_ell;

wire [127:0] ref_data_blocks [0:19];
wire [7:0] ref_ell_res [0:19];

wire [7:0] result;
reg [127:0] curr_datablock;

ell ell_transformer(
    .data_block (curr_datablock),
    .ell_result (result)
);

integer i, failures;
initial begin
    $readmemb("tb_ell_datablock_input.txt", ref_data_blocks);
    $readmemb("tb_ell_results.txt", ref_ell_res);
    for (i = 0; i < 20; i = i+1) begin
        curr_datablock = ref_data_blocks[i];
        #10;
        if (result != ref_ell_res[i]) begin
            $display("Error %b ---> %b, but expected %b", curr_datablock, result, ref_ell_res[i]);
            failures = failures + 1;
        end
    end
    $display("Failure count: %d", failures);
    $finish;
end


endmodule

