// Program memory of the CPU
// Created:     2024-01-20
// Modified:    2024-08-15 (status: working fine)
// Author:      Kagan Dikmen

// Not used in the current design

module program_memory 
    #(
    parameter OPD_WIDTH = 32,
    parameter PC_WIDTH = 12
    )(
    input clk,
    input rst,
    input [PC_WIDTH-1:0] addr,

    output reg [31:0] data,
    output reg [OPD_WIDTH-1:0] pc
    );

    `include "../lib/common_library.vh"
    `include "../lib/instr_generator.vh"

    integer i;

    (* ram_style = "block" *) reg [7:0] pmem [2**PC_WIDTH-1:0];

    // localparam testinstr_1 = {7'b0, 5'd4, 5'd3, 3'b0, 5'd2, R_OPCODE};                  
    localparam testinstr_1 = r_instr(FUNCT3_ADD, FUNCT7_ADD, 5'd2, 5'd3, 5'd4);         // ADD x2, x3, x4
    // localparam testinstr_2 = {7'b0, 5'd5, 5'd3, 3'b0, 5'd2, R_OPCODE};                  
    localparam testinstr_2 = r_instr(FUNCT3_ADD, FUNCT7_ADD, 5'd2, 5'd3, 5'd5);         // ADD x2, x3, x5
    // localparam testinstr_3 = {12'd4, 5'd3, 3'b0, 5'd2, I_OPCODE};                       
    localparam testinstr_3 = i_instr(FUNCT3_ADDI, 5'd2, 5'd3, 12'd4);                   // ADDI x2, x3, 4
    // localparam testinstr_4 = {12'd8, 5'd4, FUNCT3_LW, 5'd3, LOAD_OPCODE};               
    localparam testinstr_4 = load_instr(FUNCT3_LW, 5'd3, 12'd8, 5'd4);                  // LW x3 8(x4)
    // localparam testinstr_5 = {7'b0, 5'd4, 5'd3, FUNCT3_SW, 5'd12, S_OPCODE};         
    localparam testinstr_5 = s_instr(FUNCT3_SW, 5'd4, 12'd12, 5'd3);                    // SW x4 12(x3)
    //localparam testinstr_6 = {7'b0, 5'd4, 5'd3, FUNCT3_BGE, 5'b01100, B_OPCODE};   
    localparam testinstr_6 = b_instr(FUNCT3_BGE, 'd3, 'd4, 'd12);                       // BGE x3 x4 12
    // localparam testinstr_7 = {1'b0, 10'd40, 1'b0, 8'b0, 5'd3, JAL_OPCODE};              
    localparam testinstr_7 = jal_instr('d3, 'd80);                                      // JAL x3, 80
    // localparam testinstr_8 = {12'd120, 5'd4, FUNCT3_JALR, 5'd3, JALR_OPCODE};        
    localparam testinstr_8 = jalr_instr('d3, 'd4, 'd120);                               // JALR x3 x4 120
    // localparam testinstr_9 = {20'd2, 5'd10, LUI_OPCODE};                             
    localparam testinstr_9 = lui_instr('d10, 'd2);                                      // LUI x10 2
    // localparam testinstr_10 = {20'd2, 5'd15, AUIPC_OPCODE};                          
    localparam testinstr_10 = auipc_instr('d15, 'd2);                                   // AUIPC x15 2
    localparam testinstr_11 = {12'd4, 5'd0, FUNCT3_ADDI, 5'd0, I_OPCODE};               // ADDI x0 x0 4
    localparam testinstr_12 = {12'd3, 5'd0, FUNCT3_ADDI, 5'd1, I_OPCODE};               // ADDI x1 x0 3
    localparam testinstr_13 = {12'd2, 5'd0, FUNCT3_ADDI, 5'd2, I_OPCODE};               // ADDI x2 x0 2
    localparam testinstr_14 = {12'd1, 5'd2, FUNCT3_ADDI, 5'd2, I_OPCODE};               // ADDI x2 x2 1
    localparam testinstr_15 = b_instr(FUNCT3_BGE, 'd1, 'd2, 'b1111111111100);           // BGE x1 x2 -4
    localparam testinstr_16 = {12'd1020, 5'd0, FUNCT3_ADDI, 5'd4, I_OPCODE};            // ADDI x4 x0 1020
    localparam testinstr_17 = {12'd604, 5'd0, FUNCT3_ADDI, 5'd5, I_OPCODE};             // ADDI x5 x0 604
    localparam testinstr_18 = {7'b0, 5'd4, 5'd2, FUNCT3_SH, 5'd12, S_OPCODE};           // SH x4 12(x2)
    localparam testinstr_19 = {7'b0, 5'd5, 5'd2, FUNCT3_SB, 5'd12, S_OPCODE};           // SB x5 12(x2)
    localparam testinstr_20 = lui_instr('d5, 'd1000000);                                // LUI x5 1000000
    localparam testinstr_21 = {12'd4075, 5'd5, FUNCT3_ADDI, 5'd5, I_OPCODE};            // ADDI x5 x5 4075
    localparam testinstr_22 = {7'b0, 5'd5, 5'd2, FUNCT3_SB, 5'd12, S_OPCODE};           // SB x5 12(x2)
    localparam testinstr_23 = {7'b0, 5'd5, 5'd2, FUNCT3_SH, 5'd12, S_OPCODE};           // SH x5 12(x2)
    localparam testinstr_24 = {7'b0, 5'd5, 5'd2, FUNCT3_SW, 5'd12, S_OPCODE};           // SW x5 12(x2)
    localparam testinstr_25 = {12'd1, 5'd2, FUNCT3_ADDI, 5'd2, I_OPCODE};               // ADDI x2 x2 1     // to test HALFWORD/WORD access (should throw an error if addr%2!=0 for HW, or addr%4!=0 for W)
    localparam testinstr_26 = jal_instr('d3, 20'b11111111111111011000);                 // JAL x3 -40
    localparam testinstr_27 = 32'b0;                                                    // Invalid Operation

    always @(posedge clk)
    begin
        if (rst == 1'b1) 
        begin
            for (i=0; i<2**PC_WIDTH; i=i+1)
            begin
                pmem [i] <= 32'b0;
            end
            
            // a little bit of cheating for testing purposes
            
            // ADD x2, x3, x4
            pmem[0] <= testinstr_1[7:0];
            pmem[1] <= testinstr_1[15:8];
            pmem[2] <= testinstr_1[23:16];
            pmem[3] <= testinstr_1[31:24];

            // ADD x2, x3, x5
            pmem[4] <= testinstr_2[7:0];
            pmem[5] <= testinstr_2[15:8];
            pmem[6] <= testinstr_2[23:16];
            pmem[7] <= testinstr_2[31:24];

            // ADDI x2, x3, 4
            pmem[8] <= testinstr_3[7:0];
            pmem[9] <= testinstr_3[15:8];
            pmem[10] <= testinstr_3[23:16];
            pmem[11] <= testinstr_3[31:24];

            // LW x3 8(x4)
            pmem[12] <= testinstr_4[7:0];
            pmem[13] <= testinstr_4[15:8];
            pmem[14] <= testinstr_4[23:16];
            pmem[15] <= testinstr_4[31:24];

            // SW x4 12(x3)
            pmem[16] <= testinstr_5[7:0];
            pmem[17] <= testinstr_5[15:8];
            pmem[18] <= testinstr_5[23:16];
            pmem[19] <= testinstr_5[31:24];

            // BGE x3 x4 12
            pmem[20] <= testinstr_6[7:0];
            pmem[21] <= testinstr_6[15:8];
            pmem[22] <= testinstr_6[23:16];
            pmem[23] <= testinstr_6[31:24];

            // JAL x3, 80
            pmem[24] <= testinstr_7[7:0];
            pmem[25] <= testinstr_7[15:8];
            pmem[26] <= testinstr_7[23:16];
            pmem[27] <= testinstr_7[31:24];

            // JALR x3 x4 120
            pmem[104] <= testinstr_8[7:0];
            pmem[105] <= testinstr_8[15:8];
            pmem[106] <= testinstr_8[23:16];
            pmem[107] <= testinstr_8[31:24];

            // LUI x10 2
            pmem[132] <= testinstr_9[7:0];
            pmem[133] <= testinstr_9[15:8];
            pmem[134] <= testinstr_9[23:16];
            pmem[135] <= testinstr_9[31:24];

            // AUIPC x15 2
            pmem[136] <= testinstr_10[7:0];
            pmem[137] <= testinstr_10[15:8];
            pmem[138] <= testinstr_10[23:16];
            pmem[139] <= testinstr_10[31:24];

            // ADDI x0, x0, 4
            pmem[140] <= testinstr_11[7:0];
            pmem[141] <= testinstr_11[15:8];
            pmem[142] <= testinstr_11[23:16];
            pmem[143] <= testinstr_11[31:24];

            // ADDI x1, x0, 4
            pmem[144] <= testinstr_12[7:0];
            pmem[145] <= testinstr_12[15:8];
            pmem[146] <= testinstr_12[23:16];
            pmem[147] <= testinstr_12[31:24];

            // ADDI x2, x0, 2
            pmem[148] <= testinstr_13[7:0];
            pmem[149] <= testinstr_13[15:8];
            pmem[150] <= testinstr_13[23:16];
            pmem[151] <= testinstr_13[31:24];

            // ADDI x2, x2, 1
            pmem[152] <= testinstr_14[7:0];
            pmem[153] <= testinstr_14[15:8];
            pmem[154] <= testinstr_14[23:16];
            pmem[155] <= testinstr_14[31:24];

            // BGE x1 x2 -4
            pmem[156] <= testinstr_15[7:0];
            pmem[157] <= testinstr_15[15:8];
            pmem[158] <= testinstr_15[23:16];
            pmem[159] <= testinstr_15[31:24];

            // ADDI x4 x0 1020
            pmem[160] <= testinstr_16[7:0];
            pmem[161] <= testinstr_16[15:8];
            pmem[162] <= testinstr_16[23:16];
            pmem[163] <= testinstr_16[31:24];

            // ADDI x5 x0 604
            pmem[164] <= testinstr_17[7:0];
            pmem[165] <= testinstr_17[15:8];
            pmem[166] <= testinstr_17[23:16];
            pmem[167] <= testinstr_17[31:24];

            // SH x4 12(x2)
            pmem[168] <= testinstr_18[7:0];
            pmem[169] <= testinstr_18[15:8];
            pmem[170] <= testinstr_18[23:16];
            pmem[171] <= testinstr_18[31:24];

            // SB x5 12(x2)
            pmem[172] <= testinstr_19[7:0];
            pmem[173] <= testinstr_19[15:8];
            pmem[174] <= testinstr_19[23:16];
            pmem[175] <= testinstr_19[31:24];

            // LUI x5 12
            pmem[176] <= testinstr_20[7:0];
            pmem[177] <= testinstr_20[15:8];
            pmem[178] <= testinstr_20[23:16];
            pmem[179] <= testinstr_20[31:24];

            // ADDI x5 x5 4075
            pmem[180] <= testinstr_21[7:0];
            pmem[181] <= testinstr_21[15:8];
            pmem[182] <= testinstr_21[23:16];
            pmem[183] <= testinstr_21[31:24];

            // SB x5 12(x2)
            pmem[184] <= testinstr_22[7:0];
            pmem[185] <= testinstr_22[15:8];
            pmem[186] <= testinstr_22[23:16];
            pmem[187] <= testinstr_22[31:24];

            // SH x5 12(x2)
            pmem[188] <= testinstr_23[7:0];
            pmem[189] <= testinstr_23[15:8];
            pmem[190] <= testinstr_23[23:16];
            pmem[191] <= testinstr_23[31:24];

            // SW x5 12(x2)
            pmem[192] <= testinstr_24[7:0];
            pmem[193] <= testinstr_24[15:8];
            pmem[194] <= testinstr_24[23:16];
            pmem[195] <= testinstr_24[31:24];

            // ADDI x5 x5 1
            pmem[196] <= testinstr_25[7:0];
            pmem[197] <= testinstr_25[15:8];
            pmem[198] <= testinstr_25[23:16];
            pmem[199] <= testinstr_25[31:24];

            // JAL x3 -40
            pmem[200] <= testinstr_26[7:0];
            pmem[201] <= testinstr_26[15:8];
            pmem[202] <= testinstr_26[23:16];
            pmem[203] <= testinstr_26[31:24];

            // Invalid Operation
            pmem[204] <= testinstr_27[7:0];
            pmem[205] <= testinstr_27[15:8];
            pmem[206] <= testinstr_27[23:16];
            pmem[207] <= testinstr_27[31:24];
            
        end
    end

    always @(posedge clk)
    begin
        data <= {pmem[addr+3], pmem[addr+2], pmem[addr+1], pmem[addr]};
        pc <= addr;
    end
endmodule