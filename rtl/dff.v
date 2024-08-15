// D Flip-Flop
// Created:     2024-08-12
// Modified:    2024-08-12 (last status: working fine)
// Author:      Kagan Dikmen

module d_flip_flop
    (
        input clk,
        input in,
        output reg out
    );

    always @(posedge clk)
        out <= in;

endmodule