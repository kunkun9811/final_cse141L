// Module Name:    Ctrl 
// Project Name:   CSE141L
//
// Revision Fall 2020
// Based on SystemVerilog source code provided by John Eldon
// Comment:
// This module is the control decoder (combinational, not clocked)
// Out of all the files, you'll probably write the most lines of code here
// inputs from instrROM, ALU flags
// outputs to program_counter (fetch unit)
// There may be more outputs going to other modules

/*** TEAM NOTES ***/
// Main Purpose: This is where we will decode our instructions

/* INPUT */
// instruction [8:0]

/* OUTPUTS */
// BRANCH - for branching. Outputs to InstrFetch
//	0: PC Increment by 1
//		- All instructions except BEQZ
//	1: PC set to Target addr
//		- BEQZ
//
// WD_SRC - mux to choose which data to write to reg file. Outputs to RegFile
// 	00: write data is instr[7:0] (immediate)
//		- SET
//	01: write data from data memory
//		- LOAD
//  10: write data from ALU output
//		- SLT, SL, SR, SUB, OR, AND, SGTE, ADD
//
// Reg_Write - used to signal writes in regfile. Outputs to RegFile
// 	0X: No write
//		- HALT, BEQZ, STORE
//	10: Write to R1
//		- SLT, LOAD, SL, SR, SUB, OR, AND, SGTE, SET
//	11: Write to RS
//		- CL, ADD
//
// ALU_OP - opcode for ALU. Outputs to ALU
// OPCODES:
//	0000: HALT
// 	0001: SLT
//	0010: LOAD
//	0011: BEQZ (sub -> check 0 flag)
//	0100: SL
//  0101: SR
//	0110: CL
// 	0111: SUB
//	1000: OR
//	1001: AND
//	1010: SGTE 
//	1011: STORE
// 	1100: ADD
//	1101: SET
//
// MEM_READ - read from data memory. Outputs to DataMem
// 0: Does not access memory
// 		- All instruction except LOAD
// 1: Accesses memory
// 		- LOAD
//
// MEM_WRITE - write to data memory. Outputs to DataMem
//	0: Does not access memory
//		- All instructions except STORE
//	1: Accesses memory
//		- STORE
/*** END of TEAM NOTES ***/

// TODO: Control module should deal with HALT instruction

module Ctrl (Instruction, BRANCH, WD_SRC, REG_WRITE, ALU_OP, MEM_READ, MEM_WRITE, OFC, HALT);

	input[ 8:0] 	Instruction;	   // machine code
	output reg 		BRANCH,
					MEM_READ,
					MEM_WRITE,
					OFC;				// overflow bit clear control signal. 1 => Clear, 0 => leave it alone :)
	output reg[1:0] WD_SRC,
					REG_WRITE;
	output reg[3:0]	ALU_OP;
	output reg 		HALT;		

	// jump on right shift that generates a zero
	always@*
	begin
		HALT = 1'b0;
		casez(Instruction[8:3])
			// HALT
			6'b000000: begin
				BRANCH = 0;
				WD_SRC = 'bz;
				REG_WRITE = 2'b00;	// just to be safe
				ALU_OP = 4'b0000;
				MEM_READ = 0;
				MEM_WRITE = 0;
				HALT = 1'b1;
				OFC = 1;
			end

			// 	0001: SLT
			6'b000001: begin
				BRANCH = 0;
				WD_SRC = 2'b10;		// data from ALU
				REG_WRITE = 2'b10;	// write to R1
				ALU_OP = 4'b0001;
				MEM_READ = 0;
				MEM_WRITE = 0;
				OFC = 0;
			end

			//	0010: LOAD
			6'b000010: begin
				BRANCH = 0;
				WD_SRC = 2'b01;		// data from data memory
				REG_WRITE = 2'b10;
				ALU_OP = 4'b0010;
				MEM_READ = 1;
				MEM_WRITE = 0;
				OFC = 0;
			end

			//	0011: BEQZ (sub -> check 0 flag)
			6'b000011: begin
				BRANCH = 1;
				WD_SRC = 'bzz;
				REG_WRITE = 2'b00;
				ALU_OP = 4'b0011;
				MEM_READ = 0;
				MEM_WRITE = 0;
				OFC = 0;
			end

			//	0100: SL
			6'b000100: begin
				BRANCH = 0;
				WD_SRC = 2'b10;
				REG_WRITE = 2'b10;
				ALU_OP = 4'b0100;
				MEM_READ = 0;
				MEM_WRITE = 0;
				OFC = 0;
			end

			//  0101: SR
			6'b000101: begin
				BRANCH = 0;
				WD_SRC = 2'b10;
				REG_WRITE = 2'b10;
				ALU_OP = 4'b0101;
				MEM_READ = 0;
				MEM_WRITE = 0;
				OFC = 0;
			end

			//	0110: CL
			6'b000110: begin
				BRANCH = 0;
				WD_SRC = 2'b10;
				REG_WRITE = 2'b11;
				ALU_OP = 4'b0110;
				MEM_READ = 0;
				MEM_WRITE = 0;
				OFC = 0;
			end
			
			//  0111: SUB
			6'b000111: begin
				BRANCH = 0;
				WD_SRC = 2'b10;
				REG_WRITE = 2'b10;
				ALU_OP = 4'b0111;
				MEM_READ = 0;
				MEM_WRITE = 0;
				OFC = 0;
			end
			
			//	1000: OFC
			6'b001000: begin
				BRANCH = 0;
				WD_SRC = 2'b11;
				REG_WRITE = 2'b00;
				ALU_OP = 4'b1000;
				MEM_READ = 0;
				MEM_WRITE = 0;
				OFC = 1;
			end
			
			//	1001: AND
			6'b001001: begin
				BRANCH = 0;
				WD_SRC = 2'b10;
				REG_WRITE = 2'b10;
				ALU_OP = 4'b1001;
				MEM_READ = 0;
				MEM_WRITE = 0;
				OFC = 0;
			end
			
			//	1010: SGTE 
			6'b001010: begin
				BRANCH = 0;
				WD_SRC = 2'b10;
				REG_WRITE = 2'b10;
				ALU_OP = 4'b1010;
				MEM_READ = 0;
				MEM_WRITE = 0;
				OFC = 0;
			end

			//	1011: STORE
			6'b011zzz: begin
				BRANCH = 0;
				WD_SRC = 2'bzz;
				REG_WRITE = 2'b00;
				ALU_OP = 4'b1011;
				MEM_READ = 0;
				MEM_WRITE = 1;
				OFC = 0;
			end

			// 	1100: ADD
			6'b010zzz: begin
				BRANCH = 0;
				WD_SRC = 2'b10;
				REG_WRITE = 2'b01;
				ALU_OP = 4'b1100;
				MEM_READ = 0;
				MEM_WRITE = 0;
				OFC = 0;
			end
			
			//	1101: SET
			6'b1zzzzz: begin
				BRANCH = 0;
				WD_SRC = 2'b00;
				REG_WRITE = 2'b10;
				ALU_OP = 4'b1011;
				MEM_READ = 0;
				MEM_WRITE = 0;
				OFC = 0;
			end

			// 1110: ADDC - Inverse and Sqrt use this :)
			6'b001011: begin
				BRANCH = 0;
				WD_SRC = 2'b10;			// from ALU
				REG_WRITE = 2'b11;		// because we write to RS => ADDC RS
				ALU_OP = 4'b1110;
				MEM_READ = 0;
				MEM_WRITE = 0;
				OFC = 0;
			end

			// 1111: XOR 
			6'b001100: begin
				BRANCH = 0;
				WD_SRC = 2'b10;			// from ALU
				REG_WRITE = 2'b10;		// because we write to R1, because we need to specify RS(the value to XOR with)
				ALU_OP = 4'b1111;
				MEM_READ = 0;
				MEM_WRITE = 0;
				OFC = 0;
			end
			
		endcase
	end
endmodule