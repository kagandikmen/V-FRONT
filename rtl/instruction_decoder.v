// Instruction decoder of the CPU
// Created:     2024-01-20
// Modified:    2024-08-15 (last status: working fine)
// Author:      Kagan Dikmen

module instruction_decoder
    #(
    parameter OPD_LENGTH = 32,
    parameter REG_WIDTH = 32
    )(
    // PMEM interface
    input [31:0] instr,
    
    // register file interface
    output reg [4:0] rs1_addr,
    output reg [4:0] rs2_addr,
    output reg [4:0] rd_addr,
    input [REG_WIDTH-1:0] rs1_data,
    input [REG_WIDTH-1:0] rs2_data,

    // ALU interface
    output reg [OPD_LENGTH-1:0] opd1,
    output reg [OPD_LENGTH-1:0] opd2
    );

    `include "../lib/common_library.vh"

    always @(*)
    begin        
        rd_addr = instr [11:7];
        rs1_addr = instr [19:15];
        rs2_addr = instr [24:20];

        opd1 = rs1_data;
        opd2 = rs2_data;
    end

endmodule