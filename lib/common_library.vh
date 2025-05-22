// Common parameters library for the CPU
// Created:     2024-01-20
// Modified:    2025-05-23
// Author:      Kagan Dikmen

// OPCODES
localparam R_OPCODE         = 7'b0110011;
localparam I_OPCODE         = 7'b0010011;
localparam LOAD_OPCODE      = 7'b0000011;
localparam S_OPCODE         = 7'b0100011;
localparam B_OPCODE         = 7'b1100011;
localparam JAL_OPCODE       = 7'b1101111;
localparam JALR_OPCODE      = 7'b1100111;
localparam LUI_OPCODE       = 7'b0110111;
localparam AUIPC_OPCODE     = 7'b0010111;
localparam FENCE_OPCODE     = 7'b0001111;
localparam SYSTEM_OPCODE    = 7'b1110011;


//FUNCT3

localparam FUNCT3_JALR      = 3'b000;
localparam FUNCT3_BEQ       = 3'b000;
localparam FUNCT3_BNE       = 3'b001;
localparam FUNCT3_BLT       = 3'b100;
localparam FUNCT3_BGE       = 3'b101;
localparam FUNCT3_BLTU      = 3'b110;
localparam FUNCT3_BGEU      = 3'b111;
localparam FUNCT3_LB        = 3'b000;
localparam FUNCT3_LH        = 3'b001;
localparam FUNCT3_LW        = 3'b010;
localparam FUNCT3_LBU       = 3'b100;
localparam FUNCT3_LHU       = 3'b101;
localparam FUNCT3_SB        = 3'b000;
localparam FUNCT3_SH        = 3'b001;
localparam FUNCT3_SW        = 3'b010;
localparam FUNCT3_ADDI      = 3'b000;
localparam FUNCT3_SLTI      = 3'b010;
localparam FUNCT3_SLTIU     = 3'b011;
localparam FUNCT3_XORI      = 3'b100;
localparam FUNCT3_ORI       = 3'b110;
localparam FUNCT3_ANDI      = 3'b111;
localparam FUNCT3_SLLI      = 3'b001;
localparam FUNCT3_SRLI      = 3'b101;
localparam FUNCT3_SRAI      = 3'b101;
localparam FUNCT3_ADD       = 3'b000;
localparam FUNCT3_SUB       = 3'b000;
localparam FUNCT3_SLL       = 3'b001;
localparam FUNCT3_SLT       = 3'b010;
localparam FUNCT3_SLTU      = 3'b011;
localparam FUNCT3_XOR       = 3'b100;
localparam FUNCT3_SRL       = 3'b101;
localparam FUNCT3_SRA       = 3'b101;
localparam FUNCT3_OR        = 3'b110;
localparam FUNCT3_AND       = 3'b111;
localparam FUNCT3_FENCE     = 3'b000;
localparam FUNCT3_FENCEI    = 3'b001;
localparam FUNCT3_SYSTEM    = 3'b000;


// FUNCT7

localparam FUNCT7_SLLI      = 7'b0000000;
localparam FUNCT7_SRLI      = 7'b0000000;
localparam FUNCT7_SRAI      = 7'b0100000;
localparam FUNCT7_ADD       = 7'b0000000;
localparam FUNCT7_SUB       = 7'b0100000;
localparam FUNCT7_SLL       = 7'b0000000;
localparam FUNCT7_SLT       = 7'b0000000;
localparam FUNCT7_SLTU      = 7'b0000000;
localparam FUNCT7_XOR       = 7'b0000000;
localparam FUNCT7_SRL       = 7'b0000000;
localparam FUNCT7_SRA       = 7'b0100000;
localparam FUNCT7_OR        = 7'b0000000;
localparam FUNCT7_AND       = 7'b0000000;


// IMM

localparam ECALL_IMM        = 12'h000;
localparam EBREAK_IMM       = 12'h001;


// DMEM 

localparam DMEM_WIDTH        = 8;
localparam DMEM_DEPTH        = 4096;
localparam DMEM_ADDR_LENGTH  = 12;       // log2(MEM_DEPTH) = 12

localparam WORD         = 4'b1111;
localparam HALFWORD     = 4'b1100;
localparam BYTE         = 4'b1000;


// PMEM

// localparam PMEM_DEPTH       = 4096;
// localparam PC_WIDTH         = 12;       // log2(PMEM_DEPTH) = 12


// REGISTER FILE

localparam RF_WIDTH         = 32;
localparam RF_DEPTH         = 32;
localparam RF_ADDR_LENGTH   = 5;        // log2(RF_DEPTH) = 5
