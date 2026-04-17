// Copyright 2024-2025 Fe-Ti aka Tim Kravchenko
//
// Next PC value generator
// Version:  1
// Codename: Shikra (lat: Tachyspiza badia)

`include "constants.v"

module next_PC_generator(
    input wire [`XLEN:1] current_PC,
    input wire [`XLEN:1] rs1,
    input wire [`XLEN:1] imm,
    input wire is_JALR,
    input wire do_jump_or_branch,
    output wire [`XLEN:1] next_PC
);
    wire [`XLEN:1] step = do_jump_or_branch ? imm : 0x04;
    wire [`XLEN:1] source_address = is_JALR ? rs1 : current_PC;
    assign next_PC = source_address + step;
endmodule
