// Top SoC module
// Created:     2026-07-04
// Modified:    2026-07-05
// Author:      Kagan Dikmen

`include "./bram_dual.v"
`include "./cpu.v"

module soc
    #(
    parameter DMEM_ADDR_WIDTH  = 13,
    parameter DMEM_DATA_WIDTH  = 32,
    parameter OP_LENGTH = 32,
    parameter PC_WIDTH = 16,
    parameter MEM_INIT_FILE = "",
    parameter RESET_ADDR = 32'h00000000
    )(
    input rst,
    input sysclk,
    output wire led     // dummy signal to prevent overoptimization
    );

    wire [31:0] cpu_instr_if_in;
    wire [31:0] cpu_r_data_in;
    wire cpu_ctrl_fetch_instr_out_out;
    wire [3:0] cpu_wr_mode_out;
    wire [12:0] cpu_bram_addra_out;
    wire [DMEM_ADDR_WIDTH-1:0] cpu_bram_addrb_out;
    wire [OP_LENGTH-1:0] cpu_bram_dinb_out;

    cpu #(
        .DMEM_ADDR_WIDTH(DMEM_ADDR_WIDTH),
        .DMEM_DATA_WIDTH(DMEM_DATA_WIDTH),
        .OP_LENGTH(OP_LENGTH),
        .PC_WIDTH(PC_WIDTH),
        .RESET_ADDR(RESET_ADDR)
    ) cpu (
        .rst(rst),
        .sysclk(sysclk),
        .instr_if(cpu_instr_if_in),
        .r_data(cpu_r_data_in),
        .ctrl_fetch_instr_out(cpu_ctrl_fetch_instr_out_out),
        .wr_mode(cpu_wr_mode_out),
        .bram_addra(cpu_bram_addra_out),
        .bram_addrb(cpu_bram_addrb_out),
        .bram_dinb(cpu_bram_dinb_out),
        .led(led)
    );

    // NOTE: a for program memory, b for data memory
    bram_dual #(
        .INIT_FILE(MEM_INIT_FILE)
    ) unified_memory (
        .addra(cpu_bram_addra_out),
        .addrb(cpu_bram_addrb_out),
        .dina(),
        .dinb(cpu_bram_dinb_out),
        .clka(sysclk),
        .clkb(sysclk),
        .wea(),
        .web(cpu_wr_mode_out),
        .ena(cpu_ctrl_fetch_instr_out_out),
        .enb(1'b1),
        .rsta(),
        .rstb(),
        .regcea(),
        .regceb(),
        .douta(cpu_instr_if_in),
        .doutb(cpu_r_data_in)
    );

endmodule
