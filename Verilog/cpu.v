// Copyright 2024-2026 Fe-Ti aka Tim Kravchenko
//
// Main CPU module
// Version:  1
// Codename: Shikra (lat: Tachyspiza badia)

// IDK what this is :)
`timescale 1ns/1ns
`include "constants.v"
`include "decoder.v"
`include "brancher.v"
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
    output wire [`MEMSIZE_BUS_WIDTH:1] data_mem_cmd_datasize,
    output wire data_mem_cmd_read, data_mem_cmd_write,
    mem_sync_cache_instruction, mem_sync_cache_data,
    input wire [`XLEN:1] data_mem_loaded_data,
    input wire data_mem_ready
);
    /// PC wires
    wire [`XLEN:1] next_PC_fd;
    reg [`XLEN:1] next_PC_ex, next_PC_wb;
    reg [`XLEN:1] PC;
    ///

    /// Data and control buses
    wire [`XLEN:1] rs1_fd, rs2_fd, imm_fd, arg1_fd, arg2_fd, alu_result_ex, rd_wb;
    reg [`XLEN:1] rs2_ex, rs2_wb, arg1_ex, arg2_ex, alu_result_wb;

    wire [`REG_SELECT_WIDTH:1] rs1_addr_fd, rs2_addr_fd, rd_addr_fd;
    reg [`REG_SELECT_WIDTH:1] rd_addr_ex, rd_addr_wb;

    wire [`CONTROL_BUS_WIDTH:1] control_bus_fd;
    reg [`CONTROL_BUS_WIDTH:1] control_bus_ex, control_bus_wb;
    ///

    /// Misc wires
    wire do_branch_fd;
    ///

    /// Hazard solver wires and block instantination
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
        .is_no_writeback_ex(~control_bus_ex[`regfile_we]),
        .is_no_writeback_wb(~control_bus_wb[`regfile_we]),
        .is_jump_ex(control_bus_ex[`do_jump]),
        .is_jump_wb(control_bus_wb[`do_jump]),
        .is_prog_mem_ready(program_mem_ready),
        .is_data_mem_ready(data_mem_ready),
        .is_mem_load_op_ex(control_bus_ex[`mem_r]),
        .is_mem_load_op_wb(control_bus_wb[`mem_r]),
        // Output wires
        .stage_enable_fd(stage_enable_fd),
        .stage_enable_ex(stage_enable_ex),
        .stage_enable_wb(stage_enable_wb),
        .stage_fd_override_rs1_with_rdwb(stage_fd_override_rs1_with_rdwb),
        .stage_fd_override_rs2_with_rdwb(stage_fd_override_rs2_with_rdwb)//,
        // .stage_fd_override_rs1_with_rdex(stage_fd_override_rs1_with_rdex),
        // .stage_fd_override_rs2_with_rdex(stage_fd_override_rs2_with_rdex)
    );

    /// CPU blocks instances
    ///// Fetch-Decode stage
    // next PC value generation and Prog Mem address
    next_PC_generator next_PC_generator_instance (
        .current_PC         (PC),
        .rs1                (rs1_fd),
        .imm                (imm_fd),
        .is_JALR            (control_bus_fd[`is_JALR]),
        .do_jump_or_branch  (control_bus_fd[`do_jump] | do_branch_fd),
        .next_PC (next_PC_fd)
    );
    // Branching
    brancher rv_brancher (
        .select_flag (control_bus_fd[`select_flag_start+`select_flag_bitcnt-1:`select_flag_start]),
        .rs1 (rs1_fd),
        .rs2 (rs2_fd),
        .do_test_branch (control_bus_fd[`do_test_branch]),
        .do_branch (do_branch_fd)
    );
    assign program_mem_address = PC;

    /// Decoding part of Fetch-Decode stage
    decoder rv_decoder (
        .instruction (instruction),
        .rs1_addr (rs1_addr_fd),
        .rs2_addr (rs2_addr_fd),
        .rd_addr (rd_addr_fd),
        .control_bus (control_bus_fd),
        .imm (imm_fd)
    );
    // Argument fetch and select
    overrider_register_file rf_ovr (
        .rs1_addr (rs1_addr_fd),
        .rs2_addr (rs2_addr_fd),
        .rd_addr (rd_addr_wb),
        .input_data (rd_wb),
        .write_enable (control_bus_wb[`regfile_we]),
        .clk (clk),
        // 
        .fwd_wb_rd (rd_wb),
        // .fwd_ex_rd (fwd_ex_rd),
        .stage_fd_override_rs1_with_rdwb (stage_fd_override_rs1_with_rdwb),
        .stage_fd_override_rs2_with_rdwb (stage_fd_override_rs2_with_rdwb),
        // .stage_fd_override_rs1_with_rdex (stage_fd_override_rs1_with_rdex),
        // .stage_fd_override_rs2_with_rdex (stage_fd_override_rs2_with_rdex),
        .rs1 (rs1_fd),
        .rs2 (rs2_fd)
    );
    assign arg1_fd = control_bus_fd[`select_arg1] ? PC : rs1_fd;
    assign arg2_fd = control_bus_fd[`select_arg2] ? 
                        (control_bus_fd[`do_jump] ? `XLEN'd04 : imm_fd)
                        :
                        rs2_fd;

    ///// Execution stage
    alu alu_instance (
        .arg1 (arg1_ex),
        .arg2 (arg2_ex),
        .control_bus (control_bus_ex),
        .result (alu_result_ex)
    );

    ///// Writeback-mem stage
    assign data_mem_address = alu_result_wb;
    assign data_mem_stored_data = rs2_wb;
    assign data_mem_cmd_datasize = control_bus_wb[`select_mem_size_start+`select_mem_size_bitcnt-1:`select_mem_size_start];
    assign data_mem_cmd_read = control_bus_wb[`mem_r];
    assign data_mem_cmd_write = control_bus_wb[`mem_w];
    assign mem_sync_cache_instruction = control_bus_wb[`mem_sync_cache_instruction]; 
    assign mem_sync_cache_data = control_bus_wb[`mem_sync_cache_data];

    assign rd_wb = control_bus_wb[`mem_r] ? data_mem_loaded_data : alu_result_wb;

    /// Nopping constants for stage outputs
    // NOP constants
    // wire [:] nop_;
    wire [`REG_SELECT_WIDTH:1] nop_regsel = 0;
    wire [`CONTROL_BUS_WIDTH:1] nop_controlbus = 0;
    wire [`XLEN:1] nop_XLEN = 0;

    // Nopped signals
    wire [`CONTROL_BUS_WIDTH:1] nopped_control_bus_fd = stage_enable_fd? control_bus_fd : nop_controlbus;
    wire [`REG_SELECT_WIDTH:1] nopped_rd_addr_fd = stage_enable_fd? rd_addr_fd : nop_regsel;
    wire [`XLEN:1] nopped_arg1_fd = stage_enable_fd? arg1_fd : nop_XLEN;
    wire [`XLEN:1] nopped_arg2_fd = stage_enable_fd? arg2_fd : nop_XLEN;
    wire [`XLEN:1] nopped_rs2_fd = stage_enable_fd? rs2_fd : nop_XLEN;

    wire [`CONTROL_BUS_WIDTH:1] nopped_control_bus_ex = stage_enable_ex? control_bus_ex : nop_controlbus;
    wire [`REG_SELECT_WIDTH:1] nopped_rd_addr_ex = stage_enable_ex? rd_addr_ex : nop_regsel;
    wire [`XLEN:1] nopped_alu_result_ex = stage_enable_ex? alu_result_ex : nop_XLEN;
    wire [`XLEN:1] nopped_rs2_ex = stage_enable_ex? rs2_ex : nop_XLEN;

    always @(clk) begin
        $display("PC %h, next_PC_fd %h, do_test_branch %h, do_jump %h, do_branch %h", PC, next_PC_fd, control_bus_fd[`do_test_branch] , control_bus_fd[`do_jump] , do_branch_fd);
        $display("    rs1_fd %h, imm_fd %h,  rs1_ovr %b, rs1_addr_fd %h", rs1_fd, imm_fd, stage_fd_override_rs1_with_rdwb, rs1_addr_fd);
        $display("enable: FD=%b EX=%b WB=%b", stage_enable_fd,stage_enable_ex,stage_enable_wb);
        $display("nopped_rd_addr_fd %h, nopped_rd_addr_ex %h, rd_addr_wb %h", nopped_rd_addr_fd, nopped_rd_addr_ex, rd_addr_wb);
    end

    reg [`XLEN:1] PC_ex, PC_wb;

    /// Reg-Reg Transfer logic
    always @(posedge clk) begin
        if (global_reset) begin
            PC <= 0;
            rd_addr_ex <= 0;
            rd_addr_wb <= 0;
            control_bus_ex <= 0;
            control_bus_wb <= 0;
        end
        else begin
            if (stage_enable_fd) begin
                PC <= next_PC_fd;
            end
            if (stage_enable_ex) begin
                control_bus_ex <= nopped_control_bus_fd;
                arg1_ex <= nopped_arg1_fd;
                arg2_ex <= nopped_arg2_fd;
                rd_addr_ex <= nopped_rd_addr_fd;
                // May be ommitted I suppose, but for uniformity here it is
                rs2_ex <= nopped_rs2_fd;
                PC_ex <= PC;
            end
            if (stage_enable_wb) begin
                control_bus_wb <= nopped_control_bus_ex;
                alu_result_wb <= nopped_alu_result_ex;
                rd_addr_wb <= nopped_rd_addr_ex;
                rs2_wb <= nopped_rs2_ex;
                PC_wb <= PC_ex;
            end
        end
    end

endmodule
