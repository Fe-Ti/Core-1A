// Copyright 2024-2026 Fe-Ti aka Tim Kravchenko
//
// Main CPU module
// Version:  1
// Codename: Shikra (lat: Tachyspiza badia)

`include "constants.v"
`include "decoder.v"
`include "register_file.v"
`include "next_PC_generator.v"
`include "alu.v"
`include "hazard_solver.v"

`define MEMSIZE_BUS_WIDTH `select_mem_size_bitcnt

module cpu(
    input wire clk,
    input wire global_reset,
    output wire [`XLEN:1] program_mem_address,
    input wire [`IWIDTH:1] instruction,
    input wire program_mem_ready,
    output wire [`XLEN:1] data_mem_address,
    output wire [`XLEN:1] data_mem_stored_data,
    output wire [`MEMSIZE_BUS_WIDTH:1] mem_data_size,
    input wire [`XLEN:1] data_mem_ready
);

    wire [`XLEN:1] rs1_fd, rs2_fd, imm_fd, arg1_fd, arg2_fd;
    reg [`XLEN:1] rs2_ex, rs2_wb, arg1_ex, arg2_ex;

    wire [`REG_SELECT_WIDTH:1] rs1_addr_fd, rs2_addr_fd, rd_addr_fd;
    reg [`REG_SELECT_WIDTH:1] rd_addr_ex, rd_addr_wb;

    wire [`CONTROL_BUS_WIDTH:1] control_bus_fd;
    reg [`CONTROL_BUS_WIDTH:1] control_bus_ex, control_bus_wb;

    wire do_branch_fd;

    /// Hazard solver wires
    wire is_no_writeback_ex, is_no_writeback_wb,
        is_jump_ex, is_jump_wb,
        is_mem_load_op_ex, is_mem_load_op_wb;

    wire stage_enable_fd, stage_enable_ex, stage_enable_wb,
        stage_fd_override_rs1_with_rdwb, stage_fd_override_rs2_with_rdwb,
        stage_fd_override_rs1_with_rdex, stage_fd_override_rs2_with_rdex;

    hazard_solver hazard_solver_instance (
        // Input buses
        .rs1_addr_fd(rs1_addr_fd),  .rs2_addr_fd(rs2_addr_fd),
        .rd_addr_ex(rd_addr_ex),    .rd_addr_wb(rd_addr_wb),
        // Input wires
        .is_no_writeback_ex(is_no_writeback_ex),
        .is_no_writeback_wb(is_no_writeback_wb),
        .is_jump_ex(is_jump_ex),
        .is_jump_wb(is_jump_wb),
        .is_prog_mem_ready(program_mem_ready),
        .is_data_mem_ready(data_mem_ready),
        .is_mem_load_op_ex(is_mem_load_op_ex),
        .is_mem_load_op_wb(is_mem_load_op_wb),
        // Output wires
        .stage_enable_fd(stage_enable_fd),
        .stage_enable_ex(stage_enable_ex),
        .stage_enable_wb(stage_enable_wb),
        .stage_fd_override_rs1_with_rdwb(stage_fd_override_rs1_with_rdwb),
        .stage_fd_override_rs2_with_rdwb(stage_fd_override_rs2_with_rdwb),
        .stage_fd_override_rs1_with_rdex(stage_fd_override_rs1_with_rdex),
        .stage_fd_override_rs2_with_rdex(stage_fd_override_rs2_with_rdex)
    );

    // next PC value generation
    wire [`XLEN:1] next_PC_fd;
    reg [`XLEN:1] next_PC_ex, next_PC_wb;
    next_PC_generator next_PC_generator_instance (
        .current_PC         (PC),
        .rs1                (rs1_fd),
        .imm                (imm_fd),
        .is_JALR            (control_bus_fd[`is_JALR]),
        .do_jump_or_branch  (control_bus_fd[`do_jump]|),
        .next_PC (next_PC_fd)
    );
    reg [`XLEN:1] PC;
    assign program_mem_address = PC;
    // End of PC stuff

    decoder rv_decoder (
        .instruction (),
        .rs1_addr (rs1_addr_fd),
        .rs2_addr (rs2_addr_fd),
        .rd_addr (rd_addr_fd),
        .control_bus (control_bus_fd),
        .imm (imm_fd)
    );


brancher rv_brancher (
    .select_flag (control_bus_fd[`select_flag_start+`select_flag_bitcnt-1:`select_flag_start]),
    .rs1 (rs1_fd),
    .rs2 (rs2_fd),
    .do_test_branch (control_bus_fd[`do_test_branch]),
    .do_branch (do_branch_fd)
);

    always @(posedge clk) begin
        if (global_reset) begin
            PC <= 0;
        end
        else begin
            if (stage_enable_fd) begin
                PC <= next_PC_fd;
            end
            if (stage_enable_ex) begin
                control_bus_ex <= control_bus_fd;
                next_PC_ex <= next_PC_fd;
            end
            if (stage_enable_wb) begin
                control_bus_wb <= control_bus_ex;
                next_PC_wb <= next_PC_ex;
            end
        end
    end

endmodule
