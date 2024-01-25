// Data memory of the CPU
// Created:     2024-01-25
// Modified:    2024-01-25 (status: working fine)
// Author:      Kagan Dikmen

module data_memory
    #(
    parameter DMEM_DATA_WIDTH = 32,
    parameter DMEM_ADDR_WIDTH = 12
    )(
    input clk,
    input rst,
    input wr_en,
    input [1:0] rw_mode,
    input [DMEM_ADDR_WIDTH-1:0] addr,
    input [DMEM_DATA_WIDTH-1:0] w_data,

    output reg [DMEM_DATA_WIDTH-1:0] r_data
    );

    `include "common_library.vh"

    integer i;

    reg [7:0] dmem [2**DMEM_ADDR_WIDTH-1:0];

    // asynchronous read
    always @(*)
    begin
        case (rw_mode)
            BYTE:
            begin
                r_data <= {24'b0, dmem[addr]};
            end
            HALFWORD:
            begin
                r_data <= {16'b0, dmem[addr+1], dmem[addr]};
            end
            WORD:
            begin
                r_data <= {dmem[addr+3], dmem[addr+2], dmem[addr+1], dmem[addr]};
            end
            default:
            begin
                r_data <= 32'b0;
                $error("ERROR: Invalid rw_mode value at data memory!");
            end
        endcase
    end


    // synchronous write
    always @(posedge clk)
    begin

        if (rst == 1'b1)
        begin
            for(i=0; i<2**DMEM_ADDR_WIDTH; i=i+1)
            begin
                dmem[i] <= 8'b0;
            end


            // a little bit of cheating for testing purposes

            dmem[0] <= 'd1;
            dmem[1] <= 'd3;
            dmem[2] <= 'd6;
            dmem[3] <= 'd9;
            dmem[4] <= 'd12;
        end
        else if (wr_en == 1'b1)
        begin
            case (rw_mode)
                BYTE:
                begin
                    dmem[addr] <= w_data[7:0];
                end
                HALFWORD:
                begin
                    dmem[addr] <= w_data[7:0];
                    dmem[addr+1] <= w_data[15:8];
                end
                WORD:
                begin
                    dmem[addr] <= w_data[7:0];
                    dmem[addr+1] <= w_data[15:8];
                    dmem[addr+2] <= w_data[23:16];
                    dmem[addr+3] <= w_data[31:24];
                end
                default:
                begin
                    $error("ERROR: Invalid rw_mode value at data memory!");
                end
            endcase
        end
    end
endmodule