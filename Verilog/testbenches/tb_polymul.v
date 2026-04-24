// Copyright 2024-2026 Fe-Ti aka Tim Kravchenko
//
// Kuznyechik hardware blocks lib
// 
// Polynomial multiply (8-bit) test bench
// Version:  1
//
`include "../lib-kuznk/polymul.v"
`default_nettype none
`timescale 1ns/1ns

module tb_polymul;

reg [7:0] a;
wire [7:0] c = 8'd251; // 8-bit decimal 251
wire [8:0] prim_poly = 9'b111000011; // Kuznyechik GF(2^8) primitive poly
wire [7:0] result;

reg [7:0] reference_results [0:255];

polymul mul8bit (
    .a_in (a),
    .b_in (c),
    .prim_poly (prim_poly),
    .result_out (result)
);

wire [5:1] x = 5'b00100;
wire [5:1] y = 5'b10000;

// initial begin
//     $dumpfile("tb_.vcd");
//     $dumpvars(0, tb_);
// end
integer i, failures;
initial begin
    failures = 0;
    $display("Reading reference values...");
    $readmemb("tb_polymul_results.txt", reference_results);
    $display("a * c = result");
    for (i = 0; i < 256; i = i+1) begin
        a = i[7:0];
        #10;
        $display("%b * %b == %b", a, c, result);
        if(result != reference_results[i]) begin
            failures = failures + 1;
            $display("Unexpected result! Ref: %b",reference_results[i]);
        end
    end
    $display("Failure count: %d", failures);
    $finish;
end

endmodule
