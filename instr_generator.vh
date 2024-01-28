// Instruction Word Generator for RISC-V Core Instruction Formats
// Created:     2024-01-27
// Modified:    2024-01-28 (status: working fine)
// Author:      Kagan Dikmen

// `include "common_library.vh" 
// must be included in the module before the inclusion of this file
// if you want to use this generator in your own projects, make sure that you take
// common_library.vh, too

function [31:0] auipc_instr (input [4:0] rd, input [19:0] imm);
begin
    auipc_instr = {imm, rd, AUIPC_OPCODE};
end
endfunction

function [31:0] b_instr (input [2:0] funct3, input [4:0] rs1, rs2, input [12:0] imm);
begin
    if (imm[0] == 1'b1)
    begin
        b_instr = 32'b0;
        $error("ERROR: Invalid imm: Branch immediate cannot be an odd number!");
    end
    else
    begin
        b_instr = {imm[12], imm[10:5], rs2, rs1, funct3, imm[4:1], imm[11], B_OPCODE};
    end
end
endfunction

function [31:0] i_instr (input [2:0] funct3, input [4:0] rd, rs1, input [11:0] imm);
begin
    i_instr = {imm, rs1, funct3, rd, I_OPCODE};
end
endfunction

function [31:0] jal_instr (input [4:0] rd, input [20:0] imm);
begin
    if (imm[0] == 1'b1)
    begin
        jal_instr = 32'b0;
        $error("ERROR: Invalid imm: Jump immediate cannot be an odd number!");
    end
    else
    begin
        jal_instr = {imm[20], imm[10:1], imm[11], imm[19:12], rd, JAL_OPCODE};
    end
end
endfunction

function [31:0] jalr_instr (input [4:0] rd, rs1, input [11:0] imm);
begin
    jalr_instr = {imm, rs1, 3'b0, rd, JALR_OPCODE};
end
endfunction

function [31:0] load_instr (input [2:0] funct3, input [4:0] rd, input [11:0] imm, input [4:0] rs1);
begin
    load_instr = {imm, rs1, funct3, rd, LOAD_OPCODE};
end
endfunction

function [31:0] lui_instr (input [4:0] rd, input [19:0] imm);
begin
    lui_instr = {imm, rd, LUI_OPCODE};
end
endfunction

function [31:0] r_instr (input [2:0] funct3, input [6:0] funct7, input [4:0] rd, rs1, rs2);
begin
    r_instr = {funct7, rs2, rs1, funct3, rd, R_OPCODE};
end
endfunction

function [31:0] s_instr (input [2:0] funct3, input [4:0] rs2, input [11:0] imm, input [4:0] rs1);
begin
    s_instr = {imm[11:5], rs2, rs1, funct3, imm[4:0], S_OPCODE};
end
endfunction
