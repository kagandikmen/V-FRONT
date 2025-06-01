// PC Counter of the CPU
// Created:     2024-01-25
// Modified:    2025-06-01
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
    input csr_sel,
    input [OPD_WIDTH-1:0] alu_result,
    input [OPD_WIDTH-1:0] comp_result,
    input [OPD_WIDTH-1:0] csr_out,

    output [OPD_WIDTH-1:0] pc_out,
    output [OPD_WIDTH-1:0] pc_plus4,
    output [PC_WIDTH-1:0] next_pc
    );

    reg [31:0] pc;
    reg rst_buff;

    reg branch_buff, jump_buff, csr_sel_buff;

    always @(posedge clk)
    begin
        if (rst == 1'b1)
            pc <= 32'b0;
        else
            pc <= next_pc;
        
        rst_buff <= rst;
    end

    assign next_pc = (rst == 1'b1 || rst_buff == 1'b1) ? 32'b0 :
                     (csr_sel == 1'b1) ? csr_out :
                     ((branch == 1'b1 && comp_result == 'b1) || jump == 1'b1) ? alu_result :
                     pc + 4;
    assign pc_out = pc;
    assign pc_plus4 = pc + 4;

endmodule