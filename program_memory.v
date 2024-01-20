// Program memory of the CPU
// Created:     2024-01-20
// Modified:    2024-01-20 (status: working fine)
// Author:      Kagan Dikmen

module program_memory 
    #(
    parameter PC_WIDTH = 12
    )(
    input clk,
    input rst,
    input w_en,
    input [PC_WIDTH-1:0] addr,

    output reg [31:0] data
    );

    `include "common_library.vh"

    integer i;

    reg [31:0] pmem [2**PC_WIDTH-1:0];

    always @(posedge clk)
    begin
        if (rst == 1'b1) 
        begin
            for (i=0; i<2**PC_WIDTH; i=i+1)
            begin
                pmem [i] <= 32'b0;
            end

            // a little bit of cheating for testing purposes

            pmem [0] <= {7'b0, 5'd4, 5'd3, 3'b0, 5'd2, R_OPCODE};               // ADD x2, x3, x4
            pmem [1] <= {7'b0, 5'd5, 5'd3, 3'b0, 5'd2, R_OPCODE};               // ADD x2, x3, x5
            pmem [2] <= {12'd4, 5'd3, 3'b0, 5'd2, I_OPCODE};                    // ADDI x2, x3, 4
            pmem [3] <= {12'd8, 5'd4, FUNCT3_LW, 5'd3, LOAD_OPCODE};            // LW x3 8(x4)
            pmem [4] <= {7'b0, 5'd3, 5'd4, FUNCT3_SW, 5'd12, S_OPCODE};         // SW x4 12(x3)
            pmem [5] <= {7'b0, 5'd4, 5'd3, FUNCT3_BGE, 5'b01100, B_OPCODE};     // BGE x3 x4 12
            pmem [6] <= {1'b0, 10'd40, 1'b0, 8'b0, 5'd3, JAL_OPCODE};           // JAL x3, 80
            pmem [7] <= {12'd120, 5'd4, FUNCT3_JALR, 5'd3, JALR_OPCODE};        // JALR x3 x4 120
            pmem [8] <= {20'd2, 5'd10, LUI_OPCODE};                             // LUI x10 2
            pmem [9] <= {20'd2, 5'd15, AUIPC_OPCODE};                           // AUIPC x15 2
            pmem [10] <= 32'b0;                                                 // Invalid Operation
        end
    end

    always @(*)
    begin
        data = pmem [addr];
    end
endmodule