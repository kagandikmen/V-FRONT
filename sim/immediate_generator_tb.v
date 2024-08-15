// testbench for the immediate generator of the CPU
// Created:     2024-01-28
// Modified:    2024-08-15
// Author:      Kagan Dikmen

`include "../rtl/immediate_generator.v"

`timescale 1ns/1ps

module immediate_generator_tb
    (
    );

    `include "../lib/common_library.vh"
    `include "../lib/instr_generator.vh"

    reg [31:0] instr;
    wire [31:0] imm;

    immediate_generator immediate_generator_ut
        (
            .instr(instr),
            .imm(imm)
        );
    
    initial
    begin
        
        instr <= r_instr(FUNCT3_ADD, FUNCT7_ADD, 5'd2, 5'd3, 5'd4);
        #5;
        instr <= i_instr(FUNCT3_ADDI, 5'd2, 5'd3, 12'd4);
        #5;
        instr <= load_instr(FUNCT3_LW, 5'd3, 12'd8, 5'd4);
        #5; 
        instr <= s_instr(FUNCT3_SW, 5'd4, 12'd12, 5'd3);
        #5;
        instr <= b_instr(FUNCT3_BGE, 'd3, 'd4, 'd12);
        #5;
        instr <= jal_instr('d3, 'd80);
        #5;
        instr <= jalr_instr('d3, 'd4, 'd120);
        #5;
        instr <= lui_instr('d10, 'd2);
        #5;
        instr <= auipc_instr('d15, 'd2);
        #5;
        instr <= 32'b0;
    end

endmodule