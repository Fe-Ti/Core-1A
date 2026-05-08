`include "constants.v"

module mem_controller (
    input wire clk,
    input wire [`XLEN:1] instruction_addr, data_addr,
    input wire [`select_mem_size_bitcnt:1] select_mem_size_sext,
    input wire instr_req, data_read_req, data_write_req,
    output wire [`XLEN:1] data_to_ram,
    output wire instr_ready, data_ready
);
    reg req_selector;
    always @(posedge clk) begin
        req_selector <= ~req_selector;
    end
    

endmodule

