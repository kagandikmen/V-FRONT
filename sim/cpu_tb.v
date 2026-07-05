// Testbench for the main body of the CPU
// Created:     2024-01-26
// Modified:    2026-07-05
// Author:      Kagan Dikmen

`include "../rtl/cpu.v"

`timescale 1ns/1ns

module cpu_tb
    #(
        parameter TOHOST_ADDR   = 16384,
        parameter DMEM_ADDR_WIDTH = 13,
        parameter DMEM_DATA_WIDTH = 32,
        parameter OP_LENGTH = 32,
        parameter PC_WIDTH = 16,
        parameter RESET_ADDR    = 32'h00000000
    )(
    );

    `include "../lib/common_library.vh"
    `include "../lib/instr_generator.vh"

    reg rst, sysclk_t;
    reg [31:0] mem_instr_i_t;
    reg [31:0] mem_rdata_i_t;
    wire mem_if_en_o_t;
    wire [3:0] mem_wr_mode_o_t;
    wire [12:0] mem_addra_o_t;
    wire [DMEM_ADDR_WIDTH-1:0] mem_addrb_o_t;
    wire [OP_LENGTH-1:0] mem_dinb_o_t;

    cpu #(
        .DMEM_ADDR_WIDTH(DMEM_ADDR_WIDTH),
        .DMEM_DATA_WIDTH(DMEM_DATA_WIDTH),
        .OP_LENGTH(OP_LENGTH),
        .PC_WIDTH(PC_WIDTH),
        .RESET_ADDR(RESET_ADDR)
    ) cpu_ut (
        .rst(rst),
        .sysclk(sysclk_t),
        .mem_instr_i(mem_instr_i_t),
        .mem_rdata_i(mem_rdata_i_t),
        .mem_if_en_o(mem_if_en_o_t),
        .mem_wr_mode_o(mem_wr_mode_o_t),
        .mem_addra_o(mem_addra_o_t),
        .mem_addrb_o(mem_addrb_o_t),
        .mem_dinb_o(mem_dinb_o_t)
    );
    
    always #5 sysclk_t = ~sysclk_t;
    
    initial
    begin
        rst = 1'b0;
        sysclk_t = 1'b0;
        mem_rdata_i_t = 32'd7;
        
        #5;
        rst = ~rst;

        #20;
        rst = ~rst;

        mem_instr_i_t <= i_instr(FUNCT3_ADDI, 5'd1, 5'd0, 12'd4);
        #10;
        mem_instr_i_t <= i_instr(FUNCT3_ADDI, 5'd2, 5'd0, 12'd8);
        #10;
        mem_instr_i_t <= r_instr(FUNCT3_ADD, FUNCT7_ADD, 5'd3, 5'd1, 5'd2);
        #10;
        mem_instr_i_t <= i_instr(FUNCT3_ADDI, 5'd4, 5'd3, 12'd4);
        #10;
        mem_instr_i_t <= load_instr(FUNCT3_LW, 5'd3, 12'd12, 5'd0);
        #10; 
        mem_instr_i_t <= s_instr(FUNCT3_SW, 5'd3, 12'd12, 5'd2);
        #10;
        mem_instr_i_t <= b_instr(FUNCT3_BGE, 'd4, 'd3, 'd72);
        #40;
        mem_instr_i_t <= jal_instr('d3, 'd80);
        #40;
        mem_instr_i_t <= jalr_instr('d3, 'd4, 'd120);
        #10;
        mem_instr_i_t <= lui_instr('d10, 'd2);
        #10;
        mem_instr_i_t <= auipc_instr('d15, 'd2);
        #10;
        mem_instr_i_t <= 32'b0;
        
        #100;
        $finish;
    end

endmodule