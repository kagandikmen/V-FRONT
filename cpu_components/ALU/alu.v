// ALU of the CPU
// Created:     2024-01-17
// Modified:    2024-01-28 (last status: working fine)
// Author:      Kagan Dikmen

`include "../../common_components/adder.v"
`include "comparison_unit.v"
`include "logic_unit.v"
`include "../../common_components/mux.v"
`include "shifter.v"

module alu
    #(
    parameter OPERAND_LENGTH = 32
    )(
    input [OPERAND_LENGTH-1:0] opd1,
    input [OPERAND_LENGTH-1:0] opd2,
    input [OPERAND_LENGTH-1:0] opd3,
    input [OPERAND_LENGTH-1:0] opd4,
    input alu_mux1_select,
    input [1:0] alu_mux2_select,
    input [3:0] alu_op_select,
    
    output [OPERAND_LENGTH-1:0] alu_result,
    output [OPERAND_LENGTH-1:0] comp_result   // zero-extended
    );

    wire [OPERAND_LENGTH-1:0] adder_input1;
    wire [OPERAND_LENGTH-1:0] adder_result;
    
    wire [OPERAND_LENGTH-1:0] cu_input1;   // cu stands for "compare unit"
    wire [OPERAND_LENGTH-1:0] cu_input2;

    wire [OPERAND_LENGTH-1:0] logic_result;
    wire [OPERAND_LENGTH-1:0] shifter_result;


    adder #(.OPERAND_LENGTH(OPERAND_LENGTH)) 
                    adder_in_alu
                    (
                        .opd1(opd1),
                        .opd2(opd2),
                        .alu_op_select(alu_op_select),
                        .adder_result(adder_result)
                    );

    comparison_unit #(.OPD_LENGTH(OPERAND_LENGTH)) 
                    comparison_unit_in_alu 
                    (
                        .opd1(cu_input1),
                        .opd2(cu_input2),
                        .alu_op_select(alu_op_select),
                        .comp_result(comp_result)
                    );

    logic_unit #(.OPD_LENGTH(OPERAND_LENGTH)) 
                    logic_unit_in_alu 
                    (
                        .opd1(opd1),
                        .opd2(opd2),
                        .alu_op_select(alu_op_select),
                        .logic_result(logic_result)
                    );

    shifter #(.OPD_LENGTH(OPERAND_LENGTH)) 
                    shifter_in_alu 
                    (
                        .opd1(opd1),
                        .opd2(opd2),
                        .alu_op_select(alu_op_select),
                        .shifter_result(shifter_result)
                    );


    two_input_mux #(.INPUT_LENGTH(OPERAND_LENGTH)) 
                    cu_mux1
                    (
                        .a(opd1),
                        .b(opd3),
                        .sel(alu_mux1_select),
                        .z(cu_input1)
                    );

    two_input_mux #(.INPUT_LENGTH(OPERAND_LENGTH)) 
                    cu_mux2
                    (
                        .a(opd2),
                        .b(opd4),
                        .sel(alu_mux1_select),
                        .z(cu_input2)
                    );

    four_input_mux #(.INPUT_LENGTH(OPERAND_LENGTH))
                    result_mux
                    (
                        .a(adder_result),
                        .b(logic_result),
                        .c(shifter_result),
                        .d(comp_result),
                        .sel(alu_mux2_select),
                        .z(alu_result)
                    );
    
endmodule