# ALU module documentation

## Module description
A parameterized 16-bit Arithmetic Logic Unit (ALU) that supports 24 operations including arithmetic, logical, shift, rotate, comparison, increment/decrement, and pass-through operations.

## Parameters
-> 'WIDTH' : size of data ( default : 16)

## Ports
-> a : 16-bit input
-> b : 16-bit input
-> opcode : 5-bit input (for selecting the operation)
-> result : 16-bit output

## Flags
-> zero : a zero flag that detects if the result is zero
-> carry_out : a flag that detects if there is a carry out (in case of unsigned numbers)
-> overflow : a flag that detects if there is an overflow (in case of signed numbers)

## Opcode table
 There are a total of 24 operations in this ALU including arithmetic, logical, shift, rotate, increment, decrement, comparison and pass operartions.

 00000 - ADD    | 00101 - AND    | 01101 - SLL   | 10100 - ROTL
 00001 - SUB    | 00110 - OR     | 01110 - SRL   | 10101 - ROTR
 00010 - MUL    | 00111 - XOR    | 01111 - SRA   | 10110 - PASSA
 00011 - DIV    | 01000 - NAND   | 10000 - SLT   | 10111 - PASSB
 00100 - MOD    | 01001 - NOR    | 10001 - SLTU  |
                | 01010 - XNOR   | 10010 - INC   |
                | 01011 - NOT    | 10011 - DEC   |
                | 01100 - NEG    |               |

## Key notes
-> multiplication result is truncated to WIDTH(default : 16) bits, the lower ones(as multiplication of two 16-bit numbers results in 32-bit output)
-> division/ modulo by 0 returns 0
-> shifts use b[3:0] : 0 - 15
-> as of now, rotate operates by 1-bit
-> see source code comments for detailed operation descriptions