// Main body of the CPU
// Created:     2024-01-26
// Modified:    2025-05-29
// Author:      Kagan Dikmen

`include "./luftALU/rtl/alu.v"
`include "./clock_inverter.v"
`include "./control_unit.v"
`include "./csr_unit.v"
`include "./immediate_generator.v"
`include "./instruction_decoder.v"
`include "./bram_dual.v"
`include "./memory_access_unit.v"
`include "./mux.v"
`include "./pc_counter.v"
`include "./register_file.v"

module cpu 
    #(
    parameter DMEM_ADDR_WIDTH = 13,
    parameter DMEM_DATA_WIDTH = 32,
    parameter OP_LENGTH = 32,
    parameter PC_WIDTH = 16,
    parameter MEM_INIT_FILE = ""
    )(
    input rst,
    input sysclk,
    output wire led     // does not serve any practical purpose other than preventing synthesisers from optimising the whole CPU away
    );

    wire sysclk_inv;
    wire alu_imm_select, alu_mux1_select, w_en_rf, branch, jump;
    wire [1:0] alu_pc_select, alu_mux2_select, rf_w_select;
    wire [3:0] alu_op_select, wr_mode;
    wire [31:0] instr;
    wire [PC_WIDTH-1:0] next_pc;
    wire [OP_LENGTH-1:0] alu_result, comp_result, opd1, opd2, pc_plus4, pc;
    wire [OP_LENGTH-1:0] alu_opd1, alu_opd2;
    wire [OP_LENGTH-1:0] imm;
    wire [DMEM_DATA_WIDTH-1:0] r_data, r_data_masked;
    wire [4:0] rs1_addr, rs2_addr, rd_addr;
    wire [31:0] rs1_data, rs2_data, rd_write_data;

    wire [OP_LENGTH-1:0] csr_unit_out, csr_in;
    wire csr_unit_r_en, csr_unit_w_en;
    wire [1:0] csr_imm_select;
    wire [11:0] csr_unit_addr;
    wire [2:0] csr_unit_op;

    wire [3:0] ldst_mask;
    wire ldst_is_unsigned;
    wire st_en;

    wire [OP_LENGTH-1:0] mem_acc_in, mem_acc_out;

    wire ecall, ebreak, mret;

    wire is_misaligned, is_misalignment_store;

    wire [DMEM_ADDR_WIDTH-1:0] dmem_addr;

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

    four_input_mux #(.INPUT_LENGTH(32))
        alu_opd1_mux
        (
            .a(opd1),
            .b(pc),
            .c('b0),
            .d(),
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
            .clk_inv(sysclk_inv)
        );

    control_unit control_unit_cpu
        (
            .instr(instr),
            .is_misaligned(is_misaligned),
            .alu_imm_select(alu_imm_select),
            .alu_pc_select(alu_pc_select),
            .rf_w_select(rf_w_select),
            .alu_mux1_select(alu_mux1_select),
            .alu_mux2_select(alu_mux2_select),
            .alu_op_select(alu_op_select),
            .w_en_rf(w_en_rf),
            .branch(branch),
            .jump(jump),
            .ecall(ecall),
            .ebreak(ebreak),
            .mret(mret),
            .ldst_mask(ldst_mask),
            .ldst_is_unsigned(ldst_is_unsigned),
            .st_en(st_en),
            .csr_r_en(csr_unit_r_en),
            .csr_w_en(csr_unit_w_en),
            .csr_op(csr_unit_op),
            .csr_addr(csr_unit_addr),
            .csr_imm_select(csr_imm_select)
        );

    four_input_mux #(.INPUT_LENGTH(32)) csr_unit_mux
        (
            .a(alu_result),
            .b(imm),
            .c(instr),
            .d(),
            .sel(csr_imm_select),
            .z(csr_in)
        );
    
    csr_unit #(.CSR_REG_COUNT(4096)) csr_unit_cpu
        (
            .clk(sysclk),
            .rst(rst),
            .r_en(csr_unit_r_en),
            .w_en(csr_unit_w_en),
            .ecall(ecall),
            .ebreak(ebreak),
            .mret(mret),
            .pc(pc),
            .op(csr_unit_op),
            .in(csr_in),
            .csr_addr(csr_unit_addr),
            .out(csr_unit_out),
            .is_misaligned(is_misaligned),
            .is_misalignment_store(is_misalignment_store),
            .misaligned_store_value(opd2),
            .mem_addr(alu_result[14:0]),
            .rd_addr(rd_addr)
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

    assign mem_acc_in = (st_en==1'b1) ? opd2 : r_data;

    memory_access_unit #(.BYTE_WIDTH(8))
        memory_access_unit_cpu
        (
            .addr_in(alu_result),
            .addr_out(dmem_addr),
            .ldst_mask(ldst_mask),
            .ldst_is_unsigned(ldst_is_unsigned),
            .st_en(st_en),
            .in(mem_acc_in),
            .out(mem_acc_out),
            .wr_mode(wr_mode),
            .is_misaligned(is_misaligned),
            .is_misalignment_store(is_misalignment_store)
        );

    four_input_mux #(.INPUT_LENGTH(OP_LENGTH)) 
        rf_write_select_mux_cpu
        (
            .a(alu_result),
            .b(mem_acc_out),
            .c(pc_plus4),
            .d(csr_unit_out),
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
            .csr_sel(ecall || ebreak || mret || is_misaligned),
            .alu_result(alu_result),
            .comp_result(comp_result),
            .csr_out(csr_unit_out),
            .pc_out(pc),
            .pc_plus4(pc_plus4),
            .next_pc(next_pc)
        );
    
    
    register_file #(.RF_ADDR_LEN(5), .RF_DATA_LEN(32)) 
        register_file_cpu
        (
            .clk(sysclk),
            .rst(rst),
            .w_en(w_en_rf && !is_misaligned),
            .rs1_addr(rs1_addr),
            .rs2_addr(rs2_addr),
            .rd_addr(rd_addr),
            .rs1_data(rs1_data),
            .rs2_data(rs2_data),
            .rd_write_data(rd_write_data)
        );

    bram_dual #(.INIT_FILE(MEM_INIT_FILE))
        unified_memory_cpu
        (
            .addra(next_pc[14:2]),
            .addrb(dmem_addr),
            .dina(),
            .dinb(mem_acc_out),
            .clka(sysclk),
            .clkb(sysclk_inv),
            .wea(),
            .web(wr_mode),
            .ena(1'b1),
            .enb(1'b1),
            .rsta(),
            .rstb(),
            .regcea(),
            .regceb(),
            .douta(instr),
            .doutb(r_data)
        );
    
    assign led = branch;

endmodule