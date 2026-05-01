// Copyright 2024-2026 Fe-Ti aka Tim Kravchenko
//
// CPU test benches
// 
// Standard instruction tests
// Version:  1
//
// `include "constants.v"
`include "../cpu.v"
`default_nettype none
`timescale 1ns/1ns


`define PROGSIZE 100
`define tics_count 50

module tb_cpu;
reg clk;
reg rst;
wire [`IWIDTH:1] program_data [0:`PROGSIZE];


reg data_from_mem_is_ready, program_from_mem_is_ready;
reg [`IWIDTH:1] curr_instruction;
reg [`XLEN:1] data_from_mem;

wire mem_do_read, mem_do_write, mem_do_sync_d, mem_do_sync_i;
wire [3:1] mem_data_size;
wire [`XLEN:1] progmem_addr;
wire [`XLEN:1] mem_data_adddr;
wire [`XLEN:1] data_to_mem;


cpu RV64_CPU
(
    .global_reset (rst),
    .clk (clk),

    .program_mem_address (progmem_addr),

    .instruction (curr_instruction),
    .program_mem_ready (program_from_mem_is_ready),
    
    .data_mem_address (mem_data_adddr),
    .data_mem_stored_data (data_to_mem),
    .data_mem_cmd_datasize (mem_data_size),
    .data_mem_cmd_read (mem_do_read),
    .data_mem_cmd_write (mem_do_write),
    .mem_sync_cache_instruction (mem_do_sync_i),
    .mem_sync_cache_data (mem_do_sync_d),

    .data_mem_loaded_data (data_from_mem),
    .data_mem_ready (data_from_mem_is_ready)
);

initial begin
    $dumpfile("tb_res_normal_instructions_test_64.vcd");
    $dumpvars();
end
integer i;
initial begin
    $readmemh("programs/test_regular_instructions.hex", program_data);
    clk = 0;
    rst = 1;
    program_from_mem_is_ready = 1;
    data_from_mem_is_ready = 1;
    #10;
    rst = 0;
    #10;
    for (i = 0; i < `tics_count; i = i + 1) begin
        curr_instruction = program_data[progmem_addr[2+$clog2(`PROGSIZE):3]];
        $display("tick %d: %d : %h", i, progmem_addr[2+$clog2(`PROGSIZE):3], curr_instruction);
        clk = 1; $display("UP _/*"); #10; 
        // #10;
        clk = 0; $display("DN *\\_"); #10;
        $display("tick %d: %d ", i, progmem_addr[2+$clog2(`PROGSIZE):3]);
    end
    $finish(2);
end

endmodule
`default_nettype wire
