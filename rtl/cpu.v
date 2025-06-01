// Main body of the CPU
// Created:     2024-01-26
// Modified:    2025-06-01
// Author:      Kagan Dikmen

`include "./luftALU/rtl/alu.v"
`include "./bram_dual.v"
`include "./clock_inverter.v"
`include "./control_unit.v"
`include "./csr_unit.v"
`include "./immediate_generator.v"
`include "./instruction_decoder.v"
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
    reg alu_imm_select, alu_mux1_select, w_en_rf, branch, jump;
    reg [1:0] alu_pc_select, alu_mux2_select, rf_w_select;
    reg [3:0] alu_op_select;
    wire [3:0] wr_mode;
    wire [31:0] instr;
    wire [PC_WIDTH-1:0] next_pc;
    wire [OP_LENGTH-1:0] alu_result, comp_result, opd1, opd2;
    
    reg [OP_LENGTH-1:0] pc_plus4, pc;

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

    reg [3:0] ldst_mask;
    reg ldst_is_unsigned;
    reg st_en;

    wire [OP_LENGTH-1:0] mem_acc_in, mem_acc_out;

    reg ecall, ebreak, mret;

    wire is_misaligned, is_misalignment_store;

    wire [DMEM_ADDR_WIDTH-1:0] dmem_addr;

    wire [31:0] instr_if;

    reg [31:0] instr_id;

    wire ctrl_fetch_instr_out;
    reg make_nop;

    //
    // STAGE 1: Instruction Fetch (IF) + Control Logic
    //

    always @(posedge sysclk)
        instr_id <= instr_if;

    wire ctrl_alu_imm_select_out;
    wire [1:0] ctrl_alu_pc_select_out;
    wire [1:0] ctrl_rf_w_select_out;
    wire ctrl_alu_mux1_select_out;
    wire [1:0] ctrl_alu_mux2_select_out;
    wire [3:0] ctrl_alu_op_select_out;
    wire ctrl_w_en_rf_if_out;
    wire ctrl_branch_out;
    wire ctrl_jump_out;
    wire ctrl_ecall_out;
    wire ctrl_ebreak_out;
    wire ctrl_mret_out;
    wire [3:0] ctrl_ldst_mask_out;
    wire ctrl_ldst_is_unsigned_out;
    wire ctrl_st_en_if_out;
    wire ctrl_csr_r_en_out;
    wire ctrl_csr_w_en_out;
    wire [2:0] ctrl_csr_op_out;
    wire [11:0] ctrl_csr_addr_out;
    wire [1:0] ctrl_csr_imm_select_out;
    wire ctrl_make_nop_out;

    control_unit control_unit_cpu
        (
            .clk(sysclk),
            .rst(rst),
            .fetch_instr(ctrl_fetch_instr_out),
            .instr(instr_if),
            .is_misaligned(is_misaligned),
            .alu_imm_select(ctrl_alu_imm_select_out),
            .alu_pc_select(ctrl_alu_pc_select_out),
            .rf_w_select(ctrl_rf_w_select_out),
            .alu_mux1_select(ctrl_alu_mux1_select_out),
            .alu_mux2_select(ctrl_alu_mux2_select_out),
            .alu_op_select(ctrl_alu_op_select_out),
            .w_en_rf_if(ctrl_w_en_rf_if_out),
            .branch(ctrl_branch_out),
            .jump(ctrl_jump_out),
            .ecall(ctrl_ecall_out),
            .ebreak(ctrl_ebreak_out),
            .mret(ctrl_mret_out),
            .ldst_mask(ctrl_ldst_mask_out),
            .ldst_is_unsigned(ctrl_ldst_is_unsigned_out),
            .st_en_if(ctrl_st_en_if_out),
            .csr_r_en(csr_unit_r_en),
            .csr_w_en(csr_unit_w_en),
            .csr_op(csr_unit_op),
            .csr_addr(csr_unit_addr),
            .csr_imm_select(csr_imm_select),
            .branch_true(comp_result[0]),
            .make_nop(ctrl_make_nop_out)
        );

    always @(posedge sysclk)
    begin
        alu_imm_select <= ctrl_alu_imm_select_out;
        alu_pc_select <= ctrl_alu_pc_select_out;
        rf_w_select <= ctrl_rf_w_select_out;
        alu_mux1_select <= ctrl_alu_mux1_select_out;
        alu_mux2_select <= ctrl_alu_mux2_select_out;
        alu_op_select <= ctrl_alu_op_select_out;
        w_en_rf <= ctrl_w_en_rf_if_out;
        branch <= ctrl_branch_out;
        jump <= ctrl_jump_out;
        ecall <= ctrl_ecall_out;
        ebreak <= ctrl_ebreak_out;
        mret <= ctrl_mret_out;
        ldst_mask <= ctrl_ldst_mask_out;
        ldst_is_unsigned <= ctrl_ldst_is_unsigned_out;
        st_en <= ctrl_st_en_if_out;
        // csr_unit_r_en <= ctrl_csr_r_en_out;
        // csr_unit_w_en <= ctrl_csr_w_en_out;
        // csr_unit_op <= ctrl_csr_op_out;
        // csr_unit_addr <= ctrl_csr_addr_out;
        // csr_imm_select <= ctrl_csr_imm_select_out;
        make_nop <= ctrl_make_nop_out;
    end

    wire [OP_LENGTH-1:0] pcctrl_pc_out;
    wire [OP_LENGTH-1:0] pcctrl_pc_plus4_out;
    wire [PC_WIDTH-1:0] pcctrl_next_pc_out;

    pc_counter #(.OPD_WIDTH(OP_LENGTH), .PC_WIDTH(PC_WIDTH)) 
        pc_counter_cpu
        (
            .clk(sysclk),
            .rst(rst),
            .branch(branch && !make_nop),
            .jump(jump && !make_nop),
            .csr_sel((ecall || ebreak || mret || is_misaligned) && !make_nop),
            .alu_result(alu_result),
            .comp_result(comp_result),
            .csr_out(csr_unit_out),
            .pc_out(pcctrl_pc_out),
            .pc_plus4(pcctrl_pc_plus4_out),
            .next_pc(next_pc)
        );
    
    always @(posedge sysclk)
    begin
        pc <= pcctrl_pc_out;
        pc_plus4 <= pcctrl_pc_plus4_out;
    end

    // 
    // STAGE 2: Instruction Decode (ID)
    //

    instruction_decoder #(.OPD_LENGTH(OP_LENGTH), .REG_WIDTH(32)) 
        instruction_decoder_cpu
        (
            .instr(instr_id),
            .rs1_addr(rs1_addr),
            .rs2_addr(rs2_addr),
            .rd_addr(rd_addr),
            .rs1_data(rs1_data),
            .rs2_data(rs2_data),
            .opd1(opd1),
            .opd2(opd2)
        );
    
    immediate_generator immediate_generator_cpu
        (
            .instr(instr_id),
            .imm(imm)
        );

    //
    // STAGE 3: Execute (EX)
    //

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

    // 
    // STAGE 4: Memory Access (ME)
    //

    clock_inverter clock_inverter_cpu
        (
            .clk(sysclk),
            .clk_inv(sysclk_inv)
        );

    four_input_mux #(.INPUT_LENGTH(32)) csr_unit_mux
        (
            .a(alu_result),
            .b(imm),
            .c(instr_id),
            .d(),
            .sel(csr_imm_select),
            .z(csr_in)
        );
    
    csr_unit #(.CSR_REG_COUNT(4096)) csr_unit_cpu
        (
            .clk(sysclk),
            .rst(rst),
            .r_en(csr_unit_r_en && !make_nop),
            .w_en(csr_unit_w_en && !make_nop),
            .ecall(ecall && !make_nop),
            .ebreak(ebreak && !make_nop),
            .mret(mret && !make_nop),
            .pc(pc),
            .op(csr_unit_op),
            .in(csr_in),
            .csr_addr(csr_unit_addr),
            .out(csr_unit_out),
            .is_misaligned(is_misaligned && !make_nop),
            .is_misalignment_store(is_misalignment_store),
            .misaligned_store_value(opd2),
            .mem_addr(alu_result[14:0]),
            .rd_addr(rd_addr)
        );

    assign mem_acc_in = (st_en==1'b1) ? opd2 : r_data;

    memory_access_unit #(.BYTE_WIDTH(8))
        memory_access_unit_cpu
        (
            .addr_in(alu_result),
            .addr_out(dmem_addr),
            .ldst_mask(ldst_mask),
            .ldst_is_unsigned(ldst_is_unsigned),
            .st_en(st_en && !make_nop),
            .in(mem_acc_in),
            .out(mem_acc_out),
            .wr_mode(wr_mode),
            .is_misaligned(is_misaligned),
            .is_misalignment_store(is_misalignment_store)
        );

    // NOTE: a for program memory, b for data memory
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
            .ena(ctrl_fetch_instr_out),
            .enb(1'b1),
            .rsta(),
            .rstb(),
            .regcea(),
            .regceb(),
            .douta(instr_if),
            .doutb(r_data)
        );

    //
    // STAGE 5: Register Writeback (WB)
    //

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
    
    register_file #(.RF_ADDR_LEN(5), .RF_DATA_LEN(32)) 
        register_file_cpu
        (
            .clk(sysclk),
            .rst(rst),
            .w_en(w_en_rf && !is_misaligned && !make_nop),
            .rs1_addr(rs1_addr),
            .rs2_addr(rs2_addr),
            .rd_addr(rd_addr),
            .rs1_data(rs1_data),
            .rs2_data(rs2_data),
            .rd_write_data(rd_write_data)
        );

    //
    // Output Logic
    //
    
    // See the comment at the declaration of the output led
    assign led = branch;

endmodule