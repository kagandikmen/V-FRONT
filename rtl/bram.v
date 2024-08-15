// Block RAM Module
// Created:     2024-08-12
// Modified:    2024-08-13 (last status: working fine)
// Taken from Xilinx' module examples, partly modified by Kagan Dikmen

  //  Xilinx Simple Dual Port Single Clock RAM with Byte-write
  //  This code implements a parameterizable SDP single clock memory.
  //  If a reset or enable is not necessary, it may be tied off or removed from the code.

module bram
    #(
    parameter NB_COL = 4,                             // Specify number of columns (number of bytes)
    parameter COL_WIDTH = 8,                          // Specify column width (byte width, typically 8 or 9)
    parameter RAM_DEPTH = 4096,                       // Specify RAM depth (number of entries)
    parameter RAM_PERFORMANCE = "LOW_LATENCY",        // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    parameter INIT_FILE = ""                        // Specify name/location of RAM initialization file if using one (leave blank if not)
    )(
    input [clogb2(RAM_DEPTH-1)-1:0] wr_addr,          // Write address bus, width determined from RAM_DEPTH
    input [clogb2(RAM_DEPTH-1)-1:0] rd_addr,          // Read address bus, width determined from RAM_DEPTH
    input [(NB_COL*COL_WIDTH)-1:0] ram_in,            // RAM input data
    input clk,                                        // Clock
    input [NB_COL-1:0] byte_w_en,                     // Byte-write enable
    input r_en,                                       // Read Enable, for additional power savings, disable when not in use
    input out_res,                                    // Output reset (does not affect memory contents)
    input out_r_en,                                   // Output register enable
    output [(NB_COL*COL_WIDTH)-1:0] r_out             // RAM output data
    );
    
    (* ram_style = "block" *) reg [(NB_COL*COL_WIDTH)-1:0] ram [RAM_DEPTH-1:0];
    reg [(NB_COL*COL_WIDTH)-1:0] ram_data = {(NB_COL*COL_WIDTH){1'b0}};

    // The following code either initializes the memory values to a specified file or to all zeros to match hardware
    generate
        if (INIT_FILE != "") begin: use_init_file
        initial
            $readmemh(INIT_FILE, ram, 0, RAM_DEPTH-1);
        end else begin: init_bram_to_zero
        integer ram_index;
        initial
            for (ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1)
            ram[ram_index] = {(NB_COL*COL_WIDTH){1'b0}};
        end
    endgenerate

    always @(posedge clk)
        if (r_en)
            ram_data <= ram[rd_addr];

    generate
    genvar i;
        for (i = 0; i < NB_COL; i = i+1) begin: byte_write
        always @(posedge clk)
            if (byte_w_en[i])
                ram[wr_addr][(i+1)*COL_WIDTH-1:i*COL_WIDTH] <= ram_in[(i+1)*COL_WIDTH-1:i*COL_WIDTH];
        end
    endgenerate

    //  The following code generates HIGH_PERFORMANCE (use output register) or LOW_LATENCY (no output register)
    generate
        if (RAM_PERFORMANCE == "LOW_LATENCY") begin: no_output_register

            // The following is a 1 clock cycle read latency at the cost of a longer clock-to-out timing
            assign r_out = ram_data;

        end else begin: output_register

        // The following is a 2 clock cycle read latency with improve clock-to-out timing

        reg [(NB_COL*COL_WIDTH)-1:0] doutb_reg = {(NB_COL*COL_WIDTH){1'b0}};

        always @(posedge clk)
            if (out_res)
                doutb_reg <= {(NB_COL*COL_WIDTH){1'b0}};
            else if (out_r_en)
                doutb_reg <= ram_data;

        assign r_out = doutb_reg;

        end
    endgenerate

    //  The following function calculates the address width based on specified RAM depth
    function integer clogb2;
        input integer depth;
        for (clogb2=0; depth>0; clogb2=clogb2+1)
            depth = depth >> 1;
    endfunction
        
endmodule