// Instruction decoder of the CPU
// Created:     2024-01-20
// Modified:    2024-01-28 (last status: working fine)
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

    `include "common_library.vh"

    always @(*)
    begin        

        rd_addr = instr [11:7];
        rs1_addr = instr [19:15];
        rs2_addr = instr [24:20];

        opd1 = rs1_data;
        opd2 = rs2_data;

        /*  AN OLD IMPLEMENTATION
        case (opcode)
            R_OPCODE:
            begin
                rs1_addr = rs1;
                rs2_addr = rs2;
                rd_addr = rd;
                opd1 <= rs1_data;
                opd2 <= rs2_data;
                opd3 <= 'b0;
                opd4 <= 'b0;
            end
            I_OPCODE:
            begin
                rs1_addr = rs1;
                rs2_addr = 5'b0;
                rd_addr = rd;
                opd1 = rs1_data;
                opd2 = imm;
                opd3 = 'b0;
                opd4 = 'b0;
            end
            LOAD_OPCODE:
            begin
                rs1_addr = rs1;
                rs2_addr = 5'b0;
                rd_addr = rd;
                opd1 = rs1_data;
                opd2 = imm;
                opd3 = 'b0;
                opd4 = 'b0;
            end
            S_OPCODE:
            begin
                rs1_addr = rs1;
                rs2_addr = rs2;
                rd_addr = 'b0;
                opd1 = rs1_data;
                opd2 = imm;
                opd3 = rs2_data;
                opd4 = 'b0;
            end
            B_OPCODE:
            begin
                rs1_addr = rs1;
                rs2_addr = rs2;
                rd_addr = 5'b0;
                opd1 = 'b0;
                opd2 = imm;
                opd3 = rs1_data;
                opd4 = rs2_data;
            end
            JAL_OPCODE:
            begin                
                rs1_addr = 5'b0;
                rs2_addr = 5'b0;
                rd_addr = rd;
                opd1 = 'b0;
                opd2 = imm;
                opd3 = 'b0;
                opd4 = 'b0;
            end
            JALR_OPCODE:
            begin
                rs1_addr = rs1;
                rs2_addr = 5'b0;
                rd_addr = rd;
                opd1 = rs1_data;
                opd2 = imm;
                opd3 = 'b0;
                opd4 = 'b0;
            end
            LUI_OPCODE:
            begin
                rs1_addr = 5'b0;
                rs2_addr = 5'b0;
                rd_addr = rd;
                opd1 = imm;
                opd2 = 'b0;
                opd3 = 'b0;
                opd4 = 'b0;
            end
            AUIPC_OPCODE:
            begin
                rs1_addr = 5'b0;
                rs2_addr = 5'b0;
                rd_addr = rd;
                opd1 = 'b0;
                opd2 = imm;
                opd3 = 'b0;
                opd4 = 'b0;
            end
            default: 
            begin
                rs1_addr = 5'b0;
                rs2_addr = 5'b0;
                rd_addr = 5'b0;
                opd1 = 'b0;
                opd2 = 'b0;
                opd3 = 'b0;
                opd4 = 'b0; 
                $error("ERROR: invalid opcode given to the instruction decoder! (instruction_decoder.v line 158)");
            end 
        endcase
        */
    end

endmodule