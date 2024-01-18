// Testbench for the logic unit of the ALU
// Created:     2024-01-18
// Modified:    2024-01-18
// Author:      Kagan Dikmen

`include "logic_unit.v"

`timescale 1ns/1ps

module logic_unit_tb
    #(parameter OPD_LENGTH = 8)();

    reg [OPD_LENGTH-1:0] opd1_t, opd2_t;
    reg [2:0] alu_op_select_t;
    wire [OPD_LENGTH-1:0] logic_result_t;

    logic_unit #(.OPD_LENGTH(OPD_LENGTH)) logic_unit_ut (
                                                            .opd1(opd1_t),
                                                            .opd2(opd2_t),
                                                            .alu_op_select(alu_op_select_t),
                                                                // 111 for AND, 110 for OR, 100 for XOR, 000 for ~opd1, 001 for ~opd2
                                                            .logic_result(logic_result_t)
                                                        );

    initial
    begin
        #5;
        opd1_t <= 'b0;
        opd2_t <= 'b0;
        alu_op_select_t <= 3'b000;

        #5;
        opd1_t <= 'hcc;
        opd2_t <= 'hff;
        alu_op_select_t <= 3'b000;

        #5;
        alu_op_select_t <= 3'b001;

        #5;
        alu_op_select_t <= 3'b111;

        #5;
        alu_op_select_t <= 3'b110;

        #5;
        alu_op_select_t <= 3'b100;

        #5;
        opd1_t <= 'h0e;
        opd2_t <= 'ha0;
        alu_op_select_t <= 3'b000;

        #5;
        alu_op_select_t <= 3'b001;

        #5;
        alu_op_select_t <= 3'b111;

        #5;
        alu_op_select_t <= 3'b110;

        #5;
        alu_op_select_t <= 3'b100;

        #5;
        opd1_t <= 'b0;
        opd2_t <= 'b0;
        alu_op_select_t <= 3'b000;
    end
    
endmodule