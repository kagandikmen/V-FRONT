// Memory access unit of the CPU
// Created:     2025-05-28
// Modified:    2025-05-28
// Author:      Kagan Dikmen

module memory_access_unit
    #(
        parameter BYTE_WIDTH = 8
    )(
        input [3:0] ldst_mask,
        input [1:0] offset,
        input ldst_is_unsigned,

        input [4*BYTE_WIDTH-1:0] memory_out,
        output [4*BYTE_WIDTH-1:0] out
    );

    genvar i;

    wire [4*BYTE_WIDTH-1:0] temp;

    assign temp = (offset == 2'b11) ? {{24{1'b0}}, memory_out[31:24]}
                : (offset == 2'b10) ? {{16{1'b0}}, memory_out[31:16]}
                : (offset == 2'b01) ? {{08{1'b0}}, memory_out[31:08]}
                : memory_out ;

    generate
        for (i = 0; i < 4; i = i+1)
        begin
            assign out[(i+1)*BYTE_WIDTH-1:i*BYTE_WIDTH] = (ldst_mask == 4'b0000) ? {BYTE_WIDTH{1'b0}}
                                                        : (ldst_mask[i] == 1'b1) ? temp[(i+1)*BYTE_WIDTH-1:i*BYTE_WIDTH]
                                                        : ldst_is_unsigned ? {BYTE_WIDTH{1'b0}}
                                                        : {BYTE_WIDTH{out[i*BYTE_WIDTH-1]}};
        end
    endgenerate

endmodule