// Testbench for the adder unit for the adder of the ALU
// Created:     2024-01-17
// Modified:    2024-01-17
// Author:      Kagan Dikmen

`include "adder_unit.v"

`timescale 1ns/1ps

module adder_unit_tb
();

reg a_t;
reg b_t;
reg c_in_t;
wire out_t;
wire c_out_t;

adder_unit adder_unit_test (.a(a_t),
                            .b(b_t),
                            .c_in(c_in_t),
                            .out(out_t),
                            .c_out(c_out_t));


initial 
begin

    #10;
    a_t <= 1'b0;
    b_t <= 1'b0;
    c_in_t <= 1'b0;

    #10;
    a_t <= 1'b0;
    b_t <= 1'b1;
    c_in_t <= 1'b0;

    #10;
    a_t <= 1'b1;
    b_t <= 1'b1;
    c_in_t <= 1'b0;

    #10;
    a_t <= 1'b1;
    b_t <= 1'b0;
    c_in_t <= 1'b0;

    #10;
    a_t <= 1'b0;
    b_t <= 1'b0;
    c_in_t <= 1'b1;

    #10;
    a_t <= 1'b1;
    b_t <= 1'b1;
    c_in_t <= 1'b1;

    #10;
    a_t <= 1'b0;
    b_t <= 1'b0;
    c_in_t <= 1'b0;
end

endmodule