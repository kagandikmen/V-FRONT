// Testbench for the main body of the CPU
// Created:     2024-01-26
// Modified:    2025-05-28
// Author:      Kagan Dikmen

`include "../rtl/cpu.v"

`timescale 1ns/1ns

module cpu_tb
    #(
        parameter PMEM_INIT_FILE = "pmem.hex",
        parameter DMEM_INIT_FILE = "dmem.hex",
        parameter TOHOST_ADDR    = 16384
    )(
    );

    reg rst, sysclk_t;
    wire led_t;

    cpu #(.DMEM_ADDR_WIDTH(12), .DMEM_DATA_WIDTH(32), .OP_LENGTH(32), .PC_WIDTH(16), .PMEM_INIT_FILE(PMEM_INIT_FILE), .DMEM_INIT_FILE(DMEM_INIT_FILE)) 
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

        wait (^cpu_ut.data_memory_cpu.ram[TOHOST_ADDR[13:2]] !== 1'bx);

        wait (|cpu_ut.data_memory_cpu.ram[TOHOST_ADDR[13:2]] !== 1'b0);
        
        if (cpu_ut.data_memory_cpu.ram[TOHOST_ADDR[13:2]] == 32'd1)
            $display("Note: Success!");
        else
            $display("Note: Failure!");
        
        $finish;
        
    end

endmodule