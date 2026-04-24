// Copyright 2024-2026 Fe-Ti aka Tim Kravchenko
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
    reg [`XLEN:1] x[31:0];
    always @(posedge clk) begin
        if (write_enable)
            x[rd_addr] <= input_data;
    end
    assign rs1[`XLEN:1] = (rs1_addr != 0) ? x[rs1_addr] : 0;
    assign rs2[`XLEN:1] = (rs2_addr != 0) ? x[rs2_addr] : 0;
endmodule

module overrider_block (
    input wire [`XLEN:1] old_rs1, old_rs2, fwd_ex_rd, fwd_wb_rd,
    input wire stage_fd_override_rs1_with_rdwb, stage_fd_override_rs2_with_rdwb,
               stage_fd_override_rs1_with_rdex, stage_fd_override_rs2_with_rdex,
    output wire [`XLEN:1] rs1, rs2
);
    wire [`XLEN:1] rs1_wb_overriden = stage_fd_override_rs1_with_rdwb ? fwd_wb_rd : old_rs1;
    assign rs1 = stage_fd_override_rs1_with_rdex ? fwd_ex_rd : rs1_wb_overriden;

    wire [`XLEN:1] rs2_wb_overriden = stage_fd_override_rs1_with_rdwb ? fwd_wb_rd : old_rs2;
    assign rs2 = stage_fd_override_rs1_with_rdex ? fwd_ex_rd : rs2_wb_overriden;
endmodule

module overrider_register_file (
    input wire [`REG_SELECT_WIDTH:1] rs1_addr, rs2_addr, rd_addr,
    input wire [`XLEN:1] input_data, fwd_ex_rd, fwd_wb_rd,
    input wire write_enable,
    input wire clk,
    input wire stage_fd_override_rs1_with_rdwb, stage_fd_override_rs2_with_rdwb,
               stage_fd_override_rs1_with_rdex, stage_fd_override_rs2_with_rdex,
    output wire [`XLEN:1] rs1, rs2
);
    wire [`XLEN:1] tmp_rs1, tmp_rs2;

    register_file rf (
        .rs1_addr (rs1_addr),
        .rs2_addr (rs2_addr),
        .rd_addr (rd_addr),
        .input_data (input_data),
        .write_enable (write_enable),
        .clk (clk),
        .rs1 (tmp_rs1),
        .rs2 (tmp_rs2)
    );

    overrider_block ob (
        .old_rs1 (tmp_rs1), 
        .old_rs2 (tmp_rs2), 
        .fwd_ex_rd (fwd_ex_rd), 
        .fwd_wb_rd (fwd_wb_rd),
        .stage_fd_override_rs1_with_rdwb (stage_fd_override_rs1_with_rdwb), 
        .stage_fd_override_rs2_with_rdwb (stage_fd_override_rs2_with_rdwb),
        .stage_fd_override_rs1_with_rdex (stage_fd_override_rs1_with_rdex), 
        .stage_fd_override_rs2_with_rdex (stage_fd_override_rs2_with_rdex),
        .rs1 (rs1), 
        .rs2 (rs2)
    );

endmodule

