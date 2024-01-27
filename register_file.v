// Register file of the CPU
// Created:     2024-01-20
// Modified:    2024-01-27 (last status: working fine)
// Author:      Kagan Dikmen

module register_file
    #(
    parameter RF_ADDR_LEN = 5,
    parameter RF_DATA_LEN = 32
    )(
    input clk,
    input rst,
    input w_en,

    input [RF_ADDR_LEN-1:0] rs1_addr,
    input [RF_ADDR_LEN-1:0] rs2_addr,
    input [RF_ADDR_LEN-1:0] rd_addr,

    output reg [RF_DATA_LEN-1:0] rs1_data,
    output reg [RF_DATA_LEN-1:0] rs2_data,
    input [RF_DATA_LEN-1:0] rd_write_data
    );

    `include "common_library.vh"

    integer i;

    reg [RF_DATA_LEN-1:0] rf [2**RF_ADDR_LEN-1:0];

    // resetting
    always @(posedge clk)
    begin
        if (rst == 1'b1)
        begin
            for (i = 0; i<2**RF_ADDR_LEN; i = i+1)
            begin
                rf[i] <= 'b0;
            end

            // a little bit of cheating for testing purposes
            rf[2] <= 'd6;
            rf[3] <= 'd9;
            rf[4] <= 'd12;
            rf[5] <= 'd15;
            rf[6] <= 'd18;
            rf[7] <= 'd21;
        end
    end

    // asynchronous read
    always @(*)
    begin
        rs1_data <= rf[rs1_addr];
        rs2_data <= rf[rs2_addr];
    end

    // synchronous write
    always @(posedge clk)
    begin
        if (w_en == 1'b1)
            rf[rd_addr] <= rd_write_data;

        rf[0] <= 'b0;           // x0 always has the value 32'h00000000
    end


endmodule