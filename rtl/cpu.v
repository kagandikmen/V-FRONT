// Main body of the CPU
// Created:     2024-01-26
// Modified:    2025-05-23
// Author:      Kagan Dikmen

`include "./luftALU/rtl/alu.v"
`include "./clock_inverter.v"
`include "./control_unit.v"
// `include "./data_memory.v"
`include "./immediate_generator.v"
`include "./instruction_decoder.v"
`include "./bram.v"
`include "./dff.v"
`include "./extender_register.v"
`include "./mux.v"
`include "./pc_counter.v"
// `include "./program_memory.v"
`include "./register_file.v"

module cpu 
    #(
    parameter DMEM_ADDR_WIDTH = 12,
    parameter DMEM_DATA_WIDTH = 32,
    parameter OP_LENGTH = 32,
    parameter PC_WIDTH = 16
    )(
    input rst,
    input sysclk,
    output wire led     // does not serve any practical purpose other than preventing synthesisers from optimising the whole CPU away
    );

    wire alu_imm_select, alu_mux1_select, alu_pc_select, w_en_rf, wr_en_dmem, branch, jump;
    wire pcctr_clk;
    wire [1:0] alu_mux2_select, rf_w_select;
    wire [3:0] alu_op_select, rw_mode;
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

    clock_inverter clock_inverter_cpu
        (
            .clk(sysclk),
            .clk_inv(pcctr_clk)
        );

    control_unit control_unit_cpu
        (
            .instr(instr),
            .alu_imm_select(alu_imm_select),
            .alu_pc_select(alu_pc_select),
            .rf_w_select(rf_w_select),
            .alu_mux1_select(alu_mux1_select),
            .alu_mux2_select(alu_mux2_select),
            .alu_op_select(alu_op_select),
            .w_en_rf(w_en_rf),
            .wr_en_dmem(wr_en_dmem),
            .rw_mode(rw_mode),
            .branch(branch),
            .jump(jump)
        );
    
    bram data_memory_cpu
        (
            .wr_addr(alu_result[11:0]),
            .rd_addr(alu_result[11:0]),
            .ram_in(opd2),
            .clk(sysclk),
            .byte_w_en(rw_mode),
            .r_en(1'b1),
            .out_res(),
            .out_r_en(),
            .r_out(r_data)
        );
    
    /*
    data_memory #(.DMEM_DATA_WIDTH(DMEM_DATA_WIDTH), .DMEM_ADDR_WIDTH(DMEM_ADDR_WIDTH)) 
        data_memory_cpu
        (
            .clk(sysclk),
            .rst(rst),
            .wr_en(wr_en_dmem),
            .rw_mode(rw_mode),
            .addr(alu_result[11:0]),
            .w_data(opd2),
            .r_data(r_data)
        );
    */
    
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
            .clk(sysclk),
            .rst(rst),
            .branch(branch),
            .jump(jump),
            .alu_result(alu_result),
            .comp_result(comp_result),
            .pc_out(pc),
            .pc_plus4(pc_plus4),
            .next_pc(next_pc)
        );
    
    
    bram #(.INIT_FILE("./dummy_instrs.mem")) program_memory_cpu
        (
            .wr_addr(),
            .rd_addr({'b0,next_pc[PC_WIDTH-1:2]}),
            .ram_in(),
            .clk(sysclk),
            .byte_w_en(),
            .r_en(1'b1),
            .out_res(),
            .out_r_en(),
            .r_out(instr)
        );
    
    /*                    
    extender_register #(.INPUT_WIDTH(PC_WIDTH), .OUTPUT_WIDTH(OP_LENGTH))
        extender_register_cpu
        (
            .clk(sysclk),
            .in(next_pc),
            .out(pc)
        );
    */

    /*
    program_memory #(.PC_WIDTH(PC_WIDTH)) 
        program_memory_cpu
        (
            .clk(sysclk),
            .rst(rst),
            .addr(next_pc),
            .data(instr),
            .pc(pc)
        );
    */
    
    register_file #(.RF_ADDR_LEN(5), .RF_DATA_LEN(32)) 
        register_file_cpu
        (
            .clk(sysclk),
            .rst(rst),
            .w_en(w_en_rf),
            .rs1_addr(rs1_addr),
            .rs2_addr(rs2_addr),
            .rd_addr(rd_addr),
            .rs1_data(rs1_data),
            .rs2_data(rs2_data),
            .rd_write_data(rd_write_data)
        );
    
    assign led = wr_en_dmem;

endmodule