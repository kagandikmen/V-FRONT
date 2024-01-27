// Testbench for the main body of the CPU
// Created:     2024-01-26
// Modified:    2024-01-26
// Author:      Kagan Dikmen

`include "cpu.v"

`timescale 1ns/1ps

module cpu_tb
    (
    );

    reg rst;

    cpu #(.DMEM_ADDR_WIDTH(12), .OP_LENGTH(32), .PC_WIDTH(12)) 
        cpu_ut 
        (
            .rst(rst)
        );
    
    initial
    begin
        rst = 1'b0;
        
        #5;
        rst = ~rst;

        #5;
        rst = ~rst;
    end

endmodule