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
    input jalr,
    input wfi,

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
    output illegal_csr_o,
    output illegal_wfi_o,

    input instr_access_misaligned,
    input [31:0] instr_addr,

    output msi,
    output mti,
    output mei
    );

    `include "common_library.vh"

    localparam CSR_RF_JVT_IDX           = 0;
    localparam CSR_RF_MSTATUS_IDX       = 1;
    localparam CSR_RF_MISA_IDX          = 2;
    localparam CSR_RF_MEDELEG_IDX       = 3;    
    localparam CSR_RF_MIDELEG_IDX       = 4;
    localparam CSR_RF_MIE_IDX           = 5;
    localparam CSR_RF_MTVEC_IDX         = 6;
    localparam CSR_RF_MCOUNTEREN_IDX    = 7;
    localparam CSR_RF_MSTATUSH_IDX      = 8;
    localparam CSR_RF_MEDELEGH_IDX      = 9;
    localparam CSR_RF_MTVT_IDX          = 10;
    localparam CSR_RF_MSCRATCH_IDX      = 11;
    localparam CSR_RF_MEPC_IDX          = 12;
    localparam CSR_RF_MCAUSE_IDX        = 13;
    localparam CSR_RF_MTVAL_IDX         = 14;
    localparam CSR_RF_MIP_IDX           = 15;
    localparam CSR_RF_MTINST_IDX        = 16;
    localparam CSR_RF_MTVAL2_IDX        = 17;
    localparam CSR_RF_MVENDORID_IDX     = 18;
    localparam CSR_RF_MARCHID_IDX       = 19;
    localparam CSR_RF_MIMPID_IDX        = 20;
    localparam CSR_RF_MHARTID_IDX       = 21;
    localparam CSR_RF_MCONFIGPTR_IDX    = 22;

    reg spec_reg_r_en, spec_reg_w_en;
    reg [31:0] write_value;
    reg [31:0] csr_rf [22:0];

    reg [1:0] current_priv;

    reg not_csr;
    reg write_to_ro_csr;
    wire illegal_csr, illegal_wfi;

    wire msi_en, mti_en, mei_en;
    wire msip, mtip, meip;
    wire msie, mtie, meie;

    wire mstatus_tw;

    assign msip = csr_rf[CSR_RF_MIP_IDX][3];
    assign mtip = csr_rf[CSR_RF_MIP_IDX][7];
    assign meip = csr_rf[CSR_RF_MIP_IDX][11];

    assign msie = csr_rf[CSR_RF_MIE_IDX][3];
    assign mtie = csr_rf[CSR_RF_MIE_IDX][7];
    assign meie = csr_rf[CSR_RF_MIE_IDX][11];

    assign msi_en = msip && msie && csr_rf[CSR_RF_MSTATUS_IDX][3];
    assign mti_en = mtip && mtie && csr_rf[CSR_RF_MSTATUS_IDX][3];
    assign mei_en = meip && meie && csr_rf[CSR_RF_MSTATUS_IDX][3];

    assign msi = msi_en;
    assign mti = mti_en;
    assign mei = mei_en;

    assign mstatus_tw = csr_rf[CSR_RF_MSTATUS_IDX][21];

    assign illegal_csr = ((r_en || w_en) && (not_csr || (current_priv < csr_addr[9:8]))) || write_to_ro_csr || (mret && (current_priv != 2'b11));
    assign illegal_csr_o = illegal_csr;

    assign illegal_wfi = wfi && (current_priv == 2'b00) && (mstatus_tw == 1'b1);
    assign illegal_wfi_o = illegal_wfi;

    // write
    always @(posedge clk)
    begin
        if (rst == 1'b1)
        begin
            current_priv <= 2'b11;  // boot the chip in M mode

            csr_rf[CSR_RF_JVT_IDX]          <= CSR_JVT_RST;
            csr_rf[CSR_RF_MSTATUS_IDX]      <= CSR_MSTATUS_RST;
            csr_rf[CSR_RF_MISA_IDX]         <= CSR_MISA_RST;
            csr_rf[CSR_RF_MEDELEG_IDX]      <= CSR_MEDELEG_RST;
            csr_rf[CSR_RF_MIDELEG_IDX]      <= CSR_MIDELEG_RST;
            csr_rf[CSR_RF_MIE_IDX]          <= CSR_MIE_RST;
            csr_rf[CSR_RF_MTVEC_IDX]        <= CSR_MTVEC_RST;
            csr_rf[CSR_RF_MCOUNTEREN_IDX]   <= CSR_MCOUNTEREN_RST;
            csr_rf[CSR_RF_MSTATUSH_IDX]     <= CSR_MSTATUSH_RST;
            csr_rf[CSR_RF_MEDELEGH_IDX]     <= CSR_MEDELEGH_RST;
            csr_rf[CSR_RF_MTVT_IDX]         <= CSR_MTVT_RST;
            csr_rf[CSR_RF_MSCRATCH_IDX]     <= CSR_MSCRATCH_RST;
            csr_rf[CSR_RF_MEPC_IDX]         <= CSR_MEPC_RST;
            csr_rf[CSR_RF_MCAUSE_IDX]       <= CSR_MCAUSE_RST;
            csr_rf[CSR_RF_MTVAL_IDX]        <= CSR_MTVAL_RST;
            csr_rf[CSR_RF_MIP_IDX]          <= CSR_MIP_RST;
            csr_rf[CSR_RF_MTINST_IDX]       <= CSR_MTINST_RST;
            csr_rf[CSR_RF_MTVAL2_IDX]       <= CSR_MTVAL2_RST;
            csr_rf[CSR_RF_MVENDORID_IDX]    <= CSR_MVENDORID_RST;
            csr_rf[CSR_RF_MARCHID_IDX]      <= CSR_MARCHID_RST;
            csr_rf[CSR_RF_MIMPID_IDX]       <= CSR_MIMPID_RST;
            csr_rf[CSR_RF_MHARTID_IDX]      <= CSR_MHARTID_RST;
            csr_rf[CSR_RF_MCONFIGPTR_IDX]   <= CSR_MCONFIGPTR_RST;
        end
        else if (mret)
        begin
            csr_rf[CSR_RF_MSTATUS_IDX][3]       <= csr_rf[CSR_RF_MSTATUS_IDX][7];
            csr_rf[CSR_RF_MSTATUS_IDX][7]       <= 1'b1;
            csr_rf[CSR_RF_MSTATUS_IDX][12:11]   <= 2'b00;     // set back to least-privileged mode supported (U)
            current_priv                        <= csr_rf[CSR_RF_MSTATUS_IDX][12:11];
        end
        else if (illegal_instr || illegal_csr || illegal_wfi)
        begin
            csr_rf[CSR_RF_MEPC_IDX]     <= pc;
            csr_rf[CSR_RF_MCAUSE_IDX]   <= 32'd2;
            csr_rf[CSR_RF_MTVAL_IDX]    <= instr;
            trap_to_M();
        end
        else if (instr_access_misaligned)
        begin
            csr_rf[CSR_RF_MEPC_IDX]     <= pc;
            csr_rf[CSR_RF_MCAUSE_IDX]   <= 32'd0;
            csr_rf[CSR_RF_MTVAL_IDX]    <= jalr ? {instr_addr[31:1], 1'b0} : instr_addr;
            trap_to_M();
        end
        else if (ecall)
        begin
            csr_rf[CSR_RF_MEPC_IDX]     <= pc;
            csr_rf[CSR_RF_MCAUSE_IDX]   <= (current_priv == 2'b00) ? 32'd8 : 32'd11;
            csr_rf[CSR_RF_MTVAL_IDX]    <= 'b0;
            trap_to_M();
        end
        else if (ebreak)
        begin
            csr_rf[CSR_RF_MEPC_IDX]     <= pc;
            csr_rf[CSR_RF_MCAUSE_IDX]   <= 32'd3;
            csr_rf[CSR_RF_MTVAL_IDX]    <= 'b0;
            trap_to_M();
        end
        else if (is_misaligned)
        begin
            csr_rf[CSR_RF_MEPC_IDX]     <= pc;
            csr_rf[CSR_RF_MCAUSE_IDX]   <= (is_misalignment_store) ? 32'd6 : 32'd4;
            csr_rf[CSR_RF_MSCRATCH_IDX] <= instr;
            csr_rf[CSR_RF_MTVAL_IDX]    <= {17'b0, mem_addr};
            csr_rf[CSR_RF_MTVAL2_IDX]   <= (is_misalignment_store) ? misaligned_store_value : {27'b0, rd_addr};
            trap_to_M();
        end
        else if (msi_en)
        begin
            csr_rf[CSR_RF_MEPC_IDX]     <= pc;
            csr_rf[CSR_RF_MCAUSE_IDX]   <= {1'b1, 31'd3};
            trap_to_M();
        end
        else if (mti_en)
        begin
            csr_rf[CSR_RF_MEPC_IDX]     <= pc;
            csr_rf[CSR_RF_MCAUSE_IDX]   <= {1'b1, 31'd7};
            trap_to_M();
        end
        else if (mei_en)
        begin
            csr_rf[CSR_RF_MEPC_IDX]     <= pc;
            csr_rf[CSR_RF_MCAUSE_IDX]   <= {1'b1, 31'd11};
            trap_to_M();
        end
        else if (spec_reg_w_en && !(current_priv < csr_addr[9:8]))
        begin
            case(csr_addr)
                CSR_JVT_ADDR:          csr_rf[CSR_RF_JVT_IDX]           <= write_value;
                CSR_MSTATUS_ADDR:      csr_rf[CSR_RF_MSTATUS_IDX]       <= write_value;
                CSR_MISA_ADDR:         csr_rf[CSR_RF_MISA_IDX]          <= write_value;
                CSR_MEDELEG_ADDR:      csr_rf[CSR_RF_MEDELEG_IDX]       <= write_value;
                CSR_MIDELEG_ADDR:      csr_rf[CSR_RF_MIDELEG_IDX]       <= write_value;
                CSR_MIE_ADDR:          csr_rf[CSR_RF_MIE_IDX]           <= write_value;
                CSR_MTVEC_ADDR:        csr_rf[CSR_RF_MTVEC_IDX]         <= write_value;
                CSR_MCOUNTEREN_ADDR:   csr_rf[CSR_RF_MCOUNTEREN_IDX]    <= write_value;
                CSR_MSTATUSH_ADDR:     csr_rf[CSR_RF_MSTATUSH_IDX]      <= write_value;
                CSR_MEDELEGH_ADDR:     csr_rf[CSR_RF_MEDELEGH_IDX]      <= write_value;
                CSR_MTVT_ADDR:         csr_rf[CSR_RF_MTVT_IDX]          <= write_value;
                CSR_MSCRATCH_ADDR:     csr_rf[CSR_RF_MSCRATCH_IDX]      <= write_value;
                CSR_MEPC_ADDR:         csr_rf[CSR_RF_MEPC_IDX]          <= write_value;
                CSR_MCAUSE_ADDR:       csr_rf[CSR_RF_MCAUSE_IDX]        <= write_value;
                CSR_MTVAL_ADDR:        csr_rf[CSR_RF_MTVAL_IDX]         <= write_value;
                CSR_MIP_ADDR:          csr_rf[CSR_RF_MIP_IDX]           <= write_value;
                CSR_MTINST_ADDR:       csr_rf[CSR_RF_MTINST_IDX]        <= write_value;
                CSR_MTVAL2_ADDR:       csr_rf[CSR_RF_MTVAL2_IDX]        <= write_value;
            endcase

            if(csr_addr == CSR_MSTATUS_ADDR) begin
                case(write_value[12:11])
                    2'b00:      csr_rf[CSR_RF_MSTATUS_IDX][12:11] <= 2'b00;    // U
                    2'b11:      csr_rf[CSR_RF_MSTATUS_IDX][12:11] <= 2'b11;    // M
                    default:    csr_rf[CSR_RF_MSTATUS_IDX][12:11] <= 2'b00;    // collapse to U
                endcase
            end

            if(csr_addr == CSR_MISA_ADDR) begin
                csr_rf[CSR_RF_MISA_IDX] <= csr_rf[CSR_RF_MISA_IDX];
            end
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
                CSR_JVT_ADDR:          out <= csr_rf[CSR_RF_JVT_IDX];
                CSR_MSTATUS_ADDR:      out <= csr_rf[CSR_RF_MSTATUS_IDX];
                CSR_MISA_ADDR:         out <= csr_rf[CSR_RF_MISA_IDX];
                CSR_MEDELEG_ADDR:      out <= csr_rf[CSR_RF_MEDELEG_IDX];
                CSR_MIDELEG_ADDR:      out <= csr_rf[CSR_RF_MIDELEG_IDX];
                CSR_MIE_ADDR:          out <= csr_rf[CSR_RF_MIE_IDX];
                CSR_MTVEC_ADDR:        out <= csr_rf[CSR_RF_MTVEC_IDX];
                CSR_MCOUNTEREN_ADDR:   out <= csr_rf[CSR_RF_MCOUNTEREN_IDX];
                CSR_MSTATUSH_ADDR:     out <= csr_rf[CSR_RF_MSTATUSH_IDX];
                CSR_MEDELEGH_ADDR:     out <= csr_rf[CSR_RF_MEDELEGH_IDX];
                CSR_MTVT_ADDR:         out <= csr_rf[CSR_RF_MTVT_IDX];
                CSR_MSCRATCH_ADDR:     out <= csr_rf[CSR_RF_MSCRATCH_IDX];
                CSR_MEPC_ADDR:         out <= csr_rf[CSR_RF_MEPC_IDX];
                CSR_MCAUSE_ADDR:       out <= csr_rf[CSR_RF_MCAUSE_IDX];
                CSR_MTVAL_ADDR:        out <= csr_rf[CSR_RF_MTVAL_IDX];
                CSR_MIP_ADDR:          out <= csr_rf[CSR_RF_MIP_IDX];
                CSR_MTINST_ADDR:       out <= csr_rf[CSR_RF_MTINST_IDX];
                CSR_MTVAL2_ADDR:       out <= csr_rf[CSR_RF_MTVAL2_IDX];
                CSR_MVENDORID_ADDR:    out <= csr_rf[CSR_RF_MVENDORID_IDX];
                CSR_MARCHID_ADDR:      out <= csr_rf[CSR_RF_MARCHID_IDX];
                CSR_MIMPID_ADDR:       out <= csr_rf[CSR_RF_MIMPID_IDX];
                CSR_MHARTID_ADDR:      out <= csr_rf[CSR_RF_MHARTID_IDX];
                CSR_MCONFIGPTR_ADDR:   out <= csr_rf[CSR_RF_MCONFIGPTR_IDX];
                default:               out <= 'b0;
            endcase
        end

        if(illegal_instr || illegal_csr || illegal_wfi || instr_access_misaligned || is_misaligned || msi_en || mti_en || mei_en || ecall || ebreak) begin
            out <= csr_rf[CSR_RF_MTVEC_IDX];
        end else if(mret) begin
            out <= csr_rf[CSR_RF_MEPC_IDX];
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

    task trap_to_M;
        begin
            csr_rf[CSR_RF_MSTATUS_IDX][7] <= csr_rf[CSR_RF_MSTATUS_IDX][3];
            csr_rf[CSR_RF_MSTATUS_IDX][3] <= 1'b0;
            csr_rf[CSR_RF_MSTATUS_IDX][12:11] <= current_priv;
            current_priv <= 2'b11;
        end
    endtask

endmodule
