// Main body of the CPU
// Created:     2024-01-26
// Modified:    2024-01-28 (status: working fine)
// Author:      Kagan Dikmen

`include "cpu_components/ALU/alu.v"
`include "cpu_components/control_unit.v"
`include "cpu_components/data_memory.v"
`include "cpu_components/immediate_generator.v"
`include "cpu_components/instruction_decoder.v"
`include "common_components/mux.v"
`include "cpu_components/pc_counter.v"
`include "cpu_components/program_memory.v"
`include "cpu_components/register_file.v"

module cpu 
    #(
    parameter DMEM_ADDR_WIDTH = 12,
    parameter DMEM_DATA_WIDTH = 32,
    parameter OP_LENGTH = 32,
    parameter PC_WIDTH = 12
    )(
    input rst
    );

    wire alu_imm_select, alu_mux1_select, alu_pc_select, clk, w_en_rf, w_en_pmem, wr_en_dmem, branch, jump;
    wire [1:0] alu_mux2_select, rf_w_select, rw_mode;
    wire [3:0] alu_op_select;
    wire [31:0] instr;
    wire [PC_WIDTH-1:0] next_pc;
    wire [OP_LENGTH-1:0] alu_result, comp_result, opd1, opd2, pc_plus4, pc;
    wire [OP_LENGTH-1:0] alu_opd1, alu_opd2;
    wire [OP_LENGTH-1:0] imm;
    wire [DMEM_DATA_WIDTH-1:0] r_data;
    wire [4:0] rs1_addr, rs2_addr, rd_addr;
    wire [31:0] rs1_data, rs2_data, rd_write_data;


    alu #(.OPERAND_LENGTH(OP_LENGTH)) 
        alu_cpu
        (
            .opd1(alu_opd1),
            .opd2(alu_opd2),
            .opd3(opd1),
            .opd4(opd2),
            .alu_mux1_select(alu_mux1_select),
            .alu_mux2_select(alu_mux2_select),
            .alu_op_select(alu_op_select),
            .alu_result(alu_result),
            .comp_result(comp_result)
        );

    two_input_mux #(.INPUT_LENGTH(32))
        alu_opd1_mux
        (
            .a(opd1),
            .b(pc),
            .sel(alu_pc_select),
            .z(alu_opd1)
        );

    two_input_mux #(.INPUT_LENGTH(32))
        alu_opd2_mux
        (
            .a(opd2),
            .b(imm),
            .sel(alu_imm_select),
            .z(alu_opd2)
        );

    control_unit control_unit_cpu
        (
            .instr(instr),
            .clk(clk),
            .alu_imm_select(alu_imm_select),
            .alu_pc_select(alu_pc_select),
            .rf_w_select(rf_w_select),
            .alu_mux1_select(alu_mux1_select),
            .alu_mux2_select(alu_mux2_select),
            .alu_op_select(alu_op_select),
            .w_en_rf(w_en_rf),
            .w_en_pmem(w_en_pmem),
            .wr_en_dmem(wr_en_dmem),
            .rw_mode(rw_mode),
            .branch(branch),
            .jump(jump)
        );

    data_memory #(.DMEM_DATA_WIDTH(DMEM_DATA_WIDTH), .DMEM_ADDR_WIDTH(DMEM_ADDR_WIDTH)) 
        data_memory_cpu
        (
            .clk(clk),
            .rst(rst),
            .wr_en(wr_en_dmem),
            .rw_mode(rw_mode),
            .addr(alu_result),
            .w_data(opd2),
            .r_data(r_data)
        );

    immediate_generator immediate_generator_cpu
        (
            .instr(instr),
            .imm(imm)
        );

    instruction_decoder #(.OPD_LENGTH(OP_LENGTH), .REG_WIDTH(32)) 
        instruction_decoder_cpu
        (
            .instr(instr),
            .rs1_addr(rs1_addr),
            .rs2_addr(rs2_addr),
            .rd_addr(rd_addr),
            .rs1_data(rs1_data),
            .rs2_data(rs2_data),
            .opd1(opd1),
            .opd2(opd2)
        );

    four_input_mux #(.INPUT_LENGTH(OP_LENGTH)) 
        rf_write_select_mux_cpu
        (
            .a(alu_result),
            .b(r_data),
            .c(pc_plus4),
            .d(),
            .sel(rf_w_select),
            .z(rd_write_data)
        );

    pc_counter #(.OPD_WIDTH(OP_LENGTH), .PC_WIDTH(PC_WIDTH)) 
        pc_counter_cpu
        (
            .clk(clk),
            .rst(rst),
            .branch(branch),
            .jump(jump),
            .alu_result(alu_result),
            .comp_result(comp_result),
            .pc_plus4(pc_plus4),
            .next_pc(next_pc)
        );

    program_memory #(.PC_WIDTH(PC_WIDTH)) 
        program_memory_cpu
        (
            .clk(clk),
            .rst(rst),
            .w_en(w_en_pmem),
            .addr(next_pc),
            .data(instr),
            .pc(pc)
        );

    register_file #(.RF_ADDR_LEN(5), .RF_DATA_LEN(32)) 
        register_file_cpu
        (
            .clk(clk),
            .rst(rst),
            .w_en(w_en_rf),
            .rs1_addr(rs1_addr),
            .rs2_addr(rs2_addr),
            .rd_addr(rd_addr),
            .rs1_data(rs1_data),
            .rs2_data(rs2_data),
            .rd_write_data(rd_write_data)
        );


endmodule