// ALU of the CPU
// Created:     2024-01-17
// Modified:    2024-01-17
// Author:      Kagan Dikmen

`include "adder.v"

module alu
    #(parameter OPERAND_LENGTH = 32)
    (
    input [OPERAND_LENGTH-1:0] opd1,
    input [OPERAND_LENGTH-1:0] opd2,
    input [OPERAND_LENGTH-1:0] opd3,
    input [OPERAND_LENGTH-1:0] opd4,
    input alu_mux1_select,
    input [1:0] alu_mux2_select,
    input [2:0] alu_op_select,    // 000 for addition, 001 for subtraction
    
    output [OPERAND_LENGTH-1:0] alu_result,
    output [OPERAND_LENGTH-1:0] comp_result   // zero-extended
    );

    wire [OPERAND_LENGTH-1:0] cu_first_opd;   // cu stands for "compare unit"
    wire [OPERAND_LENGTH-1:0] cu_second_opd;
    wire [OPERAND_LENGTH-1:0] cu_result;

    wire [OPERAND_LENGTH-1:0] adder_result;
    wire [OPERAND_LENGTH-1:0] logic_result;
    wire [OPERAND_LENGTH-1:0] shifter_result;


    adder #(.OPERAND_LENGTH(OPERAND_LENGTH)) adder_in_alu(
                                                        .opd1(opd1),
                                                        .opd2(opd2),
                                                        .alu_op_select(alu_op_select),
                                                        .adder_result(adder_result)
                                                        );



    assign cu_first_opd = (alu_mux1_select == 1'b0) ? opd1 : opd3;
    assign cu_second_opd = (alu_mux1_select == 1'b0) ? opd2 : opd4;

endmodule