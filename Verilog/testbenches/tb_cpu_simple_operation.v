// Copyright 2024-2026 Fe-Ti aka Tim Kravchenko
//
// CPU test benches
// 
// Standard instruction tests
// Version:  1
//

// `include "cpu.v"
`default_nettype none
`define PROGSIZE 32
module tb_cpu;
reg clk;
reg rst_n;

wire [31:0] program_data [0:`PROGSIZE];

// cpu 
// (
//     .global_reset (rst_n),
//     .clk (clk),
// );

localparam CLK_PERIOD = 10;
// always #(CLK_PERIOD/2) clk=~clk;

// initial begin
    // $dumpfile("tb_cpu.vcd");
    // $dumpvars(0, tb_cpu);
// end
integer i;
initial begin
    $readmemh("programs/test_regular_instructions.hex", program_data);
    for (i = 0; i < `PROGSIZE; i = i + 1) begin
        $display("%d : %h",i, program_data[i]);
    end
    $finish(2);
end

endmodule
`default_nettype wire
