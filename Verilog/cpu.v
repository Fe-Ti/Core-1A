// Copyright 2024-2025 Fe-Ti aka Tim Kravchenko
//
// Main CPU module
// Version:  1
// Codename: Shikra (lat: Tachyspiza badia)

`include "constants.v"
`include "decoder.v"
`include "register.v"
`include "next_PC_generator.v"
`include "alu.v"

`define MEMSIZE_BUS_WIDTH `select_mem_size_bitcnt

// module hazard_solver(
// );

// endmodule


module cpu(
    input wire clk,
    input wire reset,
    output wire [`XLEN:1] program_mem_address,
    input wire [`IWIDTH:1] instruction,
    input wire program_mem_ready,
    output wire [`XLEN:1] data_mem_address,
    output wire [`XLEN:1] data_mem_stored_data,
    output wire [`MEMSIZE_BUS_WIDTH:1] mem_data_size,
    input wire [`XLEN:1] data_mem_loaded_data
)

always @(posedge clk) begin
    
end

endmodule
