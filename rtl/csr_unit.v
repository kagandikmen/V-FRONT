// CSR unit
// Created:     2025-05-25
// Modified:    2025-06-03
// Author:      Kagan Dikmen

module csr_unit
    #(
    parameter CSR_REG_COUNT = 4096
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
    input [clogb2(CSR_REG_COUNT-1)-1:0] csr_addr,

    output reg [31:0] out,

    input is_misaligned,
    input is_misalignment_store,
    input [31:0] misaligned_store_value,
    input [14:0] mem_addr,
    input [4:0] rd_addr
    );

    `include "../lib/common_library.vh"

    integer i;

    reg [31:0] csr_registers [CSR_REG_COUNT-1:0];

    // write
    always @(posedge clk)
    begin
        if (rst == 1'b1)
        begin
            for(i = 0; i<CSR_REG_COUNT; i = i+1)
            begin
                csr_registers[i] <= 'b0;
            end
            csr_registers[CSR_JVT_ADDR]     <= CSR_JVT_RST;
            csr_registers[CSR_MSTATUS_ADDR] <= CSR_MSTATUS_RST;
            csr_registers[CSR_MISA_ADDR]    <= CSR_MISA_RST;
            csr_registers[CSR_MIE_ADDR]     <= CSR_MIE_RST;
            csr_registers[CSR_MTVEC_ADDR]   <= CSR_MTVEC_RST;
            csr_registers[CSR_MTVT_ADDR]    <= CSR_MTVT_RST;
            csr_registers[CSR_MSCRATCH_ADDR] <= CSR_MSCRATCH_RST;
            csr_registers[CSR_MEPC_ADDR]    <= CSR_MEPC_RST;
            csr_registers[CSR_MCAUSE_ADDR]  <= CSR_MCAUSE_RST;
            csr_registers[CSR_CUSTOM1_ADDR] <= CSR_CUSTOM1_RST;
            csr_registers[CSR_CUSTOM2_ADDR] <= CSR_CUSTOM2_RST;
        end
        else if (mret == 1'b1)
        begin
            csr_registers[CSR_MSTATUS_ADDR][1] <= csr_registers[CSR_MSTATUS_ADDR][7];
            csr_registers[CSR_MSTATUS_ADDR][7] <= 1'b1;
            csr_registers[CSR_MSTATUS_ADDR][12:11] <= 2'b00;
        end
        else if (ecall || ebreak)
        begin
            csr_registers[CSR_MEPC_ADDR] <= pc;
            csr_registers[CSR_MCAUSE_ADDR] <= (ecall) ? 32'd11 : 32'd3;
        end
        else if (is_misaligned)
        begin
            csr_registers[CSR_MEPC_ADDR] <= pc;
            csr_registers[CSR_MCAUSE_ADDR] <= (is_misalignment_store) ? 32'd4 : 32'd6;
            csr_registers[CSR_MSCRATCH_ADDR] <= in;     // saves the instruction word
            csr_registers[CSR_CUSTOM1_ADDR] <= {17'b0, mem_addr};
            csr_registers[CSR_CUSTOM2_ADDR] <= (is_misalignment_store) ? misaligned_store_value : {27'b0, rd_addr};
        end
        else if (w_en == 1'b1)
        begin
            casez (op)
                3'b?01:
                    csr_registers[csr_addr] <= in;
                3'b?10:
                    csr_registers[csr_addr] <= (csr_registers[csr_addr] | in);
                3'b?11:
                    csr_registers[csr_addr] <= (csr_registers[csr_addr] & (~in));
                default:
                    csr_registers[csr_addr] <= in;
            endcase
        end
    end

    // read
    always @(*)
    begin
        out = 'b0;
        if (r_en == 1'b1)
        begin
            out = csr_registers[csr_addr];
        end
    end

endmodule