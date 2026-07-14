// CSR unit
// Created:     2025-05-25
// Modified:    2026-07-14
// Author:      Kagan Dikmen

module csr_unit
    #(
    parameter CSR_ADDR_WIDTH = 12
    )(
    input clk,
    input rst,

    input r_en,
    input w_en,

    input ecall,
    input ebreak,
    input [31:0] pc,

    input mret,

    input [2:0] op,
    input [31:0] in,
    input [CSR_ADDR_WIDTH-1:0] csr_addr,

    output reg [31:0] out,

    input is_misaligned,
    input is_misalignment_store,
    input [31:0] misaligned_store_value,
    input [14:0] mem_addr,
    input [4:0] rd_addr,

    input [31:0] instr,
    input illegal_instr,
    output illegal_csr,

    input instr_access_misaligned,
    input [31:0] instr_addr,

    output msi,
    output mti,
    output mei
    );

    `include "common_library.vh"

    localparam SPEC_CSR_JVT_INDEX           = 0;
    localparam SPEC_CSR_MSTATUS_INDEX       = 1;
    localparam SPEC_CSR_MISA_INDEX          = 2;
    localparam SPEC_CSR_MEDELEG_INDEX       = 3;    
    localparam SPEC_CSR_MIDELEG_INDEX       = 4;
    localparam SPEC_CSR_MIE_INDEX           = 5;
    localparam SPEC_CSR_MTVEC_INDEX         = 6;
    localparam SPEC_CSR_MCOUNTEREN_INDEX    = 7;
    localparam SPEC_CSR_MSTATUSH_INDEX      = 8;
    localparam SPEC_CSR_MEDELEGH_INDEX      = 9;
    localparam SPEC_CSR_MTVT_INDEX          = 10;
    localparam SPEC_CSR_MSCRATCH_INDEX      = 11;
    localparam SPEC_CSR_MEPC_INDEX          = 12;
    localparam SPEC_CSR_MCAUSE_INDEX        = 13;
    localparam SPEC_CSR_MTVAL_INDEX         = 14;
    localparam SPEC_CSR_MIP_INDEX           = 15;
    localparam SPEC_CSR_MTINST_INDEX        = 16;
    localparam SPEC_CSR_MTVAL2_INDEX        = 17;
    localparam SPEC_CSR_MVENDORID_INDEX     = 18;
    localparam SPEC_CSR_MARCHID_INDEX       = 19;
    localparam SPEC_CSR_MIMPID_INDEX        = 20;
    localparam SPEC_CSR_MHARTID_INDEX       = 21;
    localparam SPEC_CSR_MCONFIGPTR_INDEX    = 22;

    reg spec_reg_r_en, spec_reg_w_en;
    reg [31:0] write_value;
    reg [31:0] spec_csr_registers [22:0];

    reg [1:0] current_priv;

    reg not_csr;
    reg write_to_ro_csr;

    wire msi_en, mti_en, mei_en;
    wire msip, mtip, meip;
    wire msie, mtie, meie;

    assign msip = spec_csr_registers[SPEC_CSR_MIP_INDEX][3];
    assign mtip = spec_csr_registers[SPEC_CSR_MIP_INDEX][7];
    assign meip = spec_csr_registers[SPEC_CSR_MIP_INDEX][11];

    assign msie = spec_csr_registers[SPEC_CSR_MIE_INDEX][3];
    assign mtie = spec_csr_registers[SPEC_CSR_MIE_INDEX][7];
    assign meie = spec_csr_registers[SPEC_CSR_MIE_INDEX][11];

    assign msi_en = msip && msie && spec_csr_registers[SPEC_CSR_MSTATUS_INDEX][3];
    assign mti_en = mtip && mtie && spec_csr_registers[SPEC_CSR_MSTATUS_INDEX][3];
    assign mei_en = meip && meie && spec_csr_registers[SPEC_CSR_MSTATUS_INDEX][3];

    assign msi = msi_en;
    assign mti = mti_en;
    assign mei = mei_en;

    // write
    always @(posedge clk)
    begin
        if (rst == 1'b1)
        begin
            current_priv <= 2'b11;  // boot the chip in M mode

            spec_csr_registers[SPEC_CSR_JVT_INDEX]          <= CSR_JVT_RST;
            spec_csr_registers[SPEC_CSR_MSTATUS_INDEX]      <= CSR_MSTATUS_RST;
            spec_csr_registers[SPEC_CSR_MISA_INDEX]         <= CSR_MISA_RST;
            spec_csr_registers[SPEC_CSR_MEDELEG_INDEX]      <= CSR_MEDELEG_RST;
            spec_csr_registers[SPEC_CSR_MIDELEG_INDEX]      <= CSR_MIDELEG_RST;
            spec_csr_registers[SPEC_CSR_MIE_INDEX]          <= CSR_MIE_RST;
            spec_csr_registers[SPEC_CSR_MTVEC_INDEX]        <= CSR_MTVEC_RST;
            spec_csr_registers[SPEC_CSR_MCOUNTEREN_INDEX]   <= CSR_MCOUNTEREN_RST;
            spec_csr_registers[SPEC_CSR_MSTATUSH_INDEX]     <= CSR_MSTATUSH_RST;
            spec_csr_registers[SPEC_CSR_MEDELEGH_INDEX]     <= CSR_MEDELEGH_RST;
            spec_csr_registers[SPEC_CSR_MTVT_INDEX]         <= CSR_MTVT_RST;
            spec_csr_registers[SPEC_CSR_MSCRATCH_INDEX]     <= CSR_MSCRATCH_RST;
            spec_csr_registers[SPEC_CSR_MEPC_INDEX]         <= CSR_MEPC_RST;
            spec_csr_registers[SPEC_CSR_MCAUSE_INDEX]       <= CSR_MCAUSE_RST;
            spec_csr_registers[SPEC_CSR_MTVAL_INDEX]        <= CSR_MTVAL_RST;
            spec_csr_registers[SPEC_CSR_MIP_INDEX]          <= CSR_MIP_RST;
            spec_csr_registers[SPEC_CSR_MTINST_INDEX]       <= CSR_MTINST_RST;
            spec_csr_registers[SPEC_CSR_MTVAL2_INDEX]       <= CSR_MTVAL2_RST;
            spec_csr_registers[SPEC_CSR_MVENDORID_INDEX]    <= CSR_MVENDORID_RST;
            spec_csr_registers[SPEC_CSR_MARCHID_INDEX]      <= CSR_MARCHID_RST;
            spec_csr_registers[SPEC_CSR_MIMPID_INDEX]       <= CSR_MIMPID_RST;
            spec_csr_registers[SPEC_CSR_MHARTID_INDEX]      <= CSR_MHARTID_RST;
            spec_csr_registers[SPEC_CSR_MCONFIGPTR_INDEX]   <= CSR_MCONFIGPTR_RST;
        end
        else if (mret == 1'b1)
        begin
            spec_csr_registers[SPEC_CSR_MSTATUS_INDEX][3] <= spec_csr_registers[SPEC_CSR_MSTATUS_INDEX][7];
            spec_csr_registers[SPEC_CSR_MSTATUS_INDEX][7] <= 1'b1;
            spec_csr_registers[SPEC_CSR_MSTATUS_INDEX][12:11] <= 2'b11;     // set back to least-privileged mode supported (M)
            current_priv <= spec_csr_registers[SPEC_CSR_MSTATUS_INDEX][12:11];
        end
        else if (ecall || ebreak)
        begin
            spec_csr_registers[SPEC_CSR_MEPC_INDEX]     <= pc;
            spec_csr_registers[SPEC_CSR_MCAUSE_INDEX]   <= (ecall) ? 32'd11 : 32'd3;
            spec_csr_registers[SPEC_CSR_MTVAL_INDEX]    <= 'b0;

            spec_csr_registers[SPEC_CSR_MSTATUS_INDEX][7] <= spec_csr_registers[SPEC_CSR_MSTATUS_INDEX][3];
            spec_csr_registers[SPEC_CSR_MSTATUS_INDEX][3] <= 1'b0;
            spec_csr_registers[SPEC_CSR_MSTATUS_INDEX][12:11] <= current_priv;
            current_priv <= 2'b11;
        end
        else if (is_misaligned)
        begin
            spec_csr_registers[SPEC_CSR_MEPC_INDEX]     <= pc;
            spec_csr_registers[SPEC_CSR_MCAUSE_INDEX]   <= (is_misalignment_store) ? 32'd6 : 32'd4;
            spec_csr_registers[SPEC_CSR_MSCRATCH_INDEX] <= in;     // saves the instruction word
            spec_csr_registers[SPEC_CSR_MTVAL_INDEX]    <= {17'b0, mem_addr};
            spec_csr_registers[SPEC_CSR_MTVAL2_INDEX]   <= (is_misalignment_store) ? misaligned_store_value : {27'b0, rd_addr};

            spec_csr_registers[SPEC_CSR_MSTATUS_INDEX][7] <= spec_csr_registers[SPEC_CSR_MSTATUS_INDEX][3];
            spec_csr_registers[SPEC_CSR_MSTATUS_INDEX][3] <= 1'b0;
            spec_csr_registers[SPEC_CSR_MSTATUS_INDEX][12:11] <= current_priv;
            current_priv <= 2'b11;
        end
        else if (illegal_instr || illegal_csr)
        begin
            spec_csr_registers[SPEC_CSR_MEPC_INDEX]     <= pc;
            spec_csr_registers[SPEC_CSR_MCAUSE_INDEX]   <= 32'd2;
            spec_csr_registers[SPEC_CSR_MTVAL_INDEX]    <= instr;

            spec_csr_registers[SPEC_CSR_MSTATUS_INDEX][7] <= spec_csr_registers[SPEC_CSR_MSTATUS_INDEX][3];
            spec_csr_registers[SPEC_CSR_MSTATUS_INDEX][3] <= 1'b0;
            spec_csr_registers[SPEC_CSR_MSTATUS_INDEX][12:11] <= current_priv;
            current_priv <= 2'b11;
        end
        else if (instr_access_misaligned)
        begin
            spec_csr_registers[SPEC_CSR_MEPC_INDEX]     <= pc;
            spec_csr_registers[SPEC_CSR_MCAUSE_INDEX]   <= 32'd0;
            spec_csr_registers[SPEC_CSR_MTVAL_INDEX]    <= instr_addr;

            spec_csr_registers[SPEC_CSR_MSTATUS_INDEX][7] <= spec_csr_registers[SPEC_CSR_MSTATUS_INDEX][3];
            spec_csr_registers[SPEC_CSR_MSTATUS_INDEX][3] <= 1'b0;
            spec_csr_registers[SPEC_CSR_MSTATUS_INDEX][12:11] <= current_priv;
            current_priv <= 2'b11;
        end
        else if (msi_en)
        begin
            spec_csr_registers[SPEC_CSR_MEPC_INDEX]     <= pc;
            spec_csr_registers[SPEC_CSR_MCAUSE_INDEX]   <= {1'b1, 31'd3};

            spec_csr_registers[SPEC_CSR_MSTATUS_INDEX][7] <= spec_csr_registers[SPEC_CSR_MSTATUS_INDEX][3];
            spec_csr_registers[SPEC_CSR_MSTATUS_INDEX][3] <= 1'b0;
            spec_csr_registers[SPEC_CSR_MSTATUS_INDEX][12:11] <= current_priv;
            current_priv <= 2'b11;
        end
        else if (mti_en)
        begin
            spec_csr_registers[SPEC_CSR_MEPC_INDEX]     <= pc;
            spec_csr_registers[SPEC_CSR_MCAUSE_INDEX]   <= {1'b1, 31'd7};

            spec_csr_registers[SPEC_CSR_MSTATUS_INDEX][7] <= spec_csr_registers[SPEC_CSR_MSTATUS_INDEX][3];
            spec_csr_registers[SPEC_CSR_MSTATUS_INDEX][3] <= 1'b0;
            spec_csr_registers[SPEC_CSR_MSTATUS_INDEX][12:11] <= current_priv;
            current_priv <= 2'b11;
        end
        else if (mei_en)
        begin
            spec_csr_registers[SPEC_CSR_MEPC_INDEX]     <= pc;
            spec_csr_registers[SPEC_CSR_MCAUSE_INDEX]   <= {1'b1, 31'd11};

            spec_csr_registers[SPEC_CSR_MSTATUS_INDEX][7] <= spec_csr_registers[SPEC_CSR_MSTATUS_INDEX][3];
            spec_csr_registers[SPEC_CSR_MSTATUS_INDEX][3] <= 1'b0;
            spec_csr_registers[SPEC_CSR_MSTATUS_INDEX][12:11] <= current_priv;
            current_priv <= 2'b11;
        end
        else if (spec_reg_w_en)
        begin
            case(csr_addr)
                CSR_JVT_ADDR:          spec_csr_registers[SPEC_CSR_JVT_INDEX]           <= write_value;
                CSR_MSTATUS_ADDR:      spec_csr_registers[SPEC_CSR_MSTATUS_INDEX]       <= write_value;
                CSR_MISA_ADDR:         spec_csr_registers[SPEC_CSR_MISA_INDEX]          <= write_value;
                CSR_MEDELEG_ADDR:      spec_csr_registers[SPEC_CSR_MEDELEG_INDEX]       <= write_value;
                CSR_MIDELEG_ADDR:      spec_csr_registers[SPEC_CSR_MIDELEG_INDEX]       <= write_value;
                CSR_MIE_ADDR:          spec_csr_registers[SPEC_CSR_MIE_INDEX]           <= write_value;
                CSR_MTVEC_ADDR:        spec_csr_registers[SPEC_CSR_MTVEC_INDEX]         <= write_value;
                CSR_MCOUNTEREN_ADDR:   spec_csr_registers[SPEC_CSR_MCOUNTEREN_INDEX]    <= write_value;
                CSR_MSTATUSH_ADDR:     spec_csr_registers[SPEC_CSR_MSTATUSH_INDEX]      <= write_value;
                CSR_MEDELEGH_ADDR:     spec_csr_registers[SPEC_CSR_MEDELEGH_INDEX]      <= write_value;
                CSR_MTVT_ADDR:         spec_csr_registers[SPEC_CSR_MTVT_INDEX]          <= write_value;
                CSR_MSCRATCH_ADDR:     spec_csr_registers[SPEC_CSR_MSCRATCH_INDEX]      <= write_value;
                CSR_MEPC_ADDR:         spec_csr_registers[SPEC_CSR_MEPC_INDEX]          <= write_value;
                CSR_MCAUSE_ADDR:       spec_csr_registers[SPEC_CSR_MCAUSE_INDEX]        <= write_value;
                CSR_MTVAL_ADDR:        spec_csr_registers[SPEC_CSR_MTVAL_INDEX]         <= write_value;
                CSR_MIP_ADDR:          spec_csr_registers[SPEC_CSR_MIP_INDEX]           <= write_value;
                CSR_MTINST_ADDR:       spec_csr_registers[SPEC_CSR_MTINST_INDEX]        <= write_value;
                CSR_MTVAL2_ADDR:       spec_csr_registers[SPEC_CSR_MTVAL2_INDEX]        <= write_value;
            endcase
        end
    end

    always @(*)
    begin
        spec_reg_r_en = 1'b0;
        spec_reg_w_en = 1'b0;
        not_csr = 1'b0;
        write_to_ro_csr = 1'b0;
        
        if(csr_addr == CSR_JVT_ADDR 
            || csr_addr == CSR_MSTATUS_ADDR
            || csr_addr == CSR_MISA_ADDR
            || csr_addr == CSR_MEDELEG_ADDR
            || csr_addr == CSR_MIDELEG_ADDR
            || csr_addr == CSR_MIE_ADDR
            || csr_addr == CSR_MTVEC_ADDR
            || csr_addr == CSR_MCOUNTEREN_ADDR
            || csr_addr == CSR_MSTATUSH_ADDR
            || csr_addr == CSR_MEDELEGH_ADDR
            || csr_addr == CSR_MTVT_ADDR
            || csr_addr == CSR_MSCRATCH_ADDR
            || csr_addr == CSR_MEPC_ADDR
            || csr_addr == CSR_MCAUSE_ADDR
            || csr_addr == CSR_MTVAL_ADDR
            || csr_addr == CSR_MIP_ADDR
            || csr_addr == CSR_MTINST_ADDR
            || csr_addr == CSR_MTVAL2_ADDR)
        begin
            spec_reg_r_en = r_en;
            spec_reg_w_en = w_en;
        end
        else if(csr_addr == CSR_MVENDORID_ADDR
            || csr_addr == CSR_MARCHID_ADDR
            || csr_addr == CSR_MIMPID_ADDR
            || csr_addr == CSR_MHARTID_ADDR
            || csr_addr == CSR_MCONFIGPTR_ADDR)
        begin
            spec_reg_r_en = r_en;
            write_to_ro_csr = w_en;
        end
        else
        begin
            not_csr = 1'b1;
        end
    end

    always @(negedge clk)
    begin
        out <= 'b0;

        if(spec_reg_r_en)
        begin
            case(csr_addr)
                CSR_JVT_ADDR:          out <= spec_csr_registers[SPEC_CSR_JVT_INDEX];
                CSR_MSTATUS_ADDR:      out <= spec_csr_registers[SPEC_CSR_MSTATUS_INDEX];
                CSR_MISA_ADDR:         out <= spec_csr_registers[SPEC_CSR_MISA_INDEX];
                CSR_MEDELEG_ADDR:      out <= spec_csr_registers[SPEC_CSR_MEDELEG_INDEX];
                CSR_MIDELEG_ADDR:      out <= spec_csr_registers[SPEC_CSR_MIDELEG_INDEX];
                CSR_MIE_ADDR:          out <= spec_csr_registers[SPEC_CSR_MIE_INDEX];
                CSR_MTVEC_ADDR:        out <= spec_csr_registers[SPEC_CSR_MTVEC_INDEX];
                CSR_MCOUNTEREN_ADDR:   out <= spec_csr_registers[SPEC_CSR_MCOUNTEREN_INDEX];
                CSR_MSTATUSH_ADDR:     out <= spec_csr_registers[SPEC_CSR_MSTATUSH_INDEX];
                CSR_MEDELEGH_ADDR:     out <= spec_csr_registers[SPEC_CSR_MEDELEGH_INDEX];
                CSR_MTVT_ADDR:         out <= spec_csr_registers[SPEC_CSR_MTVT_INDEX];
                CSR_MSCRATCH_ADDR:     out <= spec_csr_registers[SPEC_CSR_MSCRATCH_INDEX];
                CSR_MEPC_ADDR:         out <= spec_csr_registers[SPEC_CSR_MEPC_INDEX];
                CSR_MCAUSE_ADDR:       out <= spec_csr_registers[SPEC_CSR_MCAUSE_INDEX];
                CSR_MTVAL_ADDR:        out <= spec_csr_registers[SPEC_CSR_MTVAL_INDEX];
                CSR_MIP_ADDR:          out <= spec_csr_registers[SPEC_CSR_MIP_INDEX];
                CSR_MTINST_ADDR:       out <= spec_csr_registers[SPEC_CSR_MTINST_INDEX];
                CSR_MTVAL2_ADDR:       out <= spec_csr_registers[SPEC_CSR_MTVAL2_INDEX];
                CSR_MVENDORID_ADDR:    out <= spec_csr_registers[SPEC_CSR_MVENDORID_INDEX];
                CSR_MARCHID_ADDR:      out <= spec_csr_registers[SPEC_CSR_MARCHID_INDEX];
                CSR_MIMPID_ADDR:       out <= spec_csr_registers[SPEC_CSR_MIMPID_INDEX];
                CSR_MHARTID_ADDR:      out <= spec_csr_registers[SPEC_CSR_MHARTID_INDEX];
                CSR_MCONFIGPTR_ADDR:   out <= spec_csr_registers[SPEC_CSR_MCONFIGPTR_INDEX];
                default:               out <= 'b0;
            endcase
        end

        if(illegal_instr || illegal_csr || instr_access_misaligned) begin
            out <= spec_csr_registers[SPEC_CSR_MTVEC_INDEX];
        end
    end

    // write masking
    always @(*)
    begin
        casez (op)
            3'b?01:
                write_value = in;
            3'b?10:
                write_value = (out | in);
            3'b?11:
                write_value = (out & (~in));
            default:
                write_value = in;
        endcase
    end

    assign illegal_csr = ((r_en || w_en) && not_csr) || write_to_ro_csr;

endmodule
