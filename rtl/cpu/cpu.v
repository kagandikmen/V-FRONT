// Main body of the CPU
// Created:     2024-01-26
// Modified:    2026-07-14
// Author:      Kagan Dikmen

`include "luftALU/rtl/alu.v"
`include "control_unit.v"
`include "csr_unit.v"
`include "immediate_generator.v"
`include "instruction_decoder.v"
`include "memory_access_unit.v"
`include "mux.v"
`include "pc_counter.v"
`include "register_file.v"

module cpu 
    #(
    parameter DMEM_ADDR_WIDTH = 13,
    parameter DMEM_DATA_WIDTH = 32,
    parameter OP_LENGTH = 32,
    parameter PC_WIDTH = 16,
    parameter RESET_ADDR = 32'h00000000
    )(
    input rst,
    input sysclk,

    // Memory interface
    input wire [31:0] mem_instr_i,
    input wire [31:0] mem_rdata_i,
    input wire mem_rdata_valid_i,
    input wire mem_wdata_valid_i,
    output wire mem_if_en_o,
    output wire mem_enb_o,
    output wire [3:0] mem_wr_mode_o,
    output wire [12:0] mem_addra_o,
    output wire [DMEM_ADDR_WIDTH-1:0] mem_addrb_o,
    output wire [OP_LENGTH-1:0] mem_dinb_o
    );


    // IF
    wire [OP_LENGTH-1:0] pc_if, pc_plus4_if, next_pc;
    reg filled_if;
    wire illegal_instr_if;


    // ID
    reg alu_imm_select_id, alu_cu_input_sel_id, w_en_rf_id, branch_id, jal_id, jalr_id;
    reg [1:0] alu_pc_select_id, alu_subunit_res_sel_id, rf_w_select_id;
    reg ecall_id, ebreak_id, mret_id, wfi_id;
    reg [3:0] ldst_mask_id;
    reg ldst_is_unsigned_id;
    reg st_en_id;
    reg [3:0] alu_subunit_op_sel_id;
    wire [4:0] rs1_addr_id, rs2_addr_id, rd_addr_id;
    reg [31:0] instr_id;
    reg [OP_LENGTH-1:0] pc_id, pc_plus4_id;
    wire bypass_ex_result_rs1_id, bypass_ex_result_rs2_id;
    wire bypass_me_result_rs1_id, bypass_me_result_rs2_id;
    wire [31:0] imm_id;
    reg filled_id;
    reg illegal_instr_id;


    // EX
    reg alu_imm_select_ex, alu_cu_input_sel, w_en_rf_ex, branch_ex, jal_ex, jalr_ex;
    reg [1:0] alu_pc_select_ex, alu_subunit_res_sel, rf_w_select_ex;
    reg ecall_ex, ebreak_ex, mret_ex, wfi_ex;
    reg [3:0] ldst_mask_ex;
    reg ldst_is_unsigned_ex;
    reg st_en_ex;
    reg [3:0] alu_subunit_op_sel;
    wire make_nop_ex;
    reg [4:0] rd_addr_ex;
    wire [OP_LENGTH-1:0] alu_opd1, alu_opd2, alu_mux1_out, alu_mux2_out;
    wire [OP_LENGTH-1:0] alu_result, comp_result;
    reg [OP_LENGTH-1:0] pc_ex, pc_plus4_ex;
    wire [31:0] rs1_data_ex, rs2_data_ex;
    reg [4:0] rs1_addr_ex, rs2_addr_ex;
    reg [31:0] instr_ex;
    reg [31:0] imm_ex;
    reg filled_ex;
    reg illegal_instr_ex;
    wire illegal_csr_prel_ex, illegal_csr_ex;
    wire illegal_wfi_prel_ex, illegal_wfi_ex;
    wire instr_access_misaligned;

    reg bypass_alu_ready, bypass_csr_ready, bypass_ld_ready, bypass_mem_ready;
    reg bypass_ex_result_rs1_ex, bypass_ex_result_rs2_ex;
    reg bypass_me_result_rs1_ex, bypass_me_result_rs2_ex;
    reg [OP_LENGTH-1:0] alu_result_bypass_buffer_ex, csr_result_bypass_buffer_ex;

    wire [OP_LENGTH-1:0] csr_unit_out, csr_in;
    wire csr_unit_r_en, csr_unit_w_en;
    wire csr_imm_select;
    wire [11:0] csr_unit_addr;
    wire [2:0] csr_unit_op;

    wire msi_ex, mti_ex, mei_ex;


    // ME
    wire [31:0] rd_write_data;
    wire [OP_LENGTH-1:0] mem_acc_in, mem_acc_out;
    wire is_misaligned, is_misalignment_store;
    reg bypass_me_result_rs1_me, bypass_me_result_rs2_me;
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
    reg [OP_LENGTH-1:0] pc_me, pc_plus4_me;
    reg [31:0] instr_me;
    wire is_load_ongoing, is_store_ongoing;
    wire mem_enb_buf;
    reg ready_for_mem_acc;
    wire cpu_stall;
    reg filled_me;
    reg illegal_instr_me;
    

    // WB
    reg [OP_LENGTH-1:0] alu_result_wb;
    reg [OP_LENGTH-1:0] mem_acc_out_wb;
    reg [OP_LENGTH-1:0] csr_unit_out_wb;
    reg [1:0] rf_w_select_wb;
    reg w_en_rf_wb;
    reg make_nop_wb;
    reg [4:0] rd_addr_wb;
    reg [OP_LENGTH-1:0] pc_plus4_wb;
    reg filled_wb;
    reg illegal_instr_wb;
    

    //
    // STAGE 1: Instruction Fetch (IF) + Control Logic
    //

    wire ctrl_alu_imm_select_out;
    wire [1:0] ctrl_alu_pc_select_out;
    wire [1:0] ctrl_rf_w_select_out;
    wire ctrl_alu_cu_input_sel_out;
    wire [1:0] ctrl_alu_subunit_res_sel_out;
    wire [3:0] ctrl_alu_subunit_op_sel_out;
    wire ctrl_w_en_rf_if_out;
    wire ctrl_branch_out;
    wire ctrl_jal_out;
    wire ctrl_jalr_out;
    wire ctrl_ecall_out;
    wire ctrl_ebreak_out;
    wire ctrl_mret_out;
    wire ctrl_wfi_out;
    wire [3:0] ctrl_ldst_mask_out;
    wire ctrl_ldst_is_unsigned_out;
    wire ctrl_st_en_if_out;

    control_unit control_unit_cpu
        (
            .clk(sysclk),
            .rst(rst),
            .stall(cpu_stall),
            .fetch_instr(mem_if_en_o),
            .instr(mem_instr_i),
            .is_misaligned(is_misaligned),
            .instr_access_misaligned(instr_access_misaligned),
            .alu_imm_select(ctrl_alu_imm_select_out),
            .alu_pc_select(ctrl_alu_pc_select_out),
            .rf_w_select(ctrl_rf_w_select_out),
            .alu_cu_input_sel(ctrl_alu_cu_input_sel_out),
            .alu_subunit_res_sel(ctrl_alu_subunit_res_sel_out),
            .alu_subunit_op_sel(ctrl_alu_subunit_op_sel_out),
            .w_en_rf_if(ctrl_w_en_rf_if_out),
            .branch(ctrl_branch_out),
            .jal(ctrl_jal_out),
            .jalr(ctrl_jalr_out),
            .ecall(ctrl_ecall_out),
            .ebreak(ctrl_ebreak_out),
            .mret(ctrl_mret_out),
            .wfi(ctrl_wfi_out),
            .ldst_mask(ctrl_ldst_mask_out),
            .ldst_is_unsigned(ctrl_ldst_is_unsigned_out),
            .st_en_if(ctrl_st_en_if_out),
            .csr_r_en(csr_unit_r_en),
            .csr_w_en(csr_unit_w_en),
            .csr_op(csr_unit_op),
            .csr_addr(csr_unit_addr),
            .csr_imm_select(csr_imm_select),
            .branch_true(comp_result[0]),
            .make_nop(make_nop_ex),
            .illegal_instr(illegal_instr_if),
            .illegal_instr_csr_ex(illegal_instr_ex || illegal_csr_ex || illegal_wfi_ex),
            .msi_i(msi_ex),
            .mti_i(mti_ex),
            .mei_i(mei_ex)
        );

    always @(posedge sysclk)
    begin
        if(!cpu_stall) begin
            instr_id <= mem_instr_i;
            alu_imm_select_id <= ctrl_alu_imm_select_out;
            alu_pc_select_id <= ctrl_alu_pc_select_out;
            rf_w_select_id <= ctrl_rf_w_select_out;
            alu_cu_input_sel_id <= ctrl_alu_cu_input_sel_out;
            alu_subunit_res_sel_id <= ctrl_alu_subunit_res_sel_out;
            alu_subunit_op_sel_id <= ctrl_alu_subunit_op_sel_out;
            w_en_rf_id <= ctrl_w_en_rf_if_out;
            branch_id <= ctrl_branch_out;
            jal_id <= ctrl_jal_out;
            jalr_id <= ctrl_jalr_out;
            ecall_id <= ctrl_ecall_out;
            ebreak_id <= ctrl_ebreak_out;
            mret_id <= ctrl_mret_out;
            wfi_id <= ctrl_wfi_out;
            ldst_mask_id <= ctrl_ldst_mask_out;
            ldst_is_unsigned_id <= ctrl_ldst_is_unsigned_out;
            st_en_id <= ctrl_st_en_if_out;
            illegal_instr_id <= illegal_instr_if;
        end
    end

    pc_counter #(.OPD_WIDTH(OP_LENGTH), .PC_WIDTH(PC_WIDTH), .RESET_ADDR(RESET_ADDR)) 
        pc_counter_cpu
        (
            .clk(sysclk),
            .rst(rst),
            .stall(cpu_stall),
            .branch(branch_ex && !make_nop_ex),
            .jal(jal_ex && !make_nop_ex),
            .jalr(jalr_ex && !make_nop_ex),
            .csr_sel((ecall_ex || ebreak_ex || mret_ex || is_misaligned || illegal_instr_ex || illegal_csr_ex || illegal_wfi_ex || instr_access_misaligned) && !make_nop_ex),
            .alu_result(alu_result),
            .comp_result(comp_result),
            .csr_out(csr_unit_out),
            .pc_out(pc_if),
            .pc_plus4(pc_plus4_if),
            .next_pc(next_pc)
        );

    assign mem_addra_o = next_pc[14:2];
    assign instr_access_misaligned = !make_nop_ex && ((((branch_ex && comp_result) || jal_ex) && (alu_result[1] || alu_result[0])) || (jalr_ex && alu_result[1]));
    
    always @(posedge sysclk)
    begin
        if(!cpu_stall) begin
            pc_id <= pc_if;
            pc_ex <= pc_id;
            pc_plus4_id <= pc_plus4_if;
            pc_plus4_ex <= pc_plus4_id;
        end
    end

    // 
    // STAGE 2: Instruction Decode (ID)
    //

    instruction_decoder #(.OPD_LENGTH(OP_LENGTH), .REG_WIDTH(32)) 
        instruction_decoder_cpu
        (
            .clk(sysclk),
            .rst(rst),
            .instr(instr_id),
            .stall(cpu_stall),
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
        if(!cpu_stall) begin
            instr_ex <= instr_id;
            imm_ex <= imm_id;
        end
    end

    always @(posedge sysclk)
    begin
        if(!cpu_stall) begin
            alu_imm_select_ex <= alu_imm_select_id;
            alu_pc_select_ex <= alu_pc_select_id;
            rf_w_select_ex <= rf_w_select_id;
            alu_cu_input_sel <= alu_cu_input_sel_id;
            alu_subunit_res_sel <= alu_subunit_res_sel_id;
            alu_subunit_op_sel <= alu_subunit_op_sel_id;
            w_en_rf_ex <= w_en_rf_id;
            branch_ex <= branch_id;
            jal_ex <= jal_id;
            jalr_ex <= jalr_id;
            ecall_ex <= ecall_id;
            ebreak_ex <= ebreak_id;
            mret_ex <= mret_id;
            wfi_ex <= wfi_id;
            ldst_mask_ex <= ldst_mask_id;
            ldst_is_unsigned_ex <= ldst_is_unsigned_id;
            st_en_ex <= st_en_id;
            rd_addr_ex <= rd_addr_id;
            illegal_instr_ex <= illegal_instr_id;
            bypass_ex_result_rs1_ex <= bypass_ex_result_rs1_id;
            bypass_ex_result_rs2_ex <= bypass_ex_result_rs2_id;
            bypass_me_result_rs1_ex <= bypass_me_result_rs1_id;
            bypass_me_result_rs2_ex <= bypass_me_result_rs2_id;
            bypass_me_result_rs1_me <= bypass_me_result_rs1_ex;
            bypass_me_result_rs2_me <= bypass_me_result_rs2_ex;
        end
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
            .cu_input_sel(alu_cu_input_sel),
            .subunit_res_sel(alu_subunit_res_sel),
            .subunit_op_sel(alu_subunit_op_sel),
            .alu_result(alu_result),
            .comp_result(comp_result)
        );

    always @(posedge sysclk)
    begin
        if(!cpu_stall) begin
            rs1_addr_ex <= rs1_addr_id;
            rs2_addr_ex <= rs2_addr_id;

            alu_result_bypass_buffer_ex <= alu_result;
            csr_result_bypass_buffer_ex <= csr_unit_out;
        end
    end

    always @(posedge sysclk)
    begin
        bypass_alu_ready <= 1'b0;
        bypass_csr_ready <= 1'b0;
        bypass_ld_ready <= 1'b0;
        
        if(w_en_rf_ex && !make_nop_ex && !cpu_stall)
        begin
            if(rf_w_select_ex == 2'b00)
                bypass_alu_ready <= 1'b1;
            else if(rf_w_select_ex == 2'b01)
                bypass_ld_ready <= 1'b1;
            else if(rf_w_select_ex == 2'b11)
                bypass_csr_ready <= 1'b1;
        end
    end

    assign alu_opd1 = (bypass_ex_result_rs1_ex && bypass_alu_ready) ? alu_result_bypass_buffer_ex
                    : (bypass_ex_result_rs1_ex && bypass_csr_ready) ? csr_result_bypass_buffer_ex
                    : (bypass_ex_result_rs1_ex && bypass_ld_ready)  ? mem_acc_out
                    : (bypass_ex_result_rs1_ex && is_load_ongoing && mem_rdata_valid_i) ? mem_acc_out
                    : (bypass_me_result_rs1_ex && bypass_mem_ready) ? rd_write_data // mem_result_bypass_buffer_me
                    : rs1_data_ex;
    assign alu_opd2 = (bypass_ex_result_rs2_ex && bypass_alu_ready) ? alu_result_bypass_buffer_ex
                    : (bypass_ex_result_rs2_ex && bypass_csr_ready) ? csr_result_bypass_buffer_ex
                    : (bypass_ex_result_rs2_ex && bypass_ld_ready)  ? mem_acc_out
                    : (bypass_ex_result_rs2_ex && is_load_ongoing && mem_rdata_valid_i) ? mem_acc_out
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

    two_input_mux #(.INPUT_LENGTH(32)) csr_unit_mux
        (
            .a(alu_opd1),
            .b(imm_ex),
            .sel(csr_imm_select),
            .z(csr_in)
        );
    
    csr_unit #(.CSR_ADDR_WIDTH(12)) csr_unit_cpu
        (
            .clk(sysclk),
            .rst(rst),
            .r_en(csr_unit_r_en && !make_nop_ex && !cpu_stall),
            .w_en(csr_unit_w_en && !make_nop_ex && !cpu_stall),
            .ecall(ecall_ex && !make_nop_ex && !cpu_stall),
            .ebreak(ebreak_ex && !make_nop_ex && !cpu_stall),
            .mret(mret_ex && !make_nop_ex && !cpu_stall),
            .jalr(jalr_ex),
            .wfi(wfi_ex),
            .pc(pc_ex),
            .op(csr_unit_op),
            .in(csr_in),
            .csr_addr(csr_unit_addr),
            .out(csr_unit_out),
            .is_misaligned(is_misaligned),
            .is_misalignment_store(is_misalignment_store),
            .misaligned_store_value(alu_opd2),
            .mem_addr(alu_result[14:0]),
            .rd_addr(rd_addr_ex),
            .instr(instr_ex),
            .illegal_instr(illegal_instr_ex && !make_nop_ex),
            .illegal_csr_o(illegal_csr_prel_ex),
            .illegal_wfi_o(illegal_wfi_prel_ex),
            .instr_access_misaligned(instr_access_misaligned && !make_nop_ex),
            .instr_addr(alu_result),
            .msi(msi_ex),
            .mti(mti_ex),
            .mei(mei_ex)
        );

    assign is_misaligned = ((ldst_mask_ex == 4'b1111 && alu_result[1:0] != 2'b00) || (ldst_mask_ex == 4'b0011 && alu_result[0] != 1'b0)) && !make_nop_ex && !cpu_stall;
    assign is_misalignment_store = is_misaligned && st_en_ex && !make_nop_ex && !cpu_stall;
    assign illegal_csr_ex = illegal_csr_prel_ex && !make_nop_ex;
    assign illegal_wfi_ex = illegal_wfi_prel_ex && !make_nop_ex;

    // 
    // STAGE 4: Memory Access (ME)
    //

    always @(posedge sysclk)
    begin
        if(!cpu_stall) begin
            make_nop_me <= make_nop_ex || is_misaligned || illegal_csr_ex || instr_access_misaligned;
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
            illegal_instr_me <= illegal_instr_ex;
        end
    end

    memory_access_unit #(.BYTE_WIDTH(8))
        memory_access_unit_cpu
        (
            .clk(sysclk),
            .rst(rst),
            .make_nop_i(make_nop_me),
            .addr_in(alu_result_me),
            .addr_out(mem_addrb_o),
            .ldst_mask(ldst_mask_me),
            .ldst_is_unsigned(ldst_is_unsigned_me),
            .st_en(st_en_me && !make_nop_me && ready_for_mem_acc),
            .in(mem_acc_in),
            .out(mem_acc_out),
            .wr_mode(mem_wr_mode_o),
            .is_mem_rdata_valid_i(mem_rdata_valid_i),
            .is_mem_wdata_valid_i(mem_wdata_valid_i),
            .is_load_ongoing_o(is_load_ongoing),
            .is_store_ongoing_o(is_store_ongoing),
            .ready_for_mem_acc_i(ready_for_mem_acc),
            .mem_enb_o(mem_enb_buf)
        );

    assign mem_acc_in = (st_en_me == 1'b1) ? alu_opd2_me : mem_rdata_i;

    assign mem_dinb_o = mem_acc_out;
    assign mem_enb_o = mem_enb_buf && ready_for_mem_acc;

    assign cpu_stall = filled_me && !(mem_rdata_valid_i || mem_wdata_valid_i) && ((mem_enb_buf && ready_for_mem_acc) || ((is_load_ongoing && !mem_rdata_valid_i) || (is_store_ongoing && !mem_wdata_valid_i)));

    always @(posedge sysclk) begin
        ready_for_mem_acc <= !cpu_stall;

        if(w_en_rf_me && !make_nop_me)
            bypass_mem_ready <= 1'b1;
        else
            bypass_mem_ready <= 1'b0;

        if(rst) begin
            ready_for_mem_acc <= 1'b1;
            bypass_mem_ready <= 1'b0;
        end
    end

    //
    // STAGE 5: Register Writeback (WB)
    //

    always @(posedge sysclk)
    begin
        if(!cpu_stall) begin
            alu_result_wb <= alu_result_me;
            mem_acc_out_wb <= mem_acc_out;
            pc_plus4_wb <= pc_plus4_me;
            csr_unit_out_wb <= csr_unit_out_me;
            rf_w_select_wb <= rf_w_select_me;
            w_en_rf_wb <= w_en_rf_me;
            make_nop_wb <= make_nop_me;
            rd_addr_wb <= rd_addr_me;
            illegal_instr_wb <= illegal_instr_me;
        end
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
            .w_en(w_en_rf_wb && !make_nop_wb && (!cpu_stall || (cpu_stall && ready_for_mem_acc)) && !illegal_instr_wb),
            .rs1_addr(rs1_addr_ex),
            .rs2_addr(rs2_addr_ex),
            .rd_addr(rd_addr_wb),
            .rs1_data(rs1_data_ex),
            .rs2_data(rs2_data_ex),
            .rd_write_data(rd_write_data)
        );

    always @(posedge sysclk) begin
        filled_if <= 1'b1;
        filled_id <= filled_if;
        filled_ex <= filled_id;
        filled_me <= filled_ex;
        filled_wb <= filled_me;

        if(cpu_stall) begin
            filled_if <= 1'b1;
            filled_id <= 1'b1;
            filled_ex <= 1'b1;
            filled_me <= 1'b1;
            filled_wb <= filled_wb;
        end

        if(rst) begin
            filled_if <= 1'b0;
            filled_id <= 1'b0;
            filled_ex <= 1'b0;
            filled_me <= 1'b0;
            filled_wb <= 1'b0;
        end
    end

endmodule