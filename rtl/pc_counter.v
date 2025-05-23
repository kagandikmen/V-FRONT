// PC Counter of the CPU
// Created:     2024-01-25
// Modified:    2025-05-23
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

    output [OPD_WIDTH-1:0] pc_out,
    output [OPD_WIDTH-1:0] pc_plus4,
    output [PC_WIDTH-1:0] next_pc
    );

    reg [31:0] pc;
    reg rst_buff;
    wire [PC_WIDTH-1:0] next_pc_buffer;

    always @(posedge clk)
    begin
        rst_buff <= rst;
        if (rst == 1'b1 || rst_buff == 1'b1)
            pc <= 32'b0;
        else
            pc <= {'b0, next_pc_buffer};
    end

    assign next_pc_buffer = ((branch == 1'b1 && comp_result == 'b1) || jump == 1'b1) ? alu_result : pc + 4;
    assign next_pc = next_pc_buffer;
    assign pc_out = pc;
    assign pc_plus4 = pc + 4;

endmodule