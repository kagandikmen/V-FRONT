// Comparison unit of the ALU
// Created:     2024-01-18
// Modified:    2024-01-27 (last status: working fine)
// Author:      Kagan Dikmen

module comparison_unit
    #(
    parameter OPD_LENGTH = 32
    )(
    input [OPD_LENGTH-1:0] opd1,
    input [OPD_LENGTH-1:0] opd2,
    input [3:0] alu_op_select,      // 0000 for IS_EQ, 0001 for IS_NE, 
                                    // 0010 for IS_GE, 0110 for IS_GEU,
                                    // 0011 for IS_LT, 0111 for IS_LTU

    output [OPD_LENGTH-1:0] comp_result
    );

    localparam IS_EQ = 3'b000;
    localparam IS_NE = 3'b001;
    localparam IS_GE = 3'b010;
    localparam IS_GEU = 3'b110;
    localparam IS_LT = 3'b011;
    localparam IS_LTU = 3'b111;

    reg [OPD_LENGTH-1:0] comp_result_bf;

    assign comp_result = comp_result_bf;

    always @(*)
    begin
        case (alu_op_select[2:0])
        IS_EQ:      comp_result_bf <= (opd1 == opd2) ? 'b1 : 'b0;
        IS_NE:      comp_result_bf <= (opd1 != opd2) ? 'b1 : 'b0;
        IS_GE:      comp_result_bf <= ($signed(opd1) >= $signed(opd2)) ? 'b1 : 'b0;
        IS_GEU:     comp_result_bf <= ($unsigned(opd1) >= $unsigned(opd2)) ? 'b1 : 'b0;
        IS_LT:      comp_result_bf <= ($signed(opd1) < $signed(opd2)) ? 'b1 : 'b0;
        IS_LTU:     comp_result_bf <= ($unsigned(opd1) < $unsigned(opd2)) ? 'b1 : 'b0;
        default:
        begin
            comp_result_bf <= 'b0;
            $display("WARNING: alu_op_select value %b at time %t doesn't match with any valid comparison type.", alu_op_select, $realtime);
        end
        endcase
    end


endmodule