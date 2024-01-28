// Testbench for the register file of the CPU
// Created:     2024-01-20
// Modified:    2024-01-27
// Author:      Kagan Dikmen

`include "register_file.v"

`timescale 1ns/1ps

module register_file_tb 
    #(
    parameter RF_ADDR_LEN = 5,
    parameter RF_DATA_LEN = 8
    )(
    );

    reg clk_t, rst_t, w_en_t;
    reg [RF_ADDR_LEN-1:0] rs1_addr_t, rs2_addr_t, rd_addr_t;
    wire [RF_DATA_LEN-1:0] rs1_data_t, rs2_data_t;
    reg [RF_DATA_LEN-1:0] rd_write_data_t;

    register_file #(.RF_ADDR_LEN(RF_ADDR_LEN), .RF_DATA_LEN(RF_DATA_LEN))
                    register_file_ut
                    (
                        .clk(clk_t),
                        .rst(rst_t),
                        .w_en(w_en_t),
                        .rs1_addr(rs1_addr_t),
                        .rs2_addr(rs2_addr_t),
                        .rd_addr(rd_addr_t),
                        .rs1_data(rs1_data_t),
                        .rs2_data(rs2_data_t),
                        .rd_write_data(rd_write_data_t)
                    );
    
    always #1 clk_t = ~clk_t;
    
    initial
    begin

        clk_t <= 1'b0;
        rst_t <= 1'b0;
        rs1_addr_t <= 'b0;
        rs2_addr_t <= 'b0;
        rd_addr_t <= 'b0;
        rd_write_data_t <= 'b0;
        w_en_t <= 1'b0;

        #5;
        rst_t <= 1'b1;

        #5;
        rst_t <= 1'b0;

        //testing read
        #5;
        rs1_addr_t <= 'd3;
        rs2_addr_t <= 'd5;

        #5;
        rs1_addr_t <= 'd6;
        rs2_addr_t <= 'd7;

        // testing write
        #5;
        rd_addr_t <= 'd8;
        rd_write_data_t <= 'd24;

        #5;
        w_en_t <= 1'b1;
        #5;
        rs1_addr_t <= 'd8;
        rs2_addr_t <= 'd8;

        #5;
        w_en_t <= 1'b0;
        #5;
        rs1_addr_t <= 'd2;
        rs2_addr_t <= 'd3;

        #5;

        #5;
        w_en_t <= 1'b1;
        rd_addr_t <= 'd1;
        rd_write_data_t <= 'd3;
        rs1_addr_t <= 'd1;

        #5;
        rd_addr_t <= 'd9;
        rd_write_data_t <= 'd27;

        #5;
        w_en_t <= 1'b0;

        // testing writing to x0

        #5;
        w_en_t <= 1'b1;
        rd_addr_t <= 'd0;
        rd_write_data_t <= 'd3;

        #5;
        rd_addr_t <= 'd10;
        rd_write_data_t <= 'd30;

        #5;
        w_en_t <= 1'b0;

        // testing complete

    end

endmodule