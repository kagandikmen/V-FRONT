// Testbench for the shifter of the ALU
// Created:     2024-01-18
// Modified:    2024-01-18
// Author:      Kagan Dikmen

`include "shifter.v"

`timescale 1ns/1ps

module shifter_tb 
    #(
    parameter OPD_LENGTH = 8
    )(
    );

    reg [OPD_LENGTH-1:0] opd1_t, opd2_t;
    reg [2:0] alu_op_select_t;
    wire [OPD_LENGTH-1:0] shifter_result_t;

    shifter #(.OPD_LENGTH(OPD_LENGTH)) shifter_ut (
                                                    .opd1(opd1_t),
                                                    .opd2(opd2_t),
                                                    .alu_op_select(alu_op_select_t),
                                                        // 001 for SRL/SRLI, 011 for SLL/SLLI, 111 for SRA/SRAI
                                                    .shifter_result(shifter_result_t)
                                                    );

    initial
    begin
        
        #5;
        opd1_t <= 8'b0;
        opd2_t <= 8'b0;
        alu_op_select_t <= 3'b000;      // invalid op. for shifter


        // opd2 positive

        #5;
        opd1_t <= 8'h0f;
        opd2_t <= 8'h03;
        alu_op_select_t <= 3'b011;      // SLL/SLLI

        #5;
        opd1_t <= 8'hf0;
        opd2_t <= 8'h03;
        alu_op_select_t <= 3'b001;      // SRL/SRLI

        #5;
        opd1_t <= 8'he0;
        opd2_t <= 8'h03;
        alu_op_select_t <= 3'b111;      // SRA/SRAI


        // opd2 = 0

        #5;
        opd1_t <= 8'h0f;
        opd2_t <= 8'h00;
        alu_op_select_t <= 3'b011;      // SLL/SLLI

        #5;
        opd1_t <= 8'hf0;
        opd2_t <= 8'h00;
        alu_op_select_t <= 3'b001;      // SRL/SRLI

        #5;
        opd1_t <= 8'he0;
        opd2_t <= 8'h00;
        alu_op_select_t <= 3'b111;      // SRA/SRAI


        // Testing complete

        #5;
        opd1_t <= 8'b0;
        opd2_t <= 8'b0;
        alu_op_select_t <= 3'b000;      // invalid op. for shifter

    end 

endmodule