// Testbench for the control unit of the CPU
// Created:     2024-01-25
// Modified:    2024-01-26
// Author:      Kagan Dikmen

`include "control_unit.v"

`timescale 1ns/1ps

module control_unit_tb
    (
    );

    reg [31:0] instr;
    wire clk, alu_mux1_select, alu_pc_select, w_en_rf, w_en_pmem, wr_en_dmem, branch, jump;
    wire [1:0] alu_mux2_select, rf_w_select, rw_mode;
    wire [2:0] alu_op_select;

    control_unit control_unit_ut
                    (
                        .instr(instr),
                        .clk(clk),
                        .rf_w_select(rf_w_select),
                        .alu_mux1_select(alu_mux1_select),
                        .alu_mux2_select(alu_mux2_select),
                        .alu_op_select(alu_op_select),
                        .alu_pc_select(alu_pc_select),
                        .w_en_rf(w_en_rf),
                        .w_en_pmem(w_en_pmem),
                        .wr_en_dmem(wr_en_dmem),
                        .rw_mode(rw_mode),
                        .branch(branch),
                        .jump(jump)
                    );

    `include "common_library.vh"

    initial
    begin

        #25;
        instr <= {7'b0, 5'd4, 5'd3, 3'b0, 5'd2, R_OPCODE};            // ADD x2, x3, x4

        #25;
        instr <= {7'b0, 5'd5, 5'd3, 3'b0, 5'd2, R_OPCODE};            // ADD x2, x3, x5

        #25;
        instr <= {12'd4, 5'd3, 3'b0, 5'd2, I_OPCODE};                 // ADDI x2, x3, 4

        #25;
        instr <= {12'd8, 5'd4, FUNCT3_LW, 5'd3, LOAD_OPCODE};         // LW x3 8(x4)

        #25;
        instr <= {7'b0, 5'd3, 5'd4, FUNCT3_SW, 5'd12, S_OPCODE};      // SW x4 12(x3)

        #25;
        instr <= {7'b0, 5'd4, 5'd3, FUNCT3_BGE, 5'b01100, B_OPCODE};  // BGE x3 x4 12

        #25;
        instr <= {1'b0, 10'd40, 1'b0, 8'b0, 5'd3, JAL_OPCODE};        // JAL x3, 80

        #25;
        instr <= {12'd120, 5'd4, FUNCT3_JALR, 5'd3, JALR_OPCODE};     // JALR x3 x4 120

        #25;
        instr <= {20'd2, 5'd10, LUI_OPCODE};                          // LUI x10 2

        #25;
        instr <= {20'd2, 5'd15, AUIPC_OPCODE};                        // AUIPC x15 2

        #25;
        instr <= 32'b0;                                               // Invalid Operation
    end

endmodule