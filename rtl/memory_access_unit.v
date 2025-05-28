// Memory access unit of the CPU
// Created:     2025-05-28
// Modified:    2025-05-29
// Author:      Kagan Dikmen

module memory_access_unit
    #(
        parameter BYTE_WIDTH = 8
    )(
        input [31:0] addr_in,
        output [11:0] addr_out,
        input [3:0] ldst_mask,
        input ldst_is_unsigned,
        input st_en,

        input [4*BYTE_WIDTH-1:0] in,
        output [4*BYTE_WIDTH-1:0] out,
        output [3:0] wr_mode,

        output is_misaligned,
        output is_misalignment_store
    );

    genvar i;

    wire [4*BYTE_WIDTH-1:0] out_temp_load, out_temp_store, temp_load, temp_store;
    wire [3:0] wr_mode_temp;
    wire access_misaligned;
    wire [1:0] offset;

    assign addr_out = addr_in[13:2];
    assign offset = addr_in[1:0];

    assign access_misaligned = (ldst_mask == 4'b1111 && offset != 2'b00) || (ldst_mask == 4'b0011 && offset[0] != 1'b0);

    // Load logic

    assign temp_load = (offset == 2'b11) ? {{24{1'b0}}, in[31:24]}
                     : (offset == 2'b10) ? {{16{1'b0}}, in[31:16]}
                     : (offset == 2'b01) ? {{08{1'b0}}, in[31:08]}
                     : in ;

    generate
        for (i = 0; i < 4; i = i+1)
        begin
            assign out_temp_load[(i+1)*BYTE_WIDTH-1:i*BYTE_WIDTH] = (ldst_mask == 4'b0000) ? {BYTE_WIDTH{1'b0}}
                                                                  : (ldst_mask[i] == 1'b1) ? temp_load[(i+1)*BYTE_WIDTH-1:i*BYTE_WIDTH]
                                                                  : ldst_is_unsigned ? {BYTE_WIDTH{1'b0}}
                                                                  : {BYTE_WIDTH{out[i*BYTE_WIDTH-1]}};
        end
    endgenerate

    // Store logic

    assign wr_mode_temp = (offset == 2'b11) ? {ldst_mask[0], 3'b0}
                        : (offset == 2'b10) ? {ldst_mask[1:0], 2'b0}
                        : (offset == 2'b01) ? {ldst_mask[2:0], 1'b0}
                        : ldst_mask ;

    assign wr_mode = access_misaligned ? 4'b0
                   : st_en ? wr_mode_temp
                   : 4'b0;

    assign out_temp_store = (offset == 2'b11) ? {in[7:0], 24'b0}
                          : (offset == 2'b10) ? {in[15:0], 16'b0}
                          : (offset == 2'b01) ? {in[23:0], 8'b0}
                          : in;

    // Output logic

    assign out = access_misaligned ? 32'b0
               : st_en ? out_temp_store
               : out_temp_load;

    assign is_misaligned = access_misaligned;
    assign is_misalignment_store = access_misaligned && st_en;

endmodule