// testbench for our 16-bit parameterized ALU
// As the number of operations are more, we use a task for automating the process (task is simply like a function which can be use multiple times)

`timescale 1ns/1ps
module alu_tb;
    reg [15:0] a;        // inputs to the DUT(design for test) are taken as reg and the outputs are taken as wires
    reg [15:0] b;
    reg [4:0] opcode;
    wire [15:0] result;
    wire zero;
    wire carry_out;
    wire overflow;

    integer passed = 0;            // to know how many testcases have passed, useful for tracking
    integer failed = 0;            // to know how many testcases have failed

    alu #(.WIDTH(16)) DUT(         // instantiating the ALU
        .a(a),
        .b(b),
        .opcode(opcode),
        .result(result),
        .zero(zero),
        .carry_out(carry_out),
        .overflow(overflow));
    
    // A function that checks if our outputs and the excpeted outputs are the same
    
    task check_result;
        input [15:0] expected_result;      // these are the expected output values, useful for matching with the obtained values
        input expected_zero;
        input expected_carry_out;
        input expected_overflow;
        input [200*8:1] operation_name;   // a simple string -> for storing the operation name
        
        begin
            #1;         // delay for letting signals settle
            
            if((result === expected_result) && (zero === expected_zero) && (carry_out === expected_carry_out) && (overflow === expected_overflow)) begin    // checking if the expected and the values we got are same
                $display(" PASS   :  %s", operation_name);
                $display("        a = %h, b = %h, opcode = %b", a, b, opcode);
                $display("        result = %h, zero = %b, carry = %b, overflow = %b", result, zero, carry_out, overflow);
                passed++;
            end

            else begin                                         // if the values are different
                $display(" FAIL   :  %s", operation_name);
                $display("        a = %h, b = %h, opcode = %b", a, b, opcode);
                $display("        Expected: result = %h, zero = %b, carry = %b, overflow = %b", expected_result, expected_zero, expected_carry_out, expected_overflow);
                $display("        Got: result = %h, zero = %b, carry = %b, overflow = %b", result, zero, carry_out, overflow);
                failed++;
            end
        end
    endtask

    // Testbench starts
    
    initial begin

        // Arithmetic operations
        
        // ADD
        a = 16'h0010; b = 16'h0030; opcode = 5'b00000;      // ADD
        check_result(16'h0040, 1'b0, 1'b0, 1'b0, "ADD");

        a = 16'h0000; b = 16'h0000; opcode = 5'b00000;      // ADD with zero flag
        check_result(16'h0000, 1'b1, 1'b0, 1'b0, "ADD"); 

        a = 16'hffff; b = 16'h0001; opcode = 5'b00000;      // ADD with carry out, there is a carry out in this case, here both numbers are assumed to be unsigned
        check_result(16'h0000, 1'b1, 1'b1, 1'b0, "ADD");

        a = 16'h7fff; b = 16'h0001; opcode = 5'b00000;      // ADD with overflow, output's first 4 bits : 1000 -> adding two +ve numbers gave a -ve result, here both numbers are assumed to be signed
        check_result(16'h8000, 1'b0, 1'b0, 1'b1, "ADD");                            
         
        // SUB
        a = 16'h0030; b = 16'h0020; opcode = 5'b00001;      // SUB
        check_result(16'h0010, 1'b0, 1'b0, 1'b0, "SUB");

        a = 16'h0040; b = 16'h0040; opcode = 5'b00001;      // SUB with zero flag
        check_result(16'h0000, 1'b1, 1'b0, 1'b0, "SUB");

        a = 16'h0030; b = 16'h0040; opcode = 5'b00001;      // SUB with borrow, there is a borrow(it is reflected as carry_out) in this case, here both numbers are assumed to be unsigned
        check_result(16'hfff0, 1'b0, 1'b1, 1'b0, "SUB");

        a = 16'h8000; b = 16'h0001; opcode = 5'b00001;      // SUB with overflow, output'f first 4 bits : 0111 -> subtracting a +ve number from a -ve number resulted in a +ve number, here both numbers are assumed to be signed 
        check_result(16'h7fff, 1'b0, 1'b0, 1'b1, "SUB");

        // MUL
        a = 16'h0005; b = 16'h0006; opcode = 5'b00010;      // MUL
        check_result(16'h001E, 1'b0, 1'b0, 1'b0, "MUL");
        
        a = 16'h0100; b = 16'h0100; opcode = 5'b00010;      // MUL with upper bits truncated
        check_result(16'h0000, 1'b1, 1'b0, 1'b0, "MUL");
        
        // DIV 
        a = 16'h0064; b = 16'h000A; opcode = 5'b00011;      // DIV
        check_result(16'h000A, 1'b0, 1'b0, 1'b0, "DIV");    
        
        a = 16'h0064; b = 16'h0000; opcode = 5'b00011;      // here b = 16'0000 -> a/b is not defined, so a zero flag is set
        check_result(16'h0000, 1'b1, 1'b0, 1'b0, "DIV");
        
        // MOD 
        a = 16'h0065; b = 16'h000A; opcode = 5'b00100;
        check_result(16'h0005, 1'b0, 1'b0, 1'b0, "MOD");
        
        a = 16'h0064; b = 16'h0000; opcode = 5'b00100;
        check_result(16'h0000, 1'b1, 1'b0, 1'b0, "MOD");

        // Logical operations

        a = 16'hAAAA; b = 16'h5555; opcode = 5'b00101;       // AND                
        check_result(16'h0000, 1'b1, 1'b0, 1'b0, "AND");
        
        a = 16'hAAAA; b = 16'h5555; opcode = 5'b00110;       // OR
        check_result(16'hFFFF, 1'b0, 1'b0, 1'b0, "OR");
        
        a = 16'hAAAA; b = 16'h5555; opcode = 5'b00111;       // XOR
        check_result(16'hFFFF, 1'b0, 1'b0, 1'b0, "XOR");
        
        a = 16'hFFFF; b = 16'hFFFF; opcode = 5'b01000;       // NAND
        check_result(16'h0000, 1'b1, 1'b0, 1'b0, "NAND");
        
        a = 16'h0000; b = 16'h0000; opcode = 5'b01001;       // NOR
        check_result(16'hFFFF, 1'b0, 1'b0, 1'b0, "NOR");
        
        a = 16'hAAAA; b = 16'h5555; opcode = 5'b01010;       // XNOR
        check_result(16'h0000, 1'b1, 1'b0, 1'b0, "XNOR");
        
        a = 16'hAAAA; b = 16'h0000; opcode = 5'b01011;       // NOT
        check_result(16'h5555, 1'b0, 1'b0, 1'b0, "NOT");
        
        a = 16'h0001; b = 16'h0000; opcode = 5'b01100;       // NEG
        check_result(16'hFFFF, 1'b0, 1'b0, 1'b0, "NEG"); 

        // Shift operations
        
        // SLL
        a = 16'h0001; b = 16'h0004; opcode = 5'b01101;       // SLL
        check_result(16'h0010, 1'b0, 1'b0, 1'b0, "SLL");
        
        // SRL
        a = 16'h0080; b = 16'h0004; opcode = 5'b01110;       // SRL
        check_result(16'h0008, 1'b0, 1'b0, 1'b0, "SRL");
        
        // SRA
        a = 16'h8000; b = 16'h0004; opcode = 5'b01111;       // SRA
        check_result(16'hF800, 1'b0, 1'b0, 1'b0, "SRA");
        
        a = 16'h0800; b = 16'h0004; opcode = 5'b01111;       // SRA
        check_result(16'h0080, 1'b0, 1'b0, 1'b0, "SRA");

        // Comparision operations
        
        //SLT
        a = 16'hFFFE; b = 16'h0001; opcode = 5'b10000;      // COMP : signed numbers
        check_result(16'h0001, 1'b0, 1'b0, 1'b0, "SLT");
        
        a = 16'h0001; b = 16'hFFFE; opcode = 5'b10000;      // COMP : signed numbers
        check_result(16'h0000, 1'b1, 1'b0, 1'b0, "SLT");
        
        //SLTU
        a = 16'hFFFE; b = 16'h0001; opcode = 5'b10001;      // COMP : unsigned numbers
        check_result(16'h0000, 1'b1, 1'b0, 1'b0, "SLTU");
        
        a = 16'h0001; b = 16'hFFFE; opcode = 5'b10001;      // COMP : unsigned numbers
        check_result(16'h0001, 1'b0, 1'b0, 1'b0, "SLTU");

        // Increment/Decrement operations
        
        // INC
        a = 16'h0005; b = 16'h0000; opcode = 5'b10010;      // INC
        check_result(16'h0006, 1'b0, 1'b0, 1'b0, "INC");
        
        a = 16'hFFFF; b = 16'h0000; opcode = 5'b10010;      // INC with carry out -> wrap around condition
        check_result(16'h0000, 1'b1, 1'b1, 1'b0, "INC");
        
        // DEC
        a = 16'h0005; b = 16'h0000; opcode = 5'b10011;      // DEC
        check_result(16'h0004, 1'b0, 1'b0, 1'b0, "DEC");
        
        a = 16'h0000; b = 16'h0000; opcode = 5'b10011;      // DEC with borrow (it is reflected as carry_out) -> wrap around condition
        check_result(16'hFFFF, 1'b0, 1'b1, 1'b0, "DEC");

        // Rotate operations

        a = 16'h8001; b = 16'h0000; opcode = 5'b10100;      // ROT L
        check_result(16'h0003, 1'b0, 1'b0, 1'b0, "ROTL");

        a = 16'h8001; b = 16'h0000; opcode = 5'b10101;      // ROT R
        check_result(16'hC000, 1'b0, 1'b0, 1'b0, "ROTR");

        // Pass operations

        a = 16'hf4d0; b = 16'hffff; opcode = 5'b10110;       // PASS A
        check_result(16'hf4d0, 1'b0, 1'b0, 1'b0, "PASS A");

        a = 16'h56a3; b = 16'h0050; opcode = 5'b10111;       // PASS B
        check_result(16'h0050, 1'b0, 1'b0, 1'b0, "PASS B");

        // default 

        a = 16'h234a; b = 16'h1234; opcode = 5'b11000;        // for opcodes from 24 to 31 -> default
        check_result(16'h0000, 1'b1, 1'b0, 1'b0, "DEFAULT");

        // Summary

        #10;
        $display(" Passed cases  : %d", passed);
        $display(" Failed cases  : %d", failed);

        if (failed == 0)
            $display(" All testcases passed ");
        else
            $display(" Some testcases failed");

        $finish;
    end
endmodule





        



        








                

                


    




