// Common parameters library for the CPU
// Created:     2024-01-20
// Modified:    2025-05-26
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

localparam FUNCT3_ECALL_EBREAK = 3'b000;

localparam FUNCT3_CSRRW     = 3'b001;
localparam FUNCT3_CSRRS     = 3'b010;
localparam FUNCT3_CSRRC     = 3'b011;
localparam FUNCT3_CSRRWI    = 3'b101;
localparam FUNCT3_CSRRSI    = 3'b110;
localparam FUNCT3_CSRRCI    = 3'b111;


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
localparam MEM_IDLE     = 4'b0000;


// PMEM

// localparam PMEM_DEPTH       = 4096;
// localparam PC_WIDTH         = 12;       // log2(PMEM_DEPTH) = 12


// REGISTER FILE

localparam RF_WIDTH         = 32;
localparam RF_DEPTH         = 32;
localparam RF_ADDR_LENGTH   = 5;        // log2(RF_DEPTH) = 5


// CSR

localparam CSR_JVT_ADDR     = 12'h017;
localparam CSR_MSTATUS_ADDR = 12'h300;
localparam CSR_MISA_ADDR    = 12'h301;
localparam CSR_MIE_ADDR     = 12'h304;
localparam CSR_MTVEC_ADDR   = 12'h305;
localparam CSR_MTVT_ADDR    = 12'h307;
localparam CSR_MEPC_ADDR    = 12'h341;
localparam CSR_MCAUSE_ADDR  = 12'h342;
localparam CSR_MTVAL_ADDR   = 12'h343;

localparam CSR_JVT_RST      = 32'h0000_0000;
localparam CSR_MSTATUS_RST  = 32'h0000_1800;
localparam CSR_MISA_RST     = 32'h4000_0000;    // RV32I with no extensions
localparam CSR_MIE_RST      = 32'h0000_0000;
localparam CSR_MTVEC_RST    = 32'h0000_0000;
localparam CSR_MTVT_RST     = 32'h0000_0000;
localparam CSR_MEPC_RST     = 32'h0000_0000;
localparam CSR_MCAUSE_RST   = 32'h0000_0000;
localparam CSR_MTVAL_RST    = 32'h0000_0000;


//  The following function calculates the address width based on specified RAM depth
function integer clogb2;
    input integer depth;
    for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
endfunction
