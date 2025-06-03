// PC Counter of the CPU
// Created:     2024-01-25
// Modified:    2025-06-03
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
    output [OPD_WIDTH-1:0] next_pc
    );

    reg [OPD_WIDTH:0] pc;
    reg rst_buff;

    always @(posedge clk)
    begin
        if (rst)
            pc <= 32'b0;
        else
            pc <= next_pc;
        
        rst_buff <= rst;
    end

    assign next_pc = (rst || rst_buff) ? 32'b0 :
                     csr_sel ? csr_out :
                     ((branch && comp_result == 'b1) || jump) ? alu_result :
                     pc + 4;
    assign pc_out = pc;
    assign pc_plus4 = pc + 4;

endmodule