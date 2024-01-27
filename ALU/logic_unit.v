// Logic unit of the ALU
// Created:     2024-01-18
// Modified:    2024-01-27 (last status: working fine)
// Author:      Kagan Dikmen

module logic_unit
    #(
    parameter OPD_LENGTH = 32
    )(
    input [OPD_LENGTH-1:0] opd1,
    input [OPD_LENGTH-1:0] opd2,
    input [3:0] alu_op_select,      // 0111 for AND, 0110 for OR, 0100 for XOR, 0000 for ~opd1, 0001 for ~opd2

    output [OPD_LENGTH-1:0] logic_result
    );

    localparam AND = 3'b111;
    localparam OR = 3'b110;
    localparam XOR = 3'b100;
    localparam NOT_OPD1 = 3'b000;
    localparam NOT_OPD2 = 3'b001;

    reg [OPD_LENGTH-1:0] logic_result_bf;

    assign logic_result = logic_result_bf;

    always @(*)
    begin
        case (alu_op_select[2:0])
        AND:        logic_result_bf <= opd1 & opd2;
        OR:         logic_result_bf <= opd1 | opd2;
        XOR:        logic_result_bf <= opd1 ^ opd2;
        NOT_OPD1:   logic_result_bf <= ~opd1;
        NOT_OPD2:   logic_result_bf <= ~opd2;
        default: 
        begin
            logic_result_bf <= 'b0;
            $display("WARNING: alu_op_select value %b at time %t doesn't match with any valid logical operation.", alu_op_select, $realtime);
        end
        endcase
    end
    

endmodule