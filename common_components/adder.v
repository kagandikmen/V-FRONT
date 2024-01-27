// Adder of the ALU
// Created:     2024-01-17
// Modified:    2024-01-27 (last status: working fine)
// Author:      Kagan Dikmen

`include "adder_unit.v"

module adder
    #(
    parameter OPERAND_LENGTH = 32
    )(
    input [OPERAND_LENGTH-1:0] opd1,
    input [OPERAND_LENGTH-1:0] opd2,
    input [3:0] alu_op_select,      // 0000 for addition, 1000 for subtraction
    
    output [OPERAND_LENGTH-1:0] adder_result
    );

    wire [OPERAND_LENGTH-1:0] c_out;

    genvar i;

    generate

        for (i = 0; i < 1; i = i + 1)
        begin
            adder_unit rc (
                        .a(opd1[i]), 
                        .b(alu_op_select[3] ^ opd2[i]), 
                        .c_in(alu_op_select[3]), 
                        .out(adder_result[i]), 
                        .c_out(c_out[i])
                        );
        end

        for (i = 1; i < OPERAND_LENGTH; i = i + 1)
        begin
            adder_unit rc (
                        .a(opd1[i]), 
                        .b(alu_op_select[3] ^ opd2[i]), 
                        .c_in(c_out[i-1]), 
                        .out(adder_result[i]), 
                        .c_out(c_out[i])
                        );
        end
    endgenerate

endmodule