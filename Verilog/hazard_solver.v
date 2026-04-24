// Copyright 2024-2026 Fe-Ti aka Tim Kravchenko
//
// Hazard solver module for 3-stage pipeline
// Version:  1
`include "constants.v"

module hazard_solver(
    input wire  [`REG_SELECT_WIDTH:1]   rs1_addr_fd, rs2_addr_fd,
                                        rd_addr_ex, rd_addr_wb,
    input wire  is_no_writeback_ex, is_no_writeback_wb,
                is_jump_ex, is_jump_wb,
                is_prog_mem_ready, is_data_mem_ready,
                is_mem_load_op_ex, is_mem_load_op_wb,
    output wire stage_enable_fd, stage_enable_ex, stage_enable_wb,
                stage_fd_override_rs1_with_rdwb, stage_fd_override_rs2_with_rdwb,
                stage_fd_override_rs1_with_rdex, stage_fd_override_rs2_with_rdex
);
    wire non_zero_rdex  = |rd_addr_ex;
    wire non_zero_rdwb  = |rd_addr_wb;
    wire reg_equal_rs1_rdex = non_zero_rdex & (rs1_addr_fd == rd_addr_ex);
    wire reg_equal_rs1_rdwb = non_zero_rdwb & (rs1_addr_fd == rd_addr_wb);
    wire reg_equal_rs2_rdex = non_zero_rdex & (rs2_addr_fd == rd_addr_ex);
    wire reg_equal_rs2_rdwb = non_zero_rdwb & (rs2_addr_fd == rd_addr_wb);

    // Can override only when:
    //      rs is equal to rd on WB stage AND it is not a mem load
    //      AND also rd on EX is not equal to any RS
    wire prohibit_rdwb_rs_override =
                                reg_equal_rs1_rdex |
                                reg_equal_rs2_rdex |
                                (is_mem_load_op_wb & (reg_equal_rs1_rdwb | reg_equal_rs2_rdwb));
    wire can_override_rs_with_rdwb = ~prohibit_rdwb_rs_override;
    // Plus one special case when jump is writing to register
    // and next instruction is reading it. Then we can override
    // rs value directly from EX stage
    assign stage_fd_override_rs1_with_rdex = is_jump_ex & reg_equal_rs1_rdex;
    assign stage_fd_override_rs2_with_rdex = is_jump_ex & reg_equal_rs2_rdex;

    assign stage_fd_override_rs1_with_rdwb = can_override_rs_with_rdwb & reg_equal_rs1_rdwb;
    assign stage_fd_override_rs2_with_rdwb = can_override_rs_with_rdwb & reg_equal_rs2_rdwb;

    wire can_override_rs = |{
        stage_fd_override_rs1_with_rdex,
        stage_fd_override_rs2_with_rdex,
        stage_fd_override_rs1_with_rdwb,
        stage_fd_override_rs2_with_rdwb
        };

    // RS-es are good when: none rs-rd pair are equal OR
    //                  equal, but (no writeback OR can override)
    wire some_rsrd_pair_equal = |{reg_equal_rs1_rdex, reg_equal_rs1_rdwb, reg_equal_rs2_rdex, reg_equal_rs2_rdwb};
    wire is_no_writeback =  is_no_writeback_ex | is_no_writeback_wb;

    wire rs_are_good = (~some_rsrd_pair_equal) | (some_rsrd_pair_equal & (can_override_rs | is_no_writeback));

    assign stage_enable_fd = is_prog_mem_ready & is_data_mem_ready & rs_are_good;
    assign stage_enable_ex = is_data_mem_ready;
    assign stage_enable_wb = is_data_mem_ready;
endmodule
