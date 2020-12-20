// Module Name:    ALU 
// Project Name:   CSE141L
//
// Revision Fall 2020
// Based on SystemVerilog source code provided by John Eldon
// Comment:
// 

/*** NOTES ***/
/* Signals */
// ALU_OP
	/* ALUop Lookup Table */
	// 0000
		//(0) HALT
	// 0001
		//(1) SLT $RS
			// if(RS<r1): R1 = 1
			// else: R1 = 0

	// 0010
		//(2) LOAD $RT
			// R1 = MEM[RT]

	// 0011
		//(3) BEQZ LABEL
			// if(R1 == 0): PC = R0
			// else: PC = PC+1

	// 0100
		//(4) SL $RS
			// R1 << RS
			
	// 0101
		//(5) SR $RS
			// R1 >> RS

	// 0110
		//***(6) CL $RS
			// RS = 0
	
	// 0111
		//(7) SUB $RS
			// R1 = R1 - RS

	// 1000
		//(8) OR $RS
			// R1 = R1 | RS

	// 1001
		//(9) AND $RS
			// R1 = R1 & RS

	// 1010
		//(10) SGTE $RS
			// if(RS >= R1): R1 = 1
			// else: R1 = 0

	// 1011
		//(11) STORE $RS, $RT
			// MEM[RT] = RS

	// 1100
		//(12) ADD $RS, $RT
			// RS = RS + RT

	// 1101
		//(13) SET imm
			// R1 = imm

	// 1110 - this ALUop would be kinda weird, because other R format instructions' ALUop is the same as the bits in [3:6], but this one is added later and we do not want to touch other working hardware
	// TODO: Maybe add a new instruction - ADDC or add carry
		// what it will do is say ADDC $R3 = $R1 = $R3 + carry <-- the carry will be either 1 or 0 and the carry will be a "reg" variable in the ALU

		// this means that in our assembly code, every time we would like to do 2 "word" arithmetics addition/subtraction we need to do
		// Let's say our word right now is 4 bits and we are trying to add
		// 
		//	a = 0001 1000
		//	b = 0000 1000
		//
		// $R2 = a Lower word
		// $R3 = b Lower word
		// 
		// $R4 = a Higher word
		// $R5 = b Higher word
		// ADD $R2, $R3		<-- where $R2 has the arithmetic result of the lower word/byte and in our HARDWARE, the "reg" variable will save the carry bit(either 1 or 0)
		// ADDC $R4			<-- here can either be $R4 or $R5, since adding with carry bit is just $R4 + $R5 + carry bit

/* Inputs */
// R1_data_in
// RS_data_in
// RT_data_in

/* Outputs */
// alu_result
// ALU_ZERO

/*** END of ***/

	 
module ALU(	R1_data_in,
			RS_data_in,
			RT_data_in,
			ALU_OP,
			Out,
			ALU_ZERO,
			OverflowIn,
			OverflowOut);


	input signed [ 7:0] 		R1_data_in,
								RS_data_in,
								RT_data_in;
	input [ 3:0] 				ALU_OP;
	output reg signed [7:0]		Out; // logic in SystemVerilog
	output reg 					ALU_ZERO;

	input						OverflowIn;
	output reg 					OverflowOut;

	always@* 									// always_comb in systemverilog
	begin 
		Out = 0;								// initialize
		OverflowOut = OverflowIn;				// Just in case current instruction doesn't modify OverflowOut, need to keep OverflowOut Value
		case (ALU_OP)
			4'b0000: Out = 8'b0000_0000;					// HALT
			
			4'b0001: begin									// SLT
				if (RS_data_in < R1_data_in) Out = 1;
				else Out = 0;
			end 

			4'b0011: begin									// BEQZ
				if(R1_data_in == 0) begin
					Out = 0;	
				end
				else begin
					Out = 1;
				end 			
			end

			4'b0100: Out = R1_data_in << RS_data_in;		// SL
					
			4'b0101: Out = R1_data_in >> RS_data_in;		// SR
			
			4'b0110: Out = 8'b00000000;		 				// CL		
			
			4'b0111: Out = R1_data_in - RS_data_in; 		// SUB	

			4'b1000: OverflowOut = 1'b0;  					// Overflow Clear
			
			4'b1001: Out = R1_data_in & RS_data_in;			// AND	
			
			4'b1010: begin									// SGTE
				if (R1_data_in >= RS_data_in) Out = 1;		
				else Out = 0;
			end
			
			4'b1100: begin 									// ADD	
				Out = RS_data_in + RT_data_in;				
			end	

			4'b1110: begin									// ADDC
				{OverflowOut, Out} = R1_data_in + RS_data_in + OverflowIn;		// RS + carry
			end			

			4'b1111: begin									// XOR
				Out = R1_data_in ^ RS_data_in;
			end

	  	endcase
	
	end 

	/* if out == 0, Zero == 1 */
	always@*							  					// assign Zero = !Out;
	begin
		case(Out)
			0     	: ALU_ZERO <= 1'b1;
			default : ALU_ZERO <= 1'b0;
      endcase
	end

endmodule