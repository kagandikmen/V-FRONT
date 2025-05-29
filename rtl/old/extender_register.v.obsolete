// Extender Register
// Created:     2024-08-12
// Modified:    2024-08-15 (last status: working fine)
// Author:      Kagan Dikmen

// Not used in the current design

`include "./dff.v"

module extender_register
    #(
        parameter INPUT_WIDTH = 12,
        parameter OUTPUT_WIDTH = 32
    )(
        input clk,
        input [INPUT_WIDTH-1:0] in,
        output [OUTPUT_WIDTH-1:0] out
    );

    genvar i;

    generate
        for(i=0; i<OUTPUT_WIDTH; i=i+1)
        begin
            if(i<INPUT_WIDTH)
                d_flip_flop dff (.clk(clk), .in(in[i]), .out(out[i]));
            else
                d_flip_flop dff (.clk(clk), .in(1'b0), .out(out[i]));
        end
    endgenerate


endmodule