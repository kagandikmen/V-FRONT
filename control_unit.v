// Control unit of the CPU
// Created:     2024-01-25
// Modified:    2024-01-26 (status: working fine)
// Author:      Kagan Dikmen

module control_unit
    (
    input [31:0] instr,

    output reg clk = 1'b0,

    output reg [1:0] rf_w_select,

    // to ALU
    output reg alu_mux1_select,
    output reg [1:0] alu_mux2_select,
    output reg [2:0] alu_op_select,
    output reg alu_pc_select,

    // to register file
    output reg w_en_rf,

    // to program memory
    output w_en_pmem,

    // to data memory
    output reg wr_en_dmem,
    output reg [1:0] rw_mode,

    // to PC counter
    output reg branch,
    output reg jump
    );

    `include "common_library.vh"

    wire [16:0] instr_compressed;

    assign instr_compressed = {instr[14:12], instr[6:0]};
    assign w_en_pmem = 1'b1;

    always #5 clk = ~clk;

    always @(instr)
    begin

        alu_pc_select <= 1'b0;  // don't select PC at ALU
        branch <= 1'b0;
        jump <= 1'b0;
        rw_mode <= 2'b00;       // WORD
        wr_en_dmem <= 1'b0;     // no write to DMEM
        
        case (instr_compressed)
            {FUNCT3_ADD, R_OPCODE}: // ADD / SUB
            begin
                if (instr[30] == 1'b0)      // AND
                begin
                    alu_mux1_select <= 1'b0;
                    alu_mux2_select <= 2'b00; 
                    alu_op_select <= 3'b000;
                    w_en_rf <= 1'b1;
                    rf_w_select <= 2'b00;
                end
                else                        // SUB
                begin
                    alu_mux1_select <= 1'b0;
                    alu_mux2_select <= 2'b00; 
                    alu_op_select <= 3'b001;
                    w_en_rf <= 1'b1;
                    rf_w_select <= 2'b00;
                end
            end
            {FUNCT3_SLL, R_OPCODE}: // SLL
            begin
                alu_mux1_select <= 1'b0;
                alu_mux2_select <= 2'b10;
                alu_op_select <= 3'b011;
                w_en_rf <= 1'b1;
                rf_w_select <= 2'b00;
            end
            {FUNCT3_SLT, R_OPCODE}: // SLT
            begin
                alu_mux1_select <= 1'b0;
                alu_mux2_select <= 2'b11;
                alu_op_select <= 3'b011;
                w_en_rf <= 1'b1;
                rf_w_select <= 2'b00;
            end
            {FUNCT3_SLTU, R_OPCODE}: // SLTU
            begin
                alu_mux1_select <= 1'b0;
                alu_mux2_select <= 2'b11;
                alu_op_select <= 3'b111;
                w_en_rf <= 1'b1;
                rf_w_select <= 2'b00;
            end
            {FUNCT3_XOR, R_OPCODE}: // XOR
            begin
                alu_mux1_select <= 1'b0;
                alu_mux2_select <= 2'b01;
                alu_op_select <= 3'b110;
                w_en_rf <= 1'b1;
                rf_w_select <= 2'b00;
            end
            {FUNCT3_SRL, R_OPCODE}: // SRL / SRA
            begin
                if (instr[31] == 1'b0)  // SRL
                begin
                    alu_mux1_select <= 1'b0;
                    alu_mux2_select <= 2'b10; 
                    alu_op_select <= 3'b001; 
                    w_en_rf <= 1'b1;
                    rf_w_select <= 2'b00;
                end
                else                    // SRA
                begin
                    alu_mux1_select <= 1'b0;
                    alu_mux2_select <= 2'b10;
                    alu_op_select <= 3'b111;
                    w_en_rf <= 1'b1;
                    rf_w_select <= 2'b00;
                end
            end
            {FUNCT3_OR, R_OPCODE}: // OR
            begin
                alu_mux1_select <= 1'b0;
                alu_mux2_select <= 2'b01;
                alu_op_select <= 3'b110;
                w_en_rf <= 1'b1;
                rf_w_select <= 2'b00;
            end
            {FUNCT3_AND, R_OPCODE}: // AND
            begin
                alu_mux1_select <= 1'b0;
                alu_mux2_select <= 2'b01; 
                alu_op_select <= 3'b111; 
                w_en_rf <= 1'b1;
                rf_w_select <= 2'b00;
            end
            {FUNCT3_ADDI, I_OPCODE}: // ADDI
            begin
                alu_mux1_select <= 1'b0;
                alu_mux2_select <= 2'b00;
                alu_op_select <= 3'b000;
                w_en_rf <= 1'b1;
                rf_w_select <= 2'b00;
            end
            {FUNCT3_SLTI, I_OPCODE}: // SLTI
            begin
                alu_mux1_select <= 1'b0;
                alu_mux2_select <= 2'b11;
                alu_op_select <= 3'b011;
                w_en_rf <= 1'b1;
                rf_w_select <= 2'b00;
            end
            {FUNCT3_SLTIU, I_OPCODE}: // SLTIU
            begin
                alu_mux1_select <= 1'b0;
                alu_mux2_select <= 2'b11;
                alu_op_select <= 3'b111;
                w_en_rf <= 1'b1;
                rf_w_select <= 2'b00;
            end
            {FUNCT3_XORI, I_OPCODE}: // XORI
            begin
                alu_mux1_select <= 1'b0;
                alu_mux2_select <= 2'b01; 
                alu_op_select <= 3'b100;
                w_en_rf <= 1'b1;
                rf_w_select <= 2'b00;
            end
            {FUNCT3_ORI, I_OPCODE}: // ORI
            begin
                alu_mux1_select <= 1'b0;
                alu_mux2_select <= 2'b01; 
                alu_op_select <= 3'b110;
                w_en_rf <= 1'b1;
                rf_w_select <= 2'b00;
            end
            {FUNCT3_ANDI, I_OPCODE}: // ANDI
            begin
                alu_mux1_select <= 1'b0;
                alu_mux2_select <= 2'b01;
                alu_op_select <= 3'b111;
                w_en_rf <= 1'b1;
                rf_w_select <= 2'b00;
            end
            {FUNCT3_SLLI, I_OPCODE}: // SLLI
            begin
                alu_mux1_select <= 1'b0;
                alu_mux2_select <= 2'b10;
                alu_op_select <= 3'b011;
                w_en_rf <= 1'b1;
                rf_w_select <= 2'b00;
            end
            {FUNCT3_SRLI, I_OPCODE}: // SRLI / SRAI
            begin
                if (instr[30] == 1'b0)      // SRLI
                begin
                    alu_mux1_select <= 1'b0;
                    alu_mux2_select <= 2'b10;
                    alu_op_select <= 3'b001;
                    w_en_rf <= 1'b1;
                    rf_w_select <= 2'b00;
                end
                else                        // SRAI
                begin
                    alu_mux1_select <= 1'b0;
                    alu_mux2_select <= 2'b10;
                    alu_op_select <= 3'b111;
                    w_en_rf <= 1'b1;
                    rf_w_select <= 2'b00;
                end
            end
            {FUNCT3_LB, LOAD_OPCODE}: // LB
            begin
                alu_mux1_select <= 1'b0;
                alu_mux2_select <= 2'b00;
                alu_op_select <= 3'b000; 
                w_en_rf <= 1'b1;
                rf_w_select <= 2'b01;
                rw_mode <= 2'b10;
            end
            {FUNCT3_LH, LOAD_OPCODE}: // LH
            begin
                alu_mux1_select <= 1'b0;
                alu_mux2_select <= 2'b00;
                alu_op_select <= 3'b000; 
                w_en_rf <= 1'b1;
                rf_w_select <= 2'b01;
                rw_mode <= 2'b01;
            end
            {FUNCT3_LW, LOAD_OPCODE}: // LW
            begin
                alu_mux1_select <= 1'b0;
                alu_mux2_select <= 2'b00;
                alu_op_select <= 3'b000; 
                w_en_rf <= 1'b1;
                rf_w_select <= 2'b01;
            end
            {FUNCT3_LBU, LOAD_OPCODE}: // LBU
            begin
                alu_mux1_select <= 1'b0;
                alu_mux2_select <= 2'b00;
                alu_op_select <= 3'b000; 
                w_en_rf <= 1'b1;
                rf_w_select <= 2'b01;
                rw_mode <= 2'b10;
            end
            {FUNCT3_LHU, LOAD_OPCODE}: // LHU
            begin
                alu_mux1_select <= 1'b0;
                alu_mux2_select <= 2'b00;
                alu_op_select <= 3'b000; 
                w_en_rf <= 1'b1;
                rf_w_select <= 2'b01;
                rw_mode <= 2'b01;
            end
            {FUNCT3_SB, S_OPCODE}:  // SB
            begin
                alu_mux1_select <= 1'b0;
                alu_mux2_select <= 2'b00; 
                alu_op_select <= 3'b000;
                w_en_rf <= 1'b0;
                rf_w_select <= 2'b00;
                rw_mode <= 2'b10;
                wr_en_dmem <= 1'b1;
            end
            {FUNCT3_SH, S_OPCODE}:  // SH
            begin
                alu_mux1_select <= 1'b0;
                alu_mux2_select <= 2'b00; 
                alu_op_select <= 3'b000;
                w_en_rf <= 1'b0;
                rf_w_select <= 2'b00;
                rw_mode <= 2'b01;
                wr_en_dmem <= 1'b1;
            end
            {FUNCT3_SW, S_OPCODE}:  // SW
            begin
                alu_mux1_select <= 1'b0;
                alu_mux2_select <= 2'b00; 
                alu_op_select <= 3'b000;
                w_en_rf <= 1'b0;
                rf_w_select <= 2'b00;
                wr_en_dmem <= 1'b1;
            end
            {FUNCT3_BEQ, B_OPCODE}: // BEQ
            begin
                alu_pc_select <= 1'b1;
                alu_mux1_select <= 1'b1;
                alu_mux2_select <= 2'b00;
                alu_op_select <= 3'b000;
                branch <= 1'b1; 
                w_en_rf <= 1'b0;
                rf_w_select <= 2'b00;
            end
            {FUNCT3_BNE, B_OPCODE}: // BNE
            begin
                alu_pc_select <= 1'b1;
                alu_mux1_select <= 1'b1;
                alu_mux2_select <= 2'b00;
                alu_op_select <= 3'b000; 
                branch <= 1'b1;
                w_en_rf <= 1'b0;
                rf_w_select <= 2'b00;
            end
            {FUNCT3_BLT, B_OPCODE}: // BLT
            begin
                alu_pc_select <= 1'b1;
                alu_mux1_select <= 1'b1;
                alu_mux2_select <= 2'b00;
                alu_op_select <= 3'b000; 
                branch <= 1'b1;
                w_en_rf <= 1'b0;
                rf_w_select <= 2'b00;
            end
            {FUNCT3_BGE, B_OPCODE}: // BGE
            begin
                alu_pc_select <= 1'b1;
                alu_mux1_select <= 1'b1;
                alu_mux2_select <= 2'b00;
                alu_op_select <= 3'b000; 
                branch <= 1'b1;
                w_en_rf <= 1'b0;
                rf_w_select <= 2'b00;
            end
            {FUNCT3_BLTU, B_OPCODE}: // BLTU
            begin
                alu_pc_select <= 1'b1;
                alu_mux1_select <= 1'b1;
                alu_mux2_select <= 2'b00;
                alu_op_select <= 3'b000; 
                branch <= 1'b1;
                w_en_rf <= 1'b0;
                rf_w_select <= 2'b00;
            end
            {FUNCT3_BGEU, B_OPCODE}: // BGEU
            begin
                alu_pc_select <= 1'b1;
                alu_mux1_select <= 1'b1;
                alu_mux2_select <= 2'b00;
                alu_op_select <= 3'b000;
                branch <= 1'b1; 
                w_en_rf <= 1'b0;
                rf_w_select <= 2'b00;
            end
            default:    // JAL / JALR / LUI / AUIPC
            begin
                case (instr[6:0])
                    JAL_OPCODE:
                    begin
                        alu_pc_select <= 1'b1;
                        alu_mux1_select <= 1'b0;
                        alu_mux2_select <= 2'b00;
                        alu_op_select <= 3'b000; 
                        jump <= 1'b1;
                        w_en_rf <= 1'b1;
                        rf_w_select <= 2'b10;
                    end
                    JALR_OPCODE:
                    begin
                        alu_mux1_select <= 1'b0;
                        alu_mux2_select <= 2'b00;
                        alu_op_select <= 3'b000;
                        jump <= 1'b1;
                        w_en_rf <= 1'b1;
                        rf_w_select <= 2'b10;
                    end
                    LUI_OPCODE:
                    begin
                        alu_mux1_select <= 1'b0;
                        alu_mux2_select <= 2'b00;
                        alu_op_select <= 3'b000;
                        w_en_rf <= 1'b1;
                        rf_w_select <= 2'b00;
                    end
                    AUIPC_OPCODE:
                    begin
                        alu_pc_select <= 1'b1;
                        alu_mux1_select <= 1'b0;
                        alu_mux2_select <= 2'b00;
                        alu_op_select <= 3'b000;
                        w_en_rf <= 1'b1;
                        rf_w_select <= 2'b00;
                    end
                    default:
                    begin
                        $error("ERROR: Invalid instruction!");
                    end
                endcase
            end
        endcase
        
    end
    

endmodule