// 2-input and 4-input multiplexers
// Created:     2024-01-17
// Modified:    2025-05-30
// Author:      Kagan Dikmen

`ifndef DEFINES_MUX
`define DEFINES_MUX

module two_input_mux
    #(
    parameter INPUT_LENGTH = 32
    )(
    input [INPUT_LENGTH-1:0] a,
    input [INPUT_LENGTH-1:0] b,
    input sel,
    output [INPUT_LENGTH-1:0] z
    );

    assign z = (sel == 1'b0) ? a : b;

endmodule

module four_input_mux
    #(
    parameter INPUT_LENGTH = 32
    )(
    input [INPUT_LENGTH-1:0] a,
    input [INPUT_LENGTH-1:0] b,
    input [INPUT_LENGTH-1:0] c,
    input [INPUT_LENGTH-1:0] d,
    input [1:0] sel,
    output [INPUT_LENGTH-1:0] z
    );

    assign z = (sel == 2'b00) ? a : (sel == 2'b01) ? b : (sel == 2'b10) ? c : d;

endmodule

`endif