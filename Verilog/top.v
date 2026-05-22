
`include "cpu.v"
// `include "xkgost_sim_cpu.v"

module top (
    input wire clk,
    input wire reset,
    input wire do_sync_regs,
    input wire spi_clk,
    input wire mosi,
    output wire miso
);
wire [`XLEN:1] CI_ROM [0:63];

reg [1:`IWIDTH + `XLEN + 1 + 1] inreg;
wire data_from_mem_is_ready = inreg[0];
wire program_from_mem_is_ready = inreg[1];
wire [`IWIDTH:1] curr_instruction = inreg[2:`IWIDTH+1];
wire [`XLEN:1] data_from_mem = inreg[`IWIDTH+2:`IWIDTH+`XLEN+1];


wire mem_do_read, mem_do_write, mem_do_sync_d, mem_do_sync_i;
wire [3:1] mem_data_size;
wire [`XLEN:1] progmem_addr;
wire [`XLEN:1] mem_data_adddr;
wire [`XLEN:1] data_to_mem;
reg [`XLEN+`XLEN+`XLEN+2:1] outreg;

assign miso = outreg[1];

cpu RV64_CPU
(
    .global_reset (reset),
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

integer i;
always @(posedge spi_clk) begin
    if (do_sync_regs) begin
        outreg <= {mem_do_read, mem_do_write, mem_data_size, progmem_addr, mem_data_adddr, data_to_mem};
    end
    else begin
        inreg[1] <= mosi;
        for (i=2; i < `IWIDTH + `XLEN + 1 + 1; i = i+1) begin
            inreg[i] <= inreg[i-1];
        end
        outreg[`XLEN+`XLEN+`XLEN+2] <= 0;
        for (i=2; i < `XLEN+`XLEN+`XLEN+2; i = i+1) begin
            outreg[i-1] <= outreg[i];
        end
    end
end


endmodule


