// Testbench for the data memory of the CPU
// Created:     2024-01-25
// Modified:    2024-08-15
// Author:      Kagan Dikmen

`include "../rtl/data_memory.v"

`timescale 1ns/1ps

module data_memory_tb
    #(
    parameter DMEM_DATA_WIDTH = 32,
    parameter DMEM_ADDR_WIDTH = 4
    )(
    );

    reg clk_t, rst_t, wr_en_t;
    reg [1:0] rw_mode_t;
    reg [DMEM_ADDR_WIDTH-1:0] addr_t;
    reg [DMEM_DATA_WIDTH-1:0] w_data_t;
    wire [DMEM_DATA_WIDTH-1:0] r_data_t;

    data_memory #(.DMEM_DATA_WIDTH(DMEM_DATA_WIDTH), .DMEM_ADDR_WIDTH(DMEM_ADDR_WIDTH))
                data_memory_ut
                (
                    .clk(clk_t),
                    .rst(rst_t),
                    .wr_en(wr_en_t),
                    .rw_mode(rw_mode_t),
                    .addr(addr_t),
                    .w_data(w_data_t),
                    .r_data(r_data_t)
                );
    
    always #2 clk_t = ~clk_t;
    
    initial
    begin

        clk_t <= 1'b0;
        rst_t <= 1'b0;
        wr_en_t <= 1'b0;        // DONT'WRITE
        rw_mode_t <= 2'b0;      // WORD
        addr_t <= 'd0;
        w_data_t <= 'd0;

        // resetting
        #5;
        rst_t <= 1'b1;
        #5;
        rst_t <= 1'b0;

        #5;                     // HALFWORD (READ)
        rw_mode_t <= 2'b01;     

        #5;                     // BYTE (READ)
        rw_mode_t <= 2'b10;     

        #5;                     // Invalid rw_value
        rw_mode_t <= 2'b11;     

        #5;                     // BYTE (READ)
        rw_mode_t <= 2'b10;     

        #5;                     // WRITE (BYTE)
        wr_en_t <= 1'b1;        
        addr_t <= 'd5;
        w_data_t <= 'd15;   
        
        #5;                     // WRITE (HALFWORD) (invalid addr)
        addr_t <= 'd7;
        rw_mode_t <= 2'b01;     
        w_data_t <= {8'd27, 8'd24, 8'd21, 8'd18};

        #5;                     // WRITE (HALFWORD)
        addr_t <= 'd6;   

        #5;                     // WRITE (WORD) (invalid addr)
        addr_t <= 'd6;
        rw_mode_t <= 2'b00;     
        w_data_t <= {8'd33, 8'd30, 8'd27, 8'd24};

        #5;                     // WRITE (WORD)
        addr_t <= 'd8;    

        #5;
        wr_en_t <= 1'b0;

        #5;
        rst_t <= 1'b1;

        #5;
        rst_t <= 1'b0;

    end


endmodule