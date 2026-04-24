// Copyright 2024-2026 Fe-Ti aka Tim Kravchenko
//
// Branch selector module
// Version:  1
// Codename: Shikra (lat: Tachyspiza badia)

`include "constants.v"

module brancher (
    input wire [`select_flag_bitcnt:1] select_flag,
    input wire [`XLEN:1] rs1, rs2,
    input wire do_test_branch,
    output wire do_branch
);
    reg do_branch_reg;
    assign do_branch = do_branch_reg;

    // Flag selector
    // func3 bits:
    // 2 1 0
    // | | |
    // | | +--> inverse ? yes : no
    // | +----> unsigned? yes : no
    // +------> cmp_fun ? lt  : eq
    always @(*) begin
        case (select_flag)
            0: do_branch_reg = (rs1==rs2);
            1: do_branch_reg = ~(rs1==rs2);
            2: do_branch_reg = (rs1==rs2); // BEQU === BEQ
            3: do_branch_reg = ~(rs1==rs2);
            4: do_branch_reg = ($signed(rs1) < $signed(rs2));
            5: do_branch_reg = ~($signed(rs1) < $signed(rs2));
            6: do_branch_reg = (rs1 < rs2);
            7: do_branch_reg = ~(rs1 < rs2);
        endcase
    end
endmodule
