// Testbench for the instruction decoder of the CPU
// Created:     2024-01-20
// Modified:    2024-01-25
// Author:      Kagan Dikmen

`include "instruction_decoder.v"

`timescale 1ns/1ps

module instruction_decoder_tb
    #(
    parameter OPD_LENGTH = 16,
    parameter PC_WIDTH = 8,
    parameter REG_WIDTH = 16
    )(
    );

    `include "common_library.vh"

    reg [31:0] instr_t;
    reg [PC_WIDTH-1:0] pc_t;

    wire [4:0] rs1_addr_t, rs2_addr_t, rd_addr_t;
    reg [REG_WIDTH-1:0] rs1_data_t, rs2_data_t;

    wire [OPD_LENGTH-1:0] opd1_t, opd2_t, opd3_t, opd4_t;


    instruction_decoder #(.OPD_LENGTH(OPD_LENGTH), .PC_WIDTH(PC_WIDTH), .REG_WIDTH(REG_WIDTH))
                        instruction_decoder_ut
                        (
                            .instr(instr_t),
                            .pc(pc_t),
                            .rs1_addr(rs1_addr_t),
                            .rs2_addr(rs2_addr_t),
                            .rd_addr(rd_addr_t),
                            .rs1_data(rs1_data_t),
                            .rs2_data(rs2_data_t),
                            .opd1(opd1_t),
                            .opd2(opd2_t),
                            .opd3(opd3_t),
                            .opd4(opd4_t)
                        );

    initial
    begin

        #5;
        instr_t <= {7'b0, 5'd4, 5'd3, 3'b0, 5'd2, R_OPCODE};            // ADD x2, x3, x4
        pc_t <= 'd16;
        rs1_data_t <= 'd9;
        rs2_data_t <= 'd13;

        #5;
        instr_t <= {7'b0, 5'd5, 5'd3, 3'b0, 5'd2, R_OPCODE};            // ADD x2, x3, x5

        #5;
        instr_t <= {12'd4, 5'd3, 3'b0, 5'd2, I_OPCODE};                 // ADDI x2, x3, 4

        #5;
        instr_t <= {12'd8, 5'd4, FUNCT3_LW, 5'd3, LOAD_OPCODE};         // LW x3 8(x4)

        #5;
        instr_t <= {7'b0, 5'd3, 5'd4, FUNCT3_SW, 5'd12, S_OPCODE};      // SW x4 12(x3)

        #5;
        instr_t <= {7'b0, 5'd4, 5'd3, FUNCT3_BGE, 5'b01100, B_OPCODE};  // BGE x3 x4 12

        #5;
        instr_t <= {1'b0, 10'd40, 1'b0, 8'b0, 5'd3, JAL_OPCODE};        // JAL x3, 80

        #5;
        instr_t <= {12'd120, 5'd4, FUNCT3_JALR, 5'd3, JALR_OPCODE};     // JALR x3 x4 120

        #5;
        instr_t <= {20'd2, 5'd10, LUI_OPCODE};                          // LUI x10 2

        #5;
        instr_t <= {20'd2, 5'd15, AUIPC_OPCODE};                        // AUIPC x15 2

        #5;
        instr_t <= 32'b0;                                               // Invalid Operation
    end

endmodule