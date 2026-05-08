`include "constants.v"

`define LINE_COUNT 16
`define LINE_SIZE 32

module icache (
    input wire [`XLEN:1] address,
    input wire [`IWIDTH:1] instruction_from_mem,
    input wire mem_ctrlr_data_ready,
    output wire [`XLEN:1] fetch_address,
    output wire req_fetch,
    output wire [`IWIDTH:1] instruction
);

reg [`IWIDTH*`LINE_SIZE:1] cache_mem [`LINE_COUNT-1:0];
reg is_valid [`LINE_COUNT-1:0];
reg [`XLEN-$clog2(`LINE_SIZE)-2:1] tag [`LINE_COUNT:0];

reg [$clog2(`LINE_COUNT):1] victim_ctr;

assign fetch_address = {address[`XLEN:3], 2'b00};


endmodule

