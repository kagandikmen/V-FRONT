// Testbench for the main body of the CPU
// Created:     2024-01-26
// Modified:    2024-08-12
// Author:      Kagan Dikmen

`include "cpu.v"

`timescale 1ns/1ps

module cpu_tb
    (
    );

    reg rst, sysclk_t, led_t;

    cpu #(.DMEM_ADDR_WIDTH(12), .DMEM_DATA_WIDTH(32), .OP_LENGTH(32), .PC_WIDTH(12)) 
        cpu_ut 
        (
            .rst(rst),
            .sysclk(sysclk_t)
        );
    
    always #5 sysclk_t = ~sysclk_t;
    
    initial
    begin
        rst = 1'b0;
        sysclk_t = 1'b0;
        
        #4;
        rst = ~rst;

        #10;
        rst = ~rst;
    end

endmodule