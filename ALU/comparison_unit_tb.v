// Testbench for the comparison unit of the ALU
// Created:     2024-01-18
// Modified:    2024-01-27
// Author:      Kagan Dikmen

`include "comparison_unit.v"

`timescale 1ns/1ps

module comparison_unit_tb
    #(
    parameter OPD_LENGTH = 8
    )(
    );

    reg [OPD_LENGTH-1:0] opd1_t, opd2_t;
    reg [3:0] alu_op_select_t;
    wire [OPD_LENGTH-1:0] comp_result_t;

    comparison_unit #(.OPD_LENGTH(OPD_LENGTH)) comparison_unit_ut (
                                                                    .opd1(opd1_t),
                                                                    .opd2(opd2_t),
                                                                    .alu_op_select(alu_op_select_t),
                                                                        // 000 for IS_EQ, 001 for IS_NE, 
                                                                        // 010 for IS_GE, 110 for IS_GEU,
                                                                        // 011 for IS_LT, 111 for IS_LTU
                                                                    .comp_result(comp_result_t)
                                                                    );

    initial
    begin

        opd1_t <= 8'd0;
        opd2_t <= 8'd0;
        alu_op_select_t <= 4'b0000;      // IS_EQ

        #5;
        alu_op_select_t <= 4'b0001;      // IS_NE

        #5;
        alu_op_select_t <= 4'b0010;      // IS_GE

        #5;
        alu_op_select_t <= 4'b0110;      // IS_GEU

        #5;
        alu_op_select_t <= 4'b0011;      // IS_LT

        #5;
        alu_op_select_t <= 4'b0111;      // IS_LTU
        
        // -----------------------------------------------

        #5;
        opd1_t <= 8'd1;
        opd2_t <= 8'd0;
        alu_op_select_t <= 4'b0000;      // IS_EQ

        #5;
        alu_op_select_t <= 4'b0001;      // IS_NE

        #5;
        alu_op_select_t <= 4'b0010;      // IS_GE

        #5;
        alu_op_select_t <= 4'b0110;      // IS_GEU

        #5;
        alu_op_select_t <= 4'b0011;      // IS_LT

        #5;
        alu_op_select_t <= 4'b0111;      // IS_LTU

        // -----------------------------------------------
        
        #5;
        opd1_t <= 8'hff;
        opd2_t <= 8'hff;
        alu_op_select_t <= 4'b0000;      // IS_EQ

        #5;
        alu_op_select_t <= 4'b0001;      // IS_NE

        #5;
        alu_op_select_t <= 4'b0010;      // IS_GE

        #5;
        alu_op_select_t <= 4'b0110;      // IS_GEU

        #5;
        alu_op_select_t <= 4'b0011;      // IS_LT

        #5;
        alu_op_select_t <= 4'b0111;      // IS_LTU

        // -----------------------------------------------
        
        #5;
        opd1_t <= 8'hff;
        opd2_t <= 8'hfe;
        alu_op_select_t <= 4'b0000;      // IS_EQ

        #5;
        alu_op_select_t <= 4'b0001;      // IS_NE

        #5;
        alu_op_select_t <= 4'b0010;      // IS_GE

        #5;
        alu_op_select_t <= 4'b0110;      // IS_GEU

        #5;
        alu_op_select_t <= 4'b0011;      // IS_LT

        #5;
        alu_op_select_t <= 4'b0111;      // IS_LTU

        // ---------------Testing complete----------------

        #5;
        opd1_t <= 8'd0;
        opd2_t <= 8'd0;
        alu_op_select_t <= 4'b0000;      // IS_EQ

    end
endmodule