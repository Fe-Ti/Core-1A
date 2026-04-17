// Copyright 2024-2025 Fe-Ti aka Tim Kravchenko
//
// Register file module
// Version:  1
// Codename: Shikra (lat: Tachyspiza badia)

`include "constants.v"

module register_file(
    input wire [`REG_SELECT_WIDTH:1] rs1_addr, rs2_addr, rd_addr,
    input wire [`XLEN:1] input_data,
    input wire write_enable,
    input wire clk,
    output wire [`XLEN:1] rs1, rs2
);
    reg [`XLEN:0] x[31:0];
    always @(posedge clk) begin
        if (write_enable)
            x[rd_addr] <= input_data;
    end
    assign rs1[`XLEN:1] = (rs1_addr != 0) : x[rs1_addr] : 0x0;
    assign rs2[`XLEN:1] = (rs2_addr != 0) : x[rs2_addr] : 0x0;
endmodule
