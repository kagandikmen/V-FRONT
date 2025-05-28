// Testbench for the memory access unit of the CPU
// Created:     2025-05-28
// Modified:    2025-05-28
// Author:      Kagan Dikmen

`include "../rtl/memory_access_unit.v"

`timescale 1ns/1ps

module memory_access_unit_tb
    ();

    reg ldst_is_unsigned_t;
    reg [3:0] ldst_mask_t;
    reg [31:0] memory_out_t;
    reg [1:0] offset_t;
    wire out_t;

    memory_access_unit #(.BYTE_WIDTH(8))
        memory_access_unit_ut
        (
            .ldst_mask(ldst_mask_t),
            .offset(offset_t),
            .ldst_is_unsigned(ldst_is_unsigned_t),
            .memory_out(memory_out_t),
            .out(out_t)
        );

    initial
    begin
        ldst_mask_t <= 4'b1111;
        offset_t <= 2'b00;
        ldst_is_unsigned_t <= 0;
        memory_out_t <= 32'hffeeddbb;

        #5;
        ldst_mask_t <= 4'b0111;
        ldst_is_unsigned_t <= 0;

        #5;
        ldst_mask_t <= 4'b0111;
        ldst_is_unsigned_t <= 1;

        #5;
        ldst_mask_t <= 4'b0011;
        ldst_is_unsigned_t <= 0;

        #5;
        ldst_mask_t <= 4'b0011;
        ldst_is_unsigned_t <= 1;

        #5;
        ldst_mask_t <= 4'b0001;
        ldst_is_unsigned_t <= 0;

        #5;
        ldst_mask_t <= 4'b0001;
        ldst_is_unsigned_t <= 1;

        #5;
        ldst_mask_t <= 4'b0000;
        ldst_is_unsigned_t <= 0;

        #5;
        ldst_mask_t <= 4'b0000;
        ldst_is_unsigned_t <= 1;
        
        #5;
        ldst_mask_t <= 4'b0111;
        offset_t <= 2'b01;
        ldst_is_unsigned_t <= 0;

        #5;
        ldst_mask_t <= 4'b0111;
        ldst_is_unsigned_t <= 1;

        #5;
        ldst_mask_t <= 4'b0011;
        ldst_is_unsigned_t <= 0;

        #5;
        ldst_mask_t <= 4'b0011;
        ldst_is_unsigned_t <= 1;

        #5;
        ldst_mask_t <= 4'b0001;
        ldst_is_unsigned_t <= 0;

        #5;
        ldst_mask_t <= 4'b0001;
        ldst_is_unsigned_t <= 1;

        #5;
        ldst_mask_t <= 4'b0000;
        ldst_is_unsigned_t <= 0;

        #5;
        ldst_mask_t <= 4'b0000;
        ldst_is_unsigned_t <= 1;
        
        #5;
        ldst_mask_t <= 4'b0111;
        offset_t <= 2'b10;
        ldst_is_unsigned_t <= 0;

        #5;
        ldst_mask_t <= 4'b0111;
        ldst_is_unsigned_t <= 1;

        #5;
        ldst_mask_t <= 4'b0011;
        ldst_is_unsigned_t <= 0;

        #5;
        ldst_mask_t <= 4'b0011;
        ldst_is_unsigned_t <= 1;

        #5;
        ldst_mask_t <= 4'b0001;
        ldst_is_unsigned_t <= 0;

        #5;
        ldst_mask_t <= 4'b0001;
        ldst_is_unsigned_t <= 1;

        #5;
        ldst_mask_t <= 4'b0000;
        ldst_is_unsigned_t <= 0;

        #5;
        ldst_mask_t <= 4'b0000;
        ldst_is_unsigned_t <= 1;
        
        #5;
        ldst_mask_t <= 4'b0111;
        offset_t <= 2'b11;
        ldst_is_unsigned_t <= 0;

        #5;
        ldst_mask_t <= 4'b0111;
        ldst_is_unsigned_t <= 1;

        #5;
        ldst_mask_t <= 4'b0011;
        ldst_is_unsigned_t <= 0;

        #5;
        ldst_mask_t <= 4'b0011;
        ldst_is_unsigned_t <= 1;

        #5;
        ldst_mask_t <= 4'b0001;
        ldst_is_unsigned_t <= 0;

        #5;
        ldst_mask_t <= 4'b0001;
        ldst_is_unsigned_t <= 1;

        #5;
        ldst_mask_t <= 4'b0000;
        ldst_is_unsigned_t <= 0;

        #5;
        ldst_mask_t <= 4'b0000;
        ldst_is_unsigned_t <= 1;

        #20;
        $finish;
    end

endmodule