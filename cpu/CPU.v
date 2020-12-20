// Module Name:    CPU 
// Project Name:   CSE141L
//
// Revision Fall 2020
// Based on SystemVerilog source code provided by John Eldon
// Comment:
// This is the TopLevel of your project
// Testbench will create an instance of your CPU and test it
// You may add a LUT if needed (Lookup Table)
// Set Ack to 1 to alert testbench that your CPU finishes doing a program or all 3 programs

/* Potential problem */
// 1. Our BEQZ instruction cannot jump to any 2^11 instructions. Because we only have 2^8 bits in our registers.
// 		- But, our 3 programs don't seem likt i has more than 2^8 instructions
	 
module CPU(Reset, Start, Clk, Ack);

	input Reset;			// init/reset, active high
	input Start;			// start next program
	input Clk;				// clock -- posedge used inside design
	output reg Ack;   		// done flag from DUT	TODO: DIFFERENCE
	wire Halt;				// TODO: DIFFERENCE

	
	// wire [ 2:0] Instr_opcode;  	// out 3-bit opcode

	/* InstFetch Module */
	wire [10:0] PgmCtr;        			// program counter
	wire		BRANCH,					// signal to branch
				ALU_ZERO;				// signal whether ALU's result == 0
												// 1 means yes
												// 0 means no

	/* Controller - Ctrl module */
	wire [8:0] 	Instruction;   				// our 9-bit instruction
	wire [1:0] 	WD_SRC,						// signal to choose regfile write data
					REG_WRITE;				// signal to write to reg file
	wire [3:0] 	ALU_OP,						// ALU Op output from controller
					ALU_OP_IN;				// ALU_OP_IN input for ALU
	wire 		MEM_READ,					// signal to read the data_memory
				MEM_WRITE;					// signal to write to data_memory


	/* Instruction ROM */ 
	// Already defined above
	// PgmCtr
	// Instruction

	/* RegFile */
	wire [2:0] 	regS_addr,
				regT_addr;
	wire [7:0] 	reg0,					// reg_file outputs
					reg1,
					regS, 
					regT,
					Imm,				// Inpur from Immediate value in the instruction
					ALU_result,			// Input from ALU_output
					mem_data;			// Input from Data Memory

	/* ALU */
	wire [7:0] 	reg0_data,				// ALU operand inputs
					reg1_data,
					regS_data, 
					regT_data, 	   		
					ALU_out;    		// ALU result output; 

	/* Data Memory */
	wire [7:0]	MemWriteValue; 			// data in to data_memory
	wire [7:0]	MemReadValue;			// data out from data_memory 					
	
	/* Debugging */	
	reg  [15:0] CycleCt;	      		// standalone; NOT PC!

	/* Overflow */
	wire		OverflowClear,
				Overflow_OUT;
	reg			Overflow_IN;
				

	// Fetch = Program Counter + Instruction ROM
	// Program Counter


	always@(posedge Halt) begin
		Ack <= Halt;
	end

	// For InstFetch
	wire [10:0]	Target;
	assign Target = {3'b000,reg0_data[7:0]}; // sign extend	Maybe we need to make this UNSIGNED as well

  	InstFetch IF1 (
		.Reset       	(Reset  ), 		// reset
		.Start       	(Start  ),  	// start
		.Clk         	(Clk    ),  	// clock
		.BRANCH			(BRANCH	),		// Branch flag
		.ALU_ZERO	 	(ALU_ZERO),		// Zero flag, whether or not ALU result == 0
		.Target      	(Target ),		// jump target ?
		.ProgCtr     	(PgmCtr )	   	// program count = index to instruction memory
	);	

	// Control decoder
	Ctrl Ctrl1 (
		.Instruction	(Instruction),	// from instr_ROM
		.BRANCH			(BRANCH),
		.WD_SRC			(WD_SRC),
		.REG_WRITE		(REG_WRITE),
		.ALU_OP			(ALU_OP),
		.MEM_READ		(MEM_READ),
		.MEM_WRITE		(MEM_WRITE),
		.OFC			(OverflowClear),	// Outputs whether or not to clear Overflow bit
		.HALT			(Halt)
	);
	
	assign ALU_OP_IN = ALU_OP;			// connect controller ALU_op with alu_op input of the ALU
  
	// instruction ROM
	InstROM IR1(
		.InstAddress   (PgmCtr), 
		.InstOut       (Instruction)
	);
	
	// assign LoadInst = Instruction[8:6]==3'b110;  // calls out load specially
	
	// always@*							  
	// begin
	// 	// Halt = Instruction[0];  // Update this to the condition you want to set done to true
	// 	Halt = 1'b1;
	// end
	
	//Reg file
	// Modify D = *Number of bits you use for each register*
   	// Width of register is 8 bits, do not modify
	assign regT_addr = Instruction[5:3];
	assign regS_addr = Instruction[2:0];
	assign Imm = 	   Instruction[7:0];

	RegFile #(.W(8),.D(3)) RF1 (
		.Clk    		(Clk),			
		.REG_WRITE		(REG_WRITE),		// Control signal for writing to registers
		.RS_addr		(regS_addr),		// 3 bit address for RS
		.RT_addr		(regT_addr),		// 3 bit address for RT
		.WD_SRC			(WD_SRC),			// Mux signal for Write_data source
		.Imm			(Imm),				// Immediate value
		.mem_data		(mem_data),			// Value read from data_mem
		.ALU_result		(ALU_result),		// Output of ALU
		.DataOut_RS		(regS),				// Contents of RS
		.DataOut_RT		(regT),				// Contents of RT
		.DataOut_R0		(reg0),				// Contents of R0
		.DataOut_R1		(reg1)				// Contents of R1
	);
	
	assign reg1_data = reg1;					// connect RF out to ALU in
	assign regS_data = regS;					
	assign regT_data = regT;
	assign reg0_data = reg0;					// reg0_data is also connected with target (written above)
	
	// assign MemWrite = (Instruction == 9'h111);                		// mem_store command
	// assign RegWriteValue = LoadInst? MemReadValue : ALU_out;  		// 2:1 switch into reg_file
	

	// Arithmetic Logic Unit
	ALU ALU1(
		.R1_data_in		(reg1_data),		// Data inside R1   	  
	  	.RS_data_in		(regS_data),		// Data inside RS
		.RT_data_in		(regT_data),		// Data inside RT
	  	.ALU_OP			(ALU_OP_IN),		// ALU Op code
	  	.Out			(ALU_out),		  	// ALU Output
	  	.ALU_ZERO		(ALU_ZERO),			// ALU Zero flag
		.OverflowIn		(Overflow_IN),
		.OverflowOut	(Overflow_OUT)
	);

	always @ (posedge Clk) begin
		if(Start == 1 || OverflowClear == 1)
			Overflow_IN = 0;
		else
			Overflow_IN = Overflow_OUT;
	end
	 
	assign ALU_result = ALU_out;
	assign MemWriteValue = regT_data;

	 // Data Memory
	 // Load RT
	 // STORE RT, RS
	DataMem DM1(
		.DataAddress  	(regS_data), 		// Data address from dataout_rs
		.MEM_WRITE      (MEM_WRITE), 		// Opcode for Mem_write
		.MEM_READ		(MEM_READ),			// Opcode for Mem_read
		.WriteData		(MemWriteValue), 	// value inside writedata
		.ReadData		(MemReadValue), 	// value inside readdata
		.Clk 		  	(Clk),			
		.Reset		  	(Reset)
	);

	assign mem_data = MemReadValue;

// count number of instructions executed
// Help you with debugging
	always @(posedge Clk)
		if (Start == 1)	   // if(start)
			CycleCt <= 0;
	  	else if(Ack == 0)   // if(!Ack)
		 	CycleCt <= CycleCt+16'b1;

endmodule	