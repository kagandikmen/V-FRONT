// CSR unit
// Created:     2025-05-25
// Modified:    2026-07-10
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

    output illegal_csr
    );

    `include "common_library.vh"

    reg spec_reg_r_en, spec_reg_w_en;
    reg [31:0] write_value;
    reg [31:0] spec_csr_registers [11:0];

    reg not_csr;

    localparam SPEC_CSR_JVT_INDEX       = 0;
    localparam SPEC_CSR_MSTATUS_INDEX   = 1;
    localparam SPEC_CSR_MISA_INDEX      = 2;
    localparam SPEC_CSR_MIE_INDEX       = 3;
    localparam SPEC_CSR_MTVEC_INDEX     = 4;
    localparam SPEC_CSR_MTVT_INDEX      = 5;
    localparam SPEC_CSR_MSCRATCH_INDEX  = 6;
    localparam SPEC_CSR_MEPC_INDEX      = 7;
    localparam SPEC_CSR_MCAUSE_INDEX    = 8;
    localparam SPEC_CSR_CUSTOM1_INDEX   = 9;
    localparam SPEC_CSR_CUSTOM2_INDEX   = 10;
    localparam SPEC_CSR_MHARTID_INDEX   = 11;

    // write
    always @(posedge clk)
    begin
        if (rst == 1'b1)
        begin
            spec_csr_registers[SPEC_CSR_JVT_INDEX]          <= CSR_JVT_RST;
            spec_csr_registers[SPEC_CSR_MSTATUS_INDEX]      <= CSR_MSTATUS_RST;
            spec_csr_registers[SPEC_CSR_MISA_INDEX]         <= CSR_MISA_RST;
            spec_csr_registers[SPEC_CSR_MIE_INDEX]          <= CSR_MIE_RST;
            spec_csr_registers[SPEC_CSR_MTVEC_INDEX]        <= CSR_MTVEC_RST;
            spec_csr_registers[SPEC_CSR_MTVT_INDEX]         <= CSR_MTVT_RST;
            spec_csr_registers[SPEC_CSR_MSCRATCH_INDEX]     <= CSR_MSCRATCH_RST;
            spec_csr_registers[SPEC_CSR_MEPC_INDEX]         <= CSR_MEPC_RST;
            spec_csr_registers[SPEC_CSR_MCAUSE_INDEX]       <= CSR_MCAUSE_RST;
            spec_csr_registers[SPEC_CSR_CUSTOM1_INDEX]      <= CSR_CUSTOM1_RST;
            spec_csr_registers[SPEC_CSR_CUSTOM2_INDEX]      <= CSR_CUSTOM2_RST;
            spec_csr_registers[SPEC_CSR_MHARTID_INDEX]      <= CSR_MHARTID_RST;
        end
        else if (mret == 1'b1)
        begin
            spec_csr_registers[SPEC_CSR_MSTATUS_INDEX][1] <= spec_csr_registers[SPEC_CSR_MSTATUS_INDEX][7];
            spec_csr_registers[SPEC_CSR_MSTATUS_INDEX][7] <= 1'b1;
            spec_csr_registers[SPEC_CSR_MSTATUS_INDEX][12:11] <= 2'b00;
        end
        else if (ecall || ebreak)
        begin
            spec_csr_registers[SPEC_CSR_MEPC_INDEX]     <= pc;
            spec_csr_registers[SPEC_CSR_MCAUSE_INDEX]   <= (ecall) ? 32'd11 : 32'd3;
        end
        else if (is_misaligned)
        begin
            spec_csr_registers[SPEC_CSR_MEPC_INDEX]     <= pc;
            spec_csr_registers[SPEC_CSR_MCAUSE_INDEX]   <= (is_misalignment_store) ? 32'd4 : 32'd6;
            spec_csr_registers[SPEC_CSR_MSCRATCH_INDEX] <= in;     // saves the instruction word
            spec_csr_registers[SPEC_CSR_CUSTOM1_INDEX]  <= {17'b0, mem_addr};
            spec_csr_registers[SPEC_CSR_CUSTOM2_INDEX]  <= (is_misalignment_store) ? misaligned_store_value : {27'b0, rd_addr};
        end
        else if (illegal_csr)
        begin
            spec_csr_registers[SPEC_CSR_MEPC_INDEX]     <= pc;
            spec_csr_registers[SPEC_CSR_MCAUSE_INDEX]   <= 32'd3;   // illegal instruction causes ebreak
        end
        else if (spec_reg_w_en)
        begin
            case(csr_addr)
                CSR_JVT_ADDR:          spec_csr_registers[SPEC_CSR_JVT_INDEX]       <= write_value;
                CSR_MSTATUS_ADDR:      spec_csr_registers[SPEC_CSR_MSTATUS_INDEX]   <= write_value;
                CSR_MISA_ADDR:         spec_csr_registers[SPEC_CSR_MISA_INDEX]      <= write_value;
                CSR_MIE_ADDR:          spec_csr_registers[SPEC_CSR_MIE_INDEX]       <= write_value;
                CSR_MTVEC_ADDR:        spec_csr_registers[SPEC_CSR_MTVEC_INDEX]     <= write_value;
                CSR_MTVT_ADDR:         spec_csr_registers[SPEC_CSR_MTVT_INDEX]      <= write_value;
                CSR_MSCRATCH_ADDR:     spec_csr_registers[SPEC_CSR_MSCRATCH_INDEX]  <= write_value;
                CSR_MEPC_ADDR:         spec_csr_registers[SPEC_CSR_MEPC_INDEX]      <= write_value;
                CSR_MCAUSE_ADDR:       spec_csr_registers[SPEC_CSR_MCAUSE_INDEX]    <= write_value;
                CSR_CUSTOM1_ADDR:      spec_csr_registers[SPEC_CSR_CUSTOM1_INDEX]   <= write_value;
                CSR_CUSTOM2_ADDR:      spec_csr_registers[SPEC_CSR_CUSTOM2_INDEX]   <= write_value;
                CSR_MHARTID_ADDR:      spec_csr_registers[SPEC_CSR_MHARTID_INDEX]   <= write_value;
            endcase
        end
    end

    always @(*)
    begin
        spec_reg_r_en = 1'b0;
        spec_reg_w_en = 1'b0;
        not_csr = 1'b0;
        
        if(csr_addr == CSR_JVT_ADDR 
            || csr_addr == CSR_MSTATUS_ADDR
            || csr_addr == CSR_MISA_ADDR
            || csr_addr == CSR_MIE_ADDR
            || csr_addr == CSR_MTVEC_ADDR
            || csr_addr == CSR_MTVT_ADDR
            || csr_addr == CSR_MSCRATCH_ADDR
            || csr_addr == CSR_MEPC_ADDR
            || csr_addr == CSR_MCAUSE_ADDR
            || csr_addr == CSR_CUSTOM1_ADDR
            || csr_addr == CSR_CUSTOM2_ADDR
            || csr_addr == CSR_MHARTID_ADDR)
        begin
            spec_reg_r_en = r_en;
            spec_reg_w_en = w_en;
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
                CSR_MIE_ADDR:          out <= spec_csr_registers[SPEC_CSR_MIE_INDEX];
                CSR_MTVEC_ADDR:        out <= spec_csr_registers[SPEC_CSR_MTVEC_INDEX];
                CSR_MTVT_ADDR:         out <= spec_csr_registers[SPEC_CSR_MTVT_INDEX];
                CSR_MSCRATCH_ADDR:     out <= spec_csr_registers[SPEC_CSR_MSCRATCH_INDEX];
                CSR_MEPC_ADDR:         out <= spec_csr_registers[SPEC_CSR_MEPC_INDEX];
                CSR_MCAUSE_ADDR:       out <= spec_csr_registers[SPEC_CSR_MCAUSE_INDEX];
                CSR_CUSTOM1_ADDR:      out <= spec_csr_registers[SPEC_CSR_CUSTOM1_INDEX];
                CSR_CUSTOM2_ADDR:      out <= spec_csr_registers[SPEC_CSR_CUSTOM2_INDEX];
                CSR_MHARTID_ADDR:      out <= spec_csr_registers[SPEC_CSR_MHARTID_INDEX];
                default:               out <= 'b0;
            endcase
        end

        if(illegal_csr) begin
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

    assign illegal_csr = not_csr && (r_en || w_en);

endmodule