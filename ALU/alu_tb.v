// Testbench for the ALU of the CPU
// Created:     2024-01-18
// Modified:    2024-01-28
// Author:      Kagan Dikmen

`include "alu.v"

`timescale 1ns/1ps

module alu_tb 
    #(
    parameter TB_OPD_LENGTH = 8
    )(
    );

    reg [TB_OPD_LENGTH-1:0] opd1_t, opd2_t, opd3_t, opd4_t;
    reg alu_mux1_select_t;
    reg [1:0] alu_mux2_select_t;
    reg [3:0] alu_op_select_t;
    wire [TB_OPD_LENGTH-1:0] alu_result_t, comp_result_t;


    alu #(.OPERAND_LENGTH(TB_OPD_LENGTH)) 
            alu_test (
                    .opd1(opd1_t),
                    .opd2(opd2_t),
                    .opd3(opd3_t),
                    .opd4(opd4_t),
                    .alu_mux1_select(alu_mux1_select_t),
                    .alu_mux2_select(alu_mux2_select_t),
                    .alu_op_select(alu_op_select_t),
                    .alu_result(alu_result_t),
                    .comp_result(comp_result_t)
                    );


    initial
    begin

        // Testing the adder

        #5;
        opd1_t <= 'b0;
        opd2_t <= 'b0;
        opd3_t <= 'b0;
        opd4_t <= 'b0;
        alu_mux1_select_t <= 1'b0;
        alu_mux2_select_t <= 2'b00;     // adder result
        alu_op_select_t <= 4'b0000;     // adder: addition

        #5;
        opd1_t <= 'd3;
        opd2_t <= 'd8;
        opd3_t <= 'b0;
        opd4_t <= 'b0;
        alu_mux1_select_t <= 1'b0;
        alu_mux2_select_t <= 2'b00;     // adder result
        alu_op_select_t <= 4'b0000;     // adder: addition
        
        #5;
        opd1_t <= 'd10;
        opd2_t <= 'd8;
        opd3_t <= 'b0;
        opd4_t <= 'b0;
        alu_mux1_select_t <= 1'b0;
        alu_mux2_select_t <= 2'b00;     // adder result
        alu_op_select_t <= 4'b1000;     // adder: subtraction

        #5;
        opd1_t <= 'd10;
        opd2_t <= 'd12;
        opd3_t <= 'b0;
        opd4_t <= 'b0;
        alu_mux1_select_t <= 1'b0;
        alu_mux2_select_t <= 2'b00;     // adder result
        alu_op_select_t <= 4'b1000;     // adder: subtraction

        #5;
        opd1_t <= 'hff;
        opd2_t <= 'hfe;

        #5;
        opd1_t <= 'hfe;
        opd2_t <= 'hff;

        #5;
        alu_op_select_t <= 4'b0000;     // adder: addition

        #5;
        opd1_t <= 'hff;
        opd2_t <= 'hfe;

        #5;
        opd1_t <= 'b0;
        opd2_t <= 'b0;
        opd3_t <= 'b0;
        opd4_t <= 'b0;
        alu_mux1_select_t <= 1'b0;
        alu_mux2_select_t <= 2'b00;     // adder result
        alu_op_select_t <= 4'b0000;     // adder: addition

        
        // Testing the logic unit

        #5;
        opd1_t <= 'b0;
        opd2_t <= 'b0;
        alu_mux1_select_t <= 1'b0;
        alu_mux2_select_t <= 2'b01;     // logic unit result
        alu_op_select_t <= 4'b0000;     // logic_unit: ~opd1

        #5;
        opd1_t <= 'hcc;
        opd2_t <= 'hff;
        alu_mux1_select_t <= 1'b0;
        alu_op_select_t <= 4'b0000;     // logic_unit: ~opd1

        #5;
        alu_mux1_select_t <= 1'b0;
        alu_op_select_t <= 4'b0001;     // logic_unit: ~opd2

        #5;
        alu_mux1_select_t <= 1'b0;
        alu_op_select_t <= 4'b0111;     // logic_unit: AND

        #5;
        alu_mux1_select_t <= 1'b0;
        alu_op_select_t <= 4'b0110;     // logic_unit: OR

        #5;
        alu_mux1_select_t <= 1'b0;
        alu_op_select_t <= 4'b0100;     // logic_unit: XOR

        #5;
        opd1_t <= 'h0e;
        opd2_t <= 'ha0;
        alu_mux1_select_t <= 1'b0;
        alu_op_select_t <= 4'b0000;     // logic_unit: ~opd1

        #5;
        alu_mux1_select_t <= 1'b0;
        alu_op_select_t <= 4'b0001;     // logic_unit: ~opd2

        #5;
        alu_mux1_select_t <= 1'b0;
        alu_op_select_t <= 4'b0111;     // logic_unit: AND

        #5;
        alu_mux1_select_t <= 1'b0;
        alu_op_select_t <= 4'b0110;     // logic_unit: OR

        #5;
        alu_mux1_select_t <= 1'b0;
        alu_op_select_t <= 4'b0100;     // logic_unit: XOR

        #5;
        opd1_t <= 'b0;
        opd2_t <= 'b0;
        alu_mux1_select_t <= 1'b0;
        alu_op_select_t <= 4'b0000;     // logic_unit: ~opd1


        // Testing the shifter

        #5;
        opd1_t <= 8'b0;
        opd2_t <= 8'b0;
        alu_mux1_select_t <= 1'b0;
        alu_mux2_select_t <= 2'b10;     // shifter result
        alu_op_select_t <= 4'b0000;     // invalid op. for shifter

        #5;
        opd1_t <= 8'h0f;
        opd2_t <= 8'h03;
        alu_mux1_select_t <= 1'b0;
        alu_op_select_t <= 4'b0011;     // SLL/SLLI

        #5;
        opd1_t <= 8'h70;
        opd2_t <= 8'h03;
        alu_mux1_select_t <= 1'b0;
        alu_op_select_t <= 4'b0001;     // SRL/SRLI

        #5;
        opd1_t <= 8'h60;
        opd2_t <= 8'h03;
        alu_mux1_select_t <= 1'b0;
        alu_op_select_t <= 4'b0111;     // SRA/SRAI

        #5;
        opd1_t <= 8'h0f;
        opd2_t <= 8'h06;
        alu_mux1_select_t <= 1'b0;
        alu_op_select_t <= 4'b0011;     // SLL/SLLI

        #5;
        opd1_t <= 8'h70;
        opd2_t <= 8'h06;
        alu_mux1_select_t <= 1'b0;
        alu_op_select_t <= 4'b0001;     // SRL/SRLI

        #5;
        opd1_t <= 8'h60;
        opd2_t <= 8'h06;
        alu_mux1_select_t <= 1'b0;
        alu_op_select_t <= 4'b0111;     // SRA/SRAI

        #5;
        opd1_t <= 8'h0f;
        opd2_t <= 8'h00;
        alu_mux1_select_t <= 1'b0;
        alu_op_select_t <= 4'b0011;     // SLL/SLLI

        #5;
        opd1_t <= 8'hf0;
        opd2_t <= 8'h00;
        alu_mux1_select_t <= 1'b0;
        alu_op_select_t <= 4'b0001;     // SRL/SRLI

        #5;
        opd1_t <= 8'he0;
        opd2_t <= 8'h00;
        alu_mux1_select_t <= 1'b0;
        alu_op_select_t <= 4'b0111;     // SRA/SRAI

        #5;
        opd1_t <= 8'b0;
        opd2_t <= 8'b0;
        alu_mux1_select_t <= 1'b0;
        alu_op_select_t <= 4'b0000;     // invalid op. for shifter


        // Testing the comparison unit

        #5;
        opd1_t <= 8'b0;
        opd2_t <= 8'b0;
        opd3_t <= 8'b0;
        opd4_t <= 8'b0;
        alu_mux1_select_t <= 1'b0;      // select opd1 and opd2
        alu_mux2_select_t <= 2'b11;     // comparison unit result
        alu_op_select_t <= 4'b0000;     // IS_EQ

        #5;
        opd1_t <= 8'b0;
        opd2_t <= 8'b0;
        opd3_t <= 8'b0;
        opd4_t <= 8'b1;
        alu_mux1_select_t <= 1'b0;      // select opd1 and opd2
        alu_op_select_t <= 4'b0000;     // IS_EQ 

        #5;
        opd1_t <= 8'b0;
        opd2_t <= 8'b0;
        opd3_t <= 8'b0;
        opd4_t <= 8'b1;
        alu_mux1_select_t <= 1'b1;      // select opd3 and opd4
        alu_op_select_t <= 4'b0000;     // IS_EQ 

        #5;
        alu_op_select_t <= 4'b0001;     // IS_NE

        #5;
        alu_op_select_t <= 4'b0010;     // IS_GE

        #5;
        alu_op_select_t <= 4'b0110;     // IS_GEU

        #5;
        alu_op_select_t <= 4'b0011;     // IS_LT

        #5;
        alu_op_select_t <= 4'b0111;     // IS_LTU

        #5;
        opd3_t <= 8'hff;
        opd4_t <= 8'hfc;
        alu_op_select_t <= 4'b0000;     // IS_EQ

        #5;
        alu_op_select_t <= 4'b0001;     // IS_NE

        #5;
        alu_op_select_t <= 4'b0010;     // IS_GE

        #5;
        alu_op_select_t <= 4'b0110;     // IS_GEU

        #5;
        alu_op_select_t <= 4'b0011;     // IS_LT

        #5;
        alu_op_select_t <= 4'b0111;     // IS_LTU

        // some other combinations were tested in comparison_unit_tb.v


        // Testing complete

        #5;
        opd1_t <= 8'b0;
        opd2_t <= 8'b0;
        opd3_t <= 8'b0;
        opd4_t <= 8'b0;
        alu_mux1_select_t <= 1'b0;     // select opd1 and opd2
        alu_op_select_t <= 4'b0000;       
        

    end

endmodule