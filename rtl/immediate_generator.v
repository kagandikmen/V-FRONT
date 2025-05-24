// Immediate generator of the CPU
// Created:     2024-01-28
// Modified:    2025-05-24
// Author:      Kagan Dikmen

module immediate_generator
    (
        input [31:0] instr,
        output reg [31:0] imm
    );

    `include "../lib/common_library.vh"

    wire [6:0] opcode;

    assign opcode = instr[6:0];

    always @(*)
    begin
        case (opcode)
        R_OPCODE:
        begin
            imm = 32'b0;
        end
        I_OPCODE:
        begin
            imm = {{20{instr[31]}}, instr[31:20]};
        end
        LOAD_OPCODE:
        begin
            imm = {{20{instr[31]}}, instr[31:20]};
        end
        S_OPCODE:
        begin
            imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
        end
        B_OPCODE:
        begin
            imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
        end
        JAL_OPCODE:
        begin
            imm = {instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
        end
        JALR_OPCODE:
        begin
            imm = {{20{instr[31]}}, instr[31:20]};
        end
        LUI_OPCODE:
        begin
            imm = {instr[31:12], 12'b0};
        end
        AUIPC_OPCODE:
        begin
            imm = {instr[31:12], 12'b0};
        end
        FENCE_OPCODE:
        begin
            imm = 32'b0;
        end
        SYSTEM_OPCODE:
        begin
            imm = 32'h3ff0;
        end
        default:
        begin
            imm = 32'b0;
        end
        endcase
    end

endmodule