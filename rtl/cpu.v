// Main body of the CPU
// Created:     2024-01-26
// Modified:    2025-06-03
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

    // IF
    wire [PC_WIDTH-1:0] next_pc;
    wire [OP_LENGTH-1:0] pc_if;
    wire [31:0] instr_if;
    wire ctrl_fetch_instr_out;

    // ID
    reg alu_imm_select_id, alu_mux1_select_id, w_en_rf_id, branch_id, jump_id;
    reg [1:0] alu_pc_select_id, alu_mux2_select_id, rf_w_select_id;
    reg ecall_id, ebreak_id, mret_id;
    reg [3:0] ldst_mask_id;
    reg ldst_is_unsigned_id;
    reg st_en_id;
    reg [3:0] alu_op_select_id;
    wire [4:0] rs1_addr_id, rs2_addr_id, rd_addr_id;
    reg [31:0] instr_id;
    reg [OP_LENGTH-1:0] pc_id;
    wire bypass_ex_result_rs1_id, bypass_ex_result_rs2_id;

    // EX
    reg alu_imm_select_ex, alu_mux1_select_ex, w_en_rf_ex, branch_ex, jump_ex;
    reg [1:0] alu_pc_select_ex, alu_mux2_select_ex, rf_w_select_ex;
    reg ecall_ex, ebreak_ex, mret_ex;
    reg [3:0] ldst_mask_ex;
    reg ldst_is_unsigned_ex;
    reg st_en_ex;
    reg [3:0] alu_op_select_ex;
    wire make_nop_ex;
    reg [4:0] rd_addr_ex;
    wire [OP_LENGTH-1:0] alu_opd1, alu_opd2, alu_mux1_out, alu_mux2_out;
    wire [OP_LENGTH-1:0] alu_result, comp_result;
    reg [OP_LENGTH-1:0] pc_ex;
    reg bypass_ex_result_rs1_ex, bypass_ex_result_rs2_ex;
    reg bypass_me_result_rs1_ex, bypass_me_result_rs2_ex;
    reg [OP_LENGTH-1:0] alu_result_bypass_buffer_ex, csr_result_bypass_buffer_ex;
    wire [31:0] rs1_data_ex, rs2_data_ex;
    reg [4:0] rs1_addr_ex, rs2_addr_ex;

    wire [OP_LENGTH-1:0] csr_unit_out, csr_in;
    wire csr_unit_r_en, csr_unit_w_en;
    wire [1:0] csr_imm_select;
    wire [11:0] csr_unit_addr;
    wire [2:0] csr_unit_op;

    // ME
    wire [3:0] wr_mode;
    wire [DMEM_DATA_WIDTH-1:0] r_data, r_data_masked;
    wire [31:0] rd_write_data;
    wire [OP_LENGTH-1:0] mem_acc_in, mem_acc_out;
    wire is_misaligned, is_misalignment_store;
    wire [DMEM_ADDR_WIDTH-1:0] dmem_addr;
    reg bypass_me_result_rs1_me, bypass_me_result_rs2_me;
    reg [OP_LENGTH-1:0] mem_result_bypass_buffer_me;
    reg make_nop_me;
    reg [1:0] rf_w_select_me;
    reg [4:0] rd_addr_me;
    reg [3:0] ldst_mask_me;
    reg ldst_is_unsigned_me;
    reg st_en_me;
    reg [OP_LENGTH-1:0] alu_result_me;
    reg [OP_LENGTH-1:0] alu_opd1_me, alu_opd2_me;
    reg [OP_LENGTH-1:0] csr_unit_out_me;
    reg w_en_rf_me;
    reg [OP_LENGTH-1:0] pc_me;
    reg [31:0] instr_me;

    // WB
    reg [OP_LENGTH-1:0] alu_result_wb;
    reg [OP_LENGTH-1:0] mem_acc_out_wb;
    reg [OP_LENGTH-1:0] csr_unit_out_wb;
    reg [1:0] rf_w_select_wb;
    reg w_en_rf_wb;
    reg make_nop_wb;
    reg [4:0] rd_addr_wb;

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
            .make_nop(make_nop_ex)
        );

    always @(posedge sysclk)
    begin
        make_nop_me <= make_nop_ex;
    end

    always @(posedge sysclk)
    begin
        alu_imm_select_id <= ctrl_alu_imm_select_out;
        alu_pc_select_id <= ctrl_alu_pc_select_out;
        rf_w_select_id <= ctrl_rf_w_select_out;
        alu_mux1_select_id <= ctrl_alu_mux1_select_out;
        alu_mux2_select_id <= ctrl_alu_mux2_select_out;
        alu_op_select_id <= ctrl_alu_op_select_out;
        w_en_rf_id <= ctrl_w_en_rf_if_out;
        branch_id <= ctrl_branch_out;
        jump_id <= ctrl_jump_out;
        ecall_id <= ctrl_ecall_out;
        ebreak_id <= ctrl_ebreak_out;
        mret_id <= ctrl_mret_out;
        ldst_mask_id <= ctrl_ldst_mask_out;
        ldst_is_unsigned_id <= ctrl_ldst_is_unsigned_out;
        st_en_id <= ctrl_st_en_if_out;
    end

    wire [OP_LENGTH-1:0] pc_plus4_if;
    reg [OP_LENGTH-1:0] pc_plus4_id, pc_plus4_ex, pc_plus4_me, pc_plus4_wb;

    pc_counter #(.OPD_WIDTH(OP_LENGTH), .PC_WIDTH(PC_WIDTH)) 
        pc_counter_cpu
        (
            .clk(sysclk),
            .rst(rst),
            .branch(branch_ex && !make_nop_ex),
            .jump(jump_ex && !make_nop_ex),
            .csr_sel((ecall_ex || ebreak_ex || mret_ex || is_misaligned) && !make_nop_ex),
            .alu_result(alu_result),
            .comp_result(comp_result),
            .csr_out(csr_unit_out),
            .pc_out(pc_if),
            .pc_plus4(pc_plus4_if),
            .next_pc(next_pc)
        );
    
    always @(posedge sysclk)
    begin
        pc_id <= pc_if;
        pc_ex <= pc_id;
        pc_plus4_id <= pc_plus4_if;
        pc_plus4_ex <= pc_plus4_id;
    end


    // 
    // STAGE 2: Instruction Decode (ID)
    //

    wire [31:0] opd1_id, opd2_id;
    wire [31:0] imm_id;

    reg [31:0] instr_ex;
    reg [31:0] opd1_ex, opd2_ex;
    reg [31:0] imm_ex;

    instruction_decoder #(.OPD_LENGTH(OP_LENGTH), .REG_WIDTH(32)) 
        instruction_decoder_cpu
        (
            .clk(sysclk),
            .instr(instr_id),
            .rs1_addr(rs1_addr_id),
            .rs2_addr(rs2_addr_id),
            .rd_addr(rd_addr_id),
            .rs1_data(),
            .rs2_data(),
            .opd1(),
            .opd2(),
            .bypass_ex_result_rs1(bypass_ex_result_rs1_id),
            .bypass_ex_result_rs2(bypass_ex_result_rs2_id),
            .bypass_me_result_rs1(bypass_me_result_rs1_id),
            .bypass_me_result_rs2(bypass_me_result_rs2_id)
        );
    
    immediate_generator immediate_generator_cpu
        (
            .instr(instr_id),
            .imm(imm_id)
        );

    always @(posedge sysclk)
    begin
        instr_ex <= instr_id;
        opd1_ex <= opd1_id;
        opd2_ex <= opd2_id;
        imm_ex <= imm_id;
    end

    always @(posedge sysclk)
    begin
        alu_imm_select_ex <= alu_imm_select_id;
        alu_pc_select_ex <= alu_pc_select_id;
        rf_w_select_ex <= rf_w_select_id;
        alu_mux1_select_ex <= alu_mux1_select_id;
        alu_mux2_select_ex <= alu_mux2_select_id;
        alu_op_select_ex <= alu_op_select_id;
        w_en_rf_ex <= w_en_rf_id;
        branch_ex <= branch_id;
        jump_ex <= jump_id;
        ecall_ex <= ecall_id;
        ebreak_ex <= ebreak_id;
        mret_ex <= mret_id;
        ldst_mask_ex <= ldst_mask_id;
        ldst_is_unsigned_ex <= ldst_is_unsigned_id;
        st_en_ex <= st_en_id;
        rd_addr_ex <= rd_addr_id;
        bypass_ex_result_rs1_ex <= bypass_ex_result_rs1_id;
        bypass_ex_result_rs2_ex <= bypass_ex_result_rs2_id;
        bypass_me_result_rs1_ex <= bypass_me_result_rs1_id;
        bypass_me_result_rs2_ex <= bypass_me_result_rs2_id;
        bypass_me_result_rs1_me <= bypass_me_result_rs1_ex;
        bypass_me_result_rs2_me <= bypass_me_result_rs2_ex;
    end


    //
    // STAGE 3: Execute (EX)
    //

    alu #(.OPERAND_LENGTH(OP_LENGTH)) 
        alu_cpu
        (
            .opd1(alu_mux1_out),
            .opd2(alu_mux2_out),
            .opd3(alu_opd1),
            .opd4(alu_opd2),
            .alu_mux1_select(alu_mux1_select_ex),
            .alu_mux2_select(alu_mux2_select_ex),
            .alu_op_select(alu_op_select_ex),
            .alu_result(alu_result),
            .comp_result(comp_result)
        );

    reg bypass_alu_ready, bypass_csr_ready, bypass_ld_ready, bypass_mem_ready;
    reg [1:0] alu_opd1_mux_sel, alu_opd2_mux_sel;

    always @(posedge sysclk)
    begin

        rs1_addr_ex <= rs1_addr_id;
        rs2_addr_ex <= rs2_addr_id;

        bypass_alu_ready <= 1'b0;
        bypass_csr_ready <= 1'b0;
        bypass_ld_ready <= 1'b0;
        
        if(w_en_rf_ex && !is_misaligned && !make_nop_ex)
        begin
            if(rf_w_select_ex == 2'b00)
                bypass_alu_ready <= 1'b1;
            else if(rf_w_select_ex == 2'b01)
                bypass_ld_ready <= 1'b1;
            else if(rf_w_select_ex == 2'b11)
                bypass_csr_ready <= 1'b1;
        end

        alu_result_bypass_buffer_ex <= alu_result;
        csr_result_bypass_buffer_ex <= csr_unit_out;
    end

    assign alu_opd1 = (bypass_ex_result_rs1_ex && bypass_alu_ready) ? alu_result_bypass_buffer_ex
                    : (bypass_ex_result_rs1_ex && bypass_csr_ready) ? csr_result_bypass_buffer_ex
                    : (bypass_ex_result_rs1_ex && bypass_ld_ready)  ? mem_acc_out
                    : (bypass_me_result_rs1_ex && bypass_mem_ready) ? rd_write_data // mem_result_bypass_buffer_me
                    : rs1_data_ex;
    assign alu_opd2 = (bypass_ex_result_rs2_ex && bypass_alu_ready) ? alu_result_bypass_buffer_ex
                    : (bypass_ex_result_rs2_ex && bypass_csr_ready) ? csr_result_bypass_buffer_ex
                    : (bypass_ex_result_rs2_ex && bypass_ld_ready)  ? mem_acc_out
                    : (bypass_me_result_rs2_ex && bypass_mem_ready) ? rd_write_data // mem_result_bypass_buffer_me
                    : rs2_data_ex;
    
    four_input_mux #(.INPUT_LENGTH(32))
        alu_opd1_mux
        (
            .a(alu_opd1),
            .b(pc_ex),
            .c('b0),
            .d(),
            .sel(alu_pc_select_ex),
            .z(alu_mux1_out)
        );

    two_input_mux #(.INPUT_LENGTH(32))
        alu_opd2_mux
        (
            .a(alu_opd2),
            .b(imm_ex),
            .sel(alu_imm_select_ex),
            .z(alu_mux2_out)
        );

    four_input_mux #(.INPUT_LENGTH(32)) csr_unit_mux
        (
            .a(alu_result),
            .b(imm_ex),
            .c(instr_ex),
            .d(),
            .sel(csr_imm_select),
            .z(csr_in)
        );
    
    csr_unit #(.CSR_REG_COUNT(4096)) csr_unit_cpu
        (
            .clk(sysclk),
            .rst(rst),
            .r_en(csr_unit_r_en && !make_nop_ex),
            .w_en(csr_unit_w_en && !make_nop_ex),
            .ecall(ecall_ex && !make_nop_ex),
            .ebreak(ebreak_ex && !make_nop_ex),
            .mret(mret_ex && !make_nop_ex),
            .pc(pc_ex),
            .op(csr_unit_op),
            .in(csr_in),
            .csr_addr(csr_unit_addr),
            .out(csr_unit_out),
            .is_misaligned(is_misaligned && !make_nop_ex),
            .is_misalignment_store(is_misalignment_store),
            .misaligned_store_value(alu_opd2),
            .mem_addr(alu_result[14:0]),
            .rd_addr(rd_addr_ex)
        );

    assign is_misaligned = ((ldst_mask_ex == 4'b1111 && alu_result[1:0] != 2'b00) || (ldst_mask_ex == 4'b0011 && alu_result[0] != 1'b0)) && !make_nop_ex;
    assign is_misalignment_store = is_misaligned && st_en_ex && !make_nop_ex;
    
    // 
    // STAGE 4: Memory Access (ME)
    //

    clock_inverter clock_inverter_cpu
        (
            .clk(sysclk),
            .clk_inv(sysclk_inv)
        );

    assign mem_acc_in = (st_en_me == 1'b1) ? alu_opd2_me : r_data;

    always @(posedge sysclk)
    begin
        pc_plus4_me <= pc_plus4_ex;
        rf_w_select_me <= rf_w_select_ex;
        rd_addr_me <= rd_addr_ex;
        ldst_mask_me <= ldst_mask_ex;
        ldst_is_unsigned_me <= ldst_is_unsigned_ex;
        st_en_me <= st_en_ex;
        alu_result_me <= alu_result;
        alu_opd1_me <= alu_opd1;
        alu_opd2_me <= alu_opd2;
        csr_unit_out_me <= csr_unit_out;
        w_en_rf_me <= w_en_rf_ex;
        instr_me <= instr_ex;
        pc_me <= pc_ex;
    end

    memory_access_unit #(.BYTE_WIDTH(8))
        memory_access_unit_cpu
        (
            .addr_in(alu_result_me),
            .addr_out(dmem_addr),
            .ldst_mask(ldst_mask_me),
            .ldst_is_unsigned(ldst_is_unsigned_me),
            .st_en(st_en_me && !make_nop_me),
            .in(mem_acc_in),
            .out(mem_acc_out),
            .wr_mode(wr_mode),
            .is_misaligned(),
            .is_misalignment_store()
        );

    always @(posedge sysclk)
    begin
        if(w_en_rf_me && !make_nop_me)
            bypass_mem_ready <= 1'b1;
        else
            bypass_mem_ready <= 1'b0;

        mem_result_bypass_buffer_me <= rd_write_data;
    end


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

    always @(posedge sysclk)
    begin
        alu_result_wb <= alu_result_me;
        mem_acc_out_wb <= mem_acc_out;
        pc_plus4_wb <= pc_plus4_me;
        csr_unit_out_wb <= csr_unit_out_me;
        rf_w_select_wb <= rf_w_select_me;
        w_en_rf_wb <= w_en_rf_me;
        make_nop_wb <= make_nop_me;
        rd_addr_wb <= rd_addr_me;
    end

    four_input_mux #(.INPUT_LENGTH(OP_LENGTH)) 
        rf_write_select_mux_cpu
        (
            .a(alu_result_wb),
            .b(mem_acc_out_wb),
            .c(pc_plus4_wb),
            .d(csr_unit_out_wb),
            .sel(rf_w_select_wb),
            .z(rd_write_data)
        );
    
    register_file #(.RF_ADDR_LEN(5), .RF_DATA_LEN(32)) 
        register_file_cpu
        (
            .clk(sysclk),
            .rst(rst),
            .w_en(w_en_rf_wb && !make_nop_wb),
            .rs1_addr(rs1_addr_ex),
            .rs2_addr(rs2_addr_ex),
            .rd_addr(rd_addr_wb),
            .rs1_data(rs1_data_ex),
            .rs2_data(rs2_data_ex),
            .rd_write_data(rd_write_data)
        );

    //
    // Output Logic
    //
    
    // See the comment at the declaration of the output led
    assign led = branch_ex;

endmodule