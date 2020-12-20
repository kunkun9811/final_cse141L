`timescale 1ns/ 1ps



//Test bench
//Arithmetic Logic Unit
/*
* INPUT: A, B
* op: 00, A PLUS B
* op: 01, A AND B
* op: 10, A OR B
* op: 11, A XOR B
* OUTPUT A op B
* equal: is A == B?
* even: is the output even?
*/


module ALU_tb;
reg signed [ 7:0] INPUTA;   	// data inputs
reg signed [ 7:0] INPUTB;	
reg signed [ 7:0] INPUTC;	
reg [ 4:0] op;			// ALU opcode, part of microcode
wire signed [ 7:0] OUT;		  

wire Zero;
reg Zero_result;    
 
reg signed [ 7:0] expected;
 
// CONNECTION
ALU uut(
  .R1_data_in	(INPUTA),      	  
  .RS_data_in	(INPUTB),
  .RT_data_in	(INPUTC),
  .ALU_OP		(op),		// ALU_OP		  
  .Out			(OUT),		// ALU output	  			
  .ALU_ZERO		(Zero)		// ALU zero signal
);
	 
initial begin

	// ADD
	//Output should be 14
	// INPUTA = 55;	// R1
	// INPUTB = -10;	// RS
	// INPUTC = 4; 	// RT
	// op= 'b1100; 	// ADD
	// test_alu_func; 	// void function call
	// #5;
	
	// SUB
	//Output
	// INPUTA = 55;	// R1
	// INPUTB = -10;	// RS
	// INPUTC = 80; 	// RT
	// op= 'b0111; 	// SUB
	// test_alu_func; 	// void function call
	// #5;

	// SLT
	//Output should be 1 because InputB < InputA
	// INPUTA = 55;	// R1
	// INPUTB = -10;	// RS
	// INPUTC = 80; 	// RT
	// op= 'b0001; 	// SLT 
	// test_alu_func; 	// void function call
	// #5;

	// BEQZ
	//Output should be 0 because INPUTA is not equal to 0 
	// INPUTA = -10;	// R1
	// INPUTB = -10;	// RS
	// INPUTC = 80; 	// RT
	// op= 'b0111; 	// SUB
	// test_alu_func; 	// void function call
	// #5;

	// SL
	// Output should be 1 because INPUTA (R1) does not equal to 0
	// INPUTA = 5;
	// INPUTB = 6;
	// INPUTC = 52;
	// op= 'b0100; 	// SL
	// test_alu_func; 	// void function call
	// #5;

	// SR
	// Output should be 16
	// INPUTA = 420;
	// INPUTB = 2;
	// INPUTC = 88;
	// op= 'b0101; 	// Shift left
	// test_alu_func; 	// void function call
	// #5;

	// CL
	// Output should be 1 because INPUTA (R1) does not equal to 0
	// INPUTA = 15;
	// INPUTB = 1522;
	// INPUTC = 3;
	// op= 'b0110; 	// BEQZ
	// test_alu_func; 	// void function call
	// #5;

	// OR output should be 0111 or 7
	// Output should be 16
	INPUTA = 6;
	INPUTB = 7;
	INPUTC = 88;
	op= 'b1000; 	// Shift left
	test_alu_func; 	// void function call
	#5;

	// AND
	// Output should be 4
	// INPUTA = 6;
	// INPUTB = 4;
	// INPUTC = 88;
	// op= 'b1001; 	// Shift left
	// test_alu_func; 	// void function call
	// #5;
	
	// SGTE
	// Output should be 1 because INPUTA (R1) does not equal to 0
	// INPUTA = 5;
	// INPUTB = 10;
	// INPUTC = 52;
	// op= 'b1010; 	// BEQZ
	// test_alu_func; 	// void function call
	// #5;

end
	
	task test_alu_func;
		begin
			expected = 0;
			Zero_result = 1'b0;

			case (op)
					4'b0000: expected = 8'b0000_0000;					// HALT
					
					4'b0001: begin										// SLT
						if (INPUTB < INPUTA) begin
							expected = 1'b1;
						end
						else begin
							expected = 1'b0;
						end
					end 

					4'b0011: begin										// BEQZ
						if(INPUTA == 0) begin
							expected = 1;
							Zero_result = 1'b1;		
						end
						else begin
							expected = 0;	
							Zero_result = 1'b0;
						end 			
					end

					4'b0100: expected = INPUTA << INPUTB;				// SL
							
					4'b0101: expected = INPUTA >> INPUTB;				// SR
					
					4'b0110: expected = 0;		 						// CL		
					
					4'b0111: expected = INPUTA - INPUTB; 				// Subtract: SUB	

					4'b1000: expected = INPUTA | INPUTB; 				// Or	
					
					4'b1001: expected = INPUTA & INPUTB;	 			// AND	
					
					4'b1010: begin									    // SGTE
						if (INPUTB >= INPUTA) begin
							expected = 1'b1;
						end	
						else begin
							expected = 1'b0;
						end
					end	
					
					4'b1100: expected = INPUTB + INPUTC;				// ADD
			endcase

			/* if out == 0, Zero == 1 */
			// always@(posedge expected, negedge expected)							  // assign Zero = !Out;
			// 	begin
			// 		case(expected)
			// 			0     	: Zero_result = 1'b1;
			// 			default : Zero_result = 1'b0;
			// 	endcase
			// end
			#1; 
			
			case(op)
				4'b1100: 
				begin										// ADD
					if(expected == OUT && Zero_result == Zero)
						begin
							$display("%t SUCCESS!!\ninputs = %d %d, opcode = %b\n\tExpected: Expected=%d, Zero=%d\n\tOur_output=%d, Our_Zero=%d",$time, INPUTB, INPUTC, op, expected, Zero_result, OUT, Zero);
						end
					else begin $display("%t FAIL! inputs = %d %d, opcode = %b\n\tExpected: Expected=%d, Zero=%d\n\tOur_output=%d, Our_Zero=%d",$time, INPUTB, INPUTC, op, expected, Zero_result, OUT, Zero);end
				end
			
				default: 
				begin
					if(expected == OUT && Zero_result == Zero)
						begin
							$display("%t SUCCESS!! inputs = %d %d, opcode = %b\n\tExpected: Expected=%d, Zero=%d\n\tOur_output=%d, Our_Zero=%d",$time, INPUTA,INPUTB, op, expected, Zero_result, OUT, Zero);
						end
					else 
						begin 
							$display("%t FAIL! inputs = %d %d, opcode = %b\n\tExpected: Expected=%d, Zero=%d\n\tOur_output=%d, Our_Zero=%d",$time, INPUTA,INPUTB, op, expected, Zero_result, OUT, Zero);
						end
				end
			endcase
		end
	endtask
endmodule