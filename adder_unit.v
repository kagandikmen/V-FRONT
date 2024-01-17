// Adder unit for the adder of the ALU
// Created:     2024-01-17
// Modified:    2024-01-17 (last status: working fine)
// Author:      Kagan Dikmen


module adder_unit
    (input a,
    input b,
    input c_in,
    
    output out,
    output c_out);

    assign out = (a ^ b) ^ c_in;
    assign c_out = (a & b) | ((a ^ b) & c_in);

endmodule