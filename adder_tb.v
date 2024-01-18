// Testbench for the adder of the ALU
// Created:     2024-01-17
// Modified:    2024-01-18
// Author:      Kagan Dikmen

`include "adder.v"

`timescale 1ns/1ps

module adder_tb
    ();

    reg [31:0] opd1_t;
    reg [31:0] opd2_t;
    reg [2:0] alu_op_select_t;

    wire [31:0] adder_result_t;

    adder #(.OPERAND_LENGTH(32)) adder_test (
                                            .opd1(opd1_t),
                                            .opd2(opd2_t),
                                            .alu_op_select(alu_op_select_t),
                                            .adder_result(adder_result_t)
                                            );
    
    initial
    begin
        
        #10;
        opd1_t <= 32'd0;
        opd2_t <= 32'd0;
        alu_op_select_t <= 3'b0;


        // positive operands

        #10;
        opd1_t <= 32'd0;
        opd2_t <= 32'd1;
        alu_op_select_t <= 3'b0;

        #10;
        opd1_t <= 32'd1;
        opd2_t <= 32'd5;
        alu_op_select_t <= 3'b0;

        #10;
        opd1_t <= 32'd6;
        opd2_t <= 32'd3;
        alu_op_select_t <= 3'b1;

        #10;
        opd1_t <= 32'd6;
        opd2_t <= 32'd4;
        alu_op_select_t <= 3'b1;

        #10;
        opd1_t <= 32'd6;
        opd2_t <= 32'd7;
        alu_op_select_t <= 3'b1;

        #10;
        opd1_t <= 32'd0;
        opd2_t <= 32'd0;
        alu_op_select_t <= 3'b0;


        // negative operands

        #10;
        opd1_t <= 32'hffffffff;
        opd2_t <= 32'hfffffffe;
        alu_op_select_t <= 3'b0;
        
        #10;
        opd1_t <= 32'hffffffff;
        opd2_t <= 32'hfffffffe;
        alu_op_select_t <= 3'd1;
        
        #10;
        opd1_t <= 32'hfffffffe;
        opd2_t <= 32'hffffffff;
        alu_op_select_t <= 3'd1;


        // testing complete

        #10;
        opd1_t <= 32'd0;
        opd2_t <= 32'd0;
        alu_op_select_t <= 3'b0;

    end



endmodule