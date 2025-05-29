// Testbench for the main body of the CPU
// Created:     2024-01-26
// Modified:    2025-05-29
// Author:      Kagan Dikmen

`include "../rtl/cpu.v"

`timescale 1ns/1ns

module cpu_tb
    #(
        parameter MEM_INIT_FILE = "mem.hex",
        parameter TOHOST_ADDR    = 16384
    )(
    );

    reg rst, sysclk_t;
    wire led_t;

    cpu #(.DMEM_ADDR_WIDTH(13), .DMEM_DATA_WIDTH(32), .OP_LENGTH(32), .PC_WIDTH(16), .MEM_INIT_FILE(MEM_INIT_FILE)) 
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

        wait (^cpu_ut.unified_memory_cpu.BRAM[TOHOST_ADDR[14:2]] !== 1'bx);

        wait (|cpu_ut.unified_memory_cpu.BRAM[TOHOST_ADDR[14:2]] !== 1'b0);
        
        if (cpu_ut.unified_memory_cpu.BRAM[TOHOST_ADDR[14:2]] == 32'd1)
            $display("Note: Success!");
        else
            $display("Note: Failure!");
        
        $finish;
        
    end

endmodule