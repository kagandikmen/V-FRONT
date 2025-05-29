// Testbench for the CSR unit
// Created:     2025-05-25
// Modified:    2025-05-25
// Author:      Kagan Dikmen

`include "../rtl/csr_unit.v"

`timescale 1ns/1ps

module csr_unit_tb
    #()();

    reg clk_t, rst_t, r_en_t, w_en_t;
    reg [3:0] csr_addr_t;
    reg [31:0] in_t;
    wire [31:0] out_t;

    csr_unit #(.CSR_REG_COUNT(16))
                csr_unit_ut
                (
                    .clk(clk_t),
                    .rst(rst_t),
                    .r_en(r_en_t),
                    .w_en(w_en_t),
                    .in(in_t),
                    .csr_addr(csr_addr_t),
                    .out(out_t)
                );
    
    always #2 clk_t = ~clk_t;
    
    initial
    begin

        clk_t <= 1'b0;
        rst_t <= 1'b0;
        r_en_t <= 1'b0;
        w_en_t <= 1'b0;
        in_t <= 32'b0;
        csr_addr_t <= 4'b0;

        // reset
        #5;
        rst_t <= 1'b1;
        #5;
        rst_t <= 1'b0;

        // write
        #5;
        w_en_t <= 1'b1;
        in_t <= 32'd333;
        csr_addr_t <= 4'd0;

        // write
        #5;
        in_t <= 32'd999;
        csr_addr_t <= 4'd5;

        #5;
        w_en_t <= 1'b0;

        // read
        #5;
        r_en_t <= 1'b1;
        csr_addr_t <= 4'd0;

        // read
        #5;
        csr_addr_t <= 4'd5;

        // write + read
        #5;
        w_en_t <= 1'b1;
        in_t <= 32'd2025;

        #5;
        in_t <= 32'd2026;

        // end simulation
        #5;
        r_en_t <= 1'b0;
        w_en_t <= 1'b0;

    end

endmodule