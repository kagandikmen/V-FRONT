// CSR unit
// Created:     2025-05-25
// Modified:    2025-05-26
// Author:      Kagan Dikmen

module csr_unit
    #(
    parameter CSR_REG_COUNT = 4096
    )(
    input clk,
    input rst,

    input r_en,
    input w_en,
    input [2:0] op,
    input [31:0] in,
    input [clogb2(CSR_REG_COUNT-1)-1:0] csr_addr,

    output reg [31:0] out
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