// PC Counter of the CPU
// Created:     2024-01-25
// Modified:    2024-01-27 (status: working fine)
// Author:      Kagan Dikmen

module pc_counter
    #(
    parameter OPD_WIDTH = 32,
    parameter PC_WIDTH = 12
    )(
    input clk,
    input rst,
    input branch,
    input jump,
    input [OPD_WIDTH-1:0] alu_result,
    input [OPD_WIDTH-1:0] comp_result,

    output reg [OPD_WIDTH-1:0] pc_plus4,
    output reg [PC_WIDTH-1:0] next_pc
    );

    `include "common_library.vh"

    always @(posedge clk)
    begin
        if (rst == 1'b1)
        begin
            next_pc <= 'b0;
            pc_plus4 <= 'd4;
        end
    end

    always @(negedge clk)
    begin
        if (rst != 1'b1)
        begin
            if ((branch == 1'b1 && comp_result == 'b1) || jump == 1'b1)
            begin
                next_pc <= alu_result;
                pc_plus4 <= next_pc + 4;
            end
            else
            begin
                next_pc <= next_pc + 4;
                pc_plus4 <= next_pc + 4;
            end
        end
    end

endmodule