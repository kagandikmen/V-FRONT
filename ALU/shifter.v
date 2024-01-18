// Shifter of the ALU
// Created:     2024-01-18
// Modified:    2024-01-18 (last status: working fine)
// Author:      Kagan Dikmen

module shifter
    #(
    parameter OPD_LENGTH = 32
    )(
    input [OPD_LENGTH-1:0] opd1,
    input [OPD_LENGTH-1:0] opd2,
    input [2:0] alu_op_select,      // 001 for SRL/SRLI, 011 for SLL/SLLI, 111 for SRA/SRAI

    output [OPD_LENGTH-1:0] shifter_result
    );

    localparam SRL_SRLI = 3'b001;
    localparam SLL_SLLI = 3'b011;
    localparam SRA_SRAI = 3'b111;

    reg [OPD_LENGTH-1:0] shifter_result_bf;

    assign shifter_result = shifter_result_bf;

    always @(*)
    begin
        case (alu_op_select)
            SRL_SRLI:   shifter_result_bf <= opd1 >> opd2;
            SLL_SLLI:   shifter_result_bf <= opd1 << opd2;
            SRA_SRAI:   shifter_result_bf <= opd1 >> opd2;
            default: 
            begin
                shifter_result_bf <= 'b0;
                $display("WARNING: alu_op_select value %b at time %t doesn't match with any valid shift operation.", alu_op_select, $realtime);
            end
        endcase
    end

endmodule