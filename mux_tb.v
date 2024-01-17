// Testbench for the 2-input and 4-input multiplexers
// Created:     2024-01-17
// Modified:    2024-01-17
// Author:      Kagan Dikmen

`include "mux.v"

module mux_tb
    ();

    reg [7:0] a_t;
    reg [7:0] b_t;
    reg [7:0] c_t;
    reg [7:0] d_t;
    reg sel1_t;
    reg [1:0] sel2_t;
    
    wire [7:0] z1_t;
    wire [7:0] z2_t;

    two_input_mux #(.INPUT_LENGTH(8)) mux_1_test (.a(a_t), .b(b_t), .sel(sel1_t), .z(z1_t));

    four_input_mux #(.INPUT_LENGTH(8)) mux_2_test (.a(a_t), .b(b_t), .c(c_t), .d(d_t), .sel(sel2_t), .z(z2_t));

    initial
    begin
        #5;
        a_t <= 8'h03;
        b_t <= 8'hff;
        c_t <= 8'h0f;
        d_t <= 8'hee;
        sel1_t <= 1'd0;
        sel2_t <= 2'd3;

        #5;
        sel1_t <= 1'd1;
        sel2_t <= 2'd2;

        #5;
        sel2_t <= 2'd1;

        #5;
        sel2_t <= 2'd0;

        #5;
        a_t <= 8'h00;
        b_t <= 8'h0f;
        c_t <= 8'hf0;
        d_t <= 8'h00;
        sel1_t <= 1'd0;
        sel2_t <= 2'd2;

        #5;
        sel1_t <= 1'd1;
        sel2_t <= 2'd3;

        #5;
        sel2_t <= 2'd1;

        #5;
        sel1_t <= 1'd0;
        sel2_t <= 2'd0;

        #5;
        sel2_t <= 2'd3;
    end


endmodule