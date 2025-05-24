// Testbench for the main body of the CPU
// Created:     2024-01-26
// Modified:    2025-05-24
// Author:      Kagan Dikmen

`include "../rtl/cpu.v"

`timescale 1ns/1ps

module cpu_tb
    (
    );

    reg rst, sysclk_t;
    wire led_t;

    cpu #(.DMEM_ADDR_WIDTH(12), .DMEM_DATA_WIDTH(32), .OP_LENGTH(32), .PC_WIDTH(16), .PMEM_INIT_FILE("pmem.hex"), .DMEM_INIT_FILE("dmem.hex")) 
        cpu_ut 
        (
            .rst(rst),
            .sysclk(sysclk_t),
            .led(led_t)
        );
    
    always #5 sysclk_t = ~sysclk_t;
    
    initial
    begin
        rst = 1'b0;
        sysclk_t = 1'b0;
        
        #4;
        rst = ~rst;

        #20;
        rst = ~rst;
    end

endmodule