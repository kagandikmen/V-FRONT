// Clock inverter of the CPU
// Created:     2024-08-12
// Modified:    2024-08-15 (status: working fine)
// Author:      Kagan Dikmen

// Not used in the current design

module clock_inverter
    (
        input clk,
        output clk_inv
    );

    assign clk_inv = ~clk;

endmodule