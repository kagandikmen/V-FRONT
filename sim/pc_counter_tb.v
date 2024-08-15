// Testbench for the PC Counter of the CPU
// Created:     2024-01-25
// Modified:    2024-08-15
// Author:      Kagan Dikmen

`include "../rtl/pc_counter.v"

`timescale 1ns/1ps

module pc_counter_tb
    #(
    parameter OPD_WIDTH = 8,
    parameter PC_WIDTH = 8
    )(
    );

    reg clk_t, rst_t, branch_t, jump_t;
    reg [OPD_WIDTH-1:0] alu_result_t, comp_result_t;
    wire [PC_WIDTH-1:0] next_pc_t, pc_plus4_t;

    pc_counter #(.OPD_WIDTH(OPD_WIDTH), .PC_WIDTH(PC_WIDTH))
                pc_counter_ut
                (
                    .clk(clk_t),
                    .rst(rst_t),
                    .branch(branch_t),
                    .jump(jump_t),
                    .alu_result(alu_result_t),
                    .comp_result(comp_result_t),
                    .pc_plus4(pc_plus4_t),
                    .next_pc(next_pc_t)
                );

    always #2 clk_t = ~clk_t;

    initial
    begin
        
        clk_t <= 1'b0;
        rst_t <= 1'b0;
        branch_t <= 1'b0;
        jump_t <= 1'b0;
        alu_result_t <= 8'hee;
        comp_result_t <= 8'b0;

        // resetting
        #5;
        rst_t <= 1'b1;
        #5;
        rst_t <= 1'b0;


        #5;
        branch_t <= 1'b1;
        
        #5;
        comp_result_t <= 1'b1;
        
        #5;
        branch_t <= 1'b0;
        alu_result_t <= 'd48;

        #15;
        jump_t <= 1'b1;

        #5;
        jump_t <= 1'b0;


    end

endmodule