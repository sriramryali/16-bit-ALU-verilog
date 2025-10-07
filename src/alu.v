// Implementation of a parameterized 16-bit ALU
// This ALU supports arithmetic, logical, shift, rotate and comparision operations

`timescale 1ns/1ps
module alu #(
    parameter WIDTH = 16        // declaring a parameter for the width of bits, can be simply changed if needed
    )(
    input [WIDTH-1 : 0] a,
    input [WIDTH-1 : 0] b,
    input [4:0] opcode,
    output reg [WIDTH-1 : 0] result,
    output reg zero,           // zero flag
    output reg carry_out,      // a flag that detects if there is a carry out
    output reg overflow);      // a flag that detects if there is overflow 

    always @(*) begin
        
        carry_out = 1'b0;      // initialising all the flags to 0
        zero = 1'b0;
        overflow = 1'b0;
        
        case (opcode)
            
            // ARITHMETIC OPERATIONS
            5'b00000 : begin                  // ADD
                {carry_out, result} = a + b;
                overflow = (a[WIDTH-1] & b[WIDTH-1] & ~result[WIDTH-1]) | (~a[WIDTH-1] & ~b[WIDTH-1] & result[WIDTH-1]);
            end

            5'b00001 : begin                  // SUB
                {carry_out, result} = a - b;
                overflow = (a[WIDTH-1] & ~b[WIDTH-1] & ~result[WIDTH-1]) | (~a[WIDTH-1] & b[WIDTH-1] & result[WIDTH-1]);
            end

            5'b00010 : result = a * b;                            // MUL  ->  here, only the lower 16 bits are stored, rest are truncated (as multiplication of two 16-bit numbers results in a 32-bit number )
            5'b00011 : result = (b != 0) ? (a / b) : WIDTH'd0;    // QUOTIENT
            5'b00100 : result = (b != 0) ? (a % b) : WIDTH'd0;    // REMAINDER
            
            // LOGICAL OPERATIONS
            5'b00101 : result = a & b;          // AND
            5'b00110 : result = a | b;          // OR
            5'b00111 : result = a ^ b;          // XOR
            5'b01000 : result = ~(a & b);       // NAND
            5'b01001 : result = ~(a | b);       // NOR
            5'b01010 : result = ~(a ^ b);       // XNOR
            5'b01011 : result = ~a;             // bitwise NOT
            5'b01100 : result = -a;             // 2's complement negation
            
            // SHIFT OPERATIONS
            5'b01101 : result = a << b[3:0];              // SLL  -> shift left logical
            5'b01110 : result = a >> b[3:0];              // SRL  -> shift right logical 
            5'b01111 : result = $signed(a) >>> b[3:0];    // SRA  -> shift right arithmetic : sign bit is preserved
            
            // COMPARISON OPERATIONS
            5'b10000 : result = ($signed(a) < $signed(b)) ? WIDTH'd1 : WIDTH'd0;   // SLT  -> set less than
            5'b10001 : result = (a < b) ? WIDTH'd1 : WIDTH'd0;                     // SLTU  -> set less than unsigned
            
            // INCREMENT/DECREMENT OPERATIONS
            5'b10010 : result = a + 1;          // INC
            5'b10011 : result = a - 1;          // DEC
            
            // ROTATE OPERATIONS
            5'b10100 : result = {a[WIDTH-2 : 0], a[WIDTH-1]};    // ROT L  -> gets rotated by a single bit
            5'b10101 : result = {a[0], a[WIDTH-1 : 1]};    // ROT R  -> gets rotated by a single bit
            
            // PASS OPERATIONS
            5'b10110 : result = a;              // PASS a
            5'b10111 : result = b;              // PASS b
            default : result = WIDTH'd0;
        endcase

        zero = (result == WIDTH'd0);     // detects if the output is zero
    end

endmodule



        
    
    