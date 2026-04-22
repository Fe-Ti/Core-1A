// Copyright 2024-2026 Fe-Ti aka Tim Kravchenko
//
// Constants defenition
// Version:  1
// Codename: Shikra (lat: Tachyspiza badia)

`ifndef SHIKRA_CONSTANTS
`define SHIKRA_CONSTANTS 1

// Disable implicit net defenition
`default_nettype none

// IDK what this is :)
`timescale 1ns/1ns


// Register width
`define XLEN 64
// Instruction width
`define IWIDTH 32
// Register select width (log(gpr_count))
`define REG_SELECT_WIDTH 5


// Control bus pin definitions
//// arg1 ---> RS1 or PC
`define select_arg1 1
//// arg2 ---> RS2 or imm
`define select_arg2 2

`define do_test_branch 3
`define do_jump 4
`define is_JALR 5

`define mem_w 6
`define mem_r 7
`define select_mem_result `mem_r
`define mem_sync_cache_data 8
`define mem_sync_cache_instruction 9

`define select_rdd `do_jump
`define regfile_we 10

// Control subbuses definitions
`define select_mem_size_start 11
`define select_mem_size_bitcnt 3
`define select_flag_start `select_mem_size_start+`select_mem_size_bitcnt
`define select_flag_bitcnt 3
`define select_aluop_start `select_flag_start+`select_flag_bitcnt
`define select_aluop_bitcnt 10

// Calculate control bus total width
`define CONTROL_BUS_WIDTH `select_aluop_start+`select_aluop_bitcnt-1


`endif
