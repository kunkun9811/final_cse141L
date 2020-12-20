// Module Name:    RegFile 
// Project Name:   CSE141L
//
// Revision Fall 2020
// Based on SystemVerilog source code provided by John Eldon
// Comment:
// This module is your register file.
// If you have more or less bits for your registers, update the value of D.
// Ex. If you only supports 8 registers. Set D = 3

/* parameters are compile time directives 
       this can be an any-size reg_file: just override the params!
*/

/*** NOTES ***/
/* SIGNALS */
// [1 bit]Clk
// [2 bits]REG_WRITE
	// 01 = write to RT
	// 10 = write to R1
	// 11 = write to RS
	// 00 = DON'T write to REG FILE
// [2 bits]WD_SRC
	// 00 = immediate [7:0]
	// 01 = write data is from data memory
	// 10 = write data is from ALU output
	// anything else = N
/* INPUT */
// [3 bits]RS_addr - register number for RS
// [3 bits]RT_addr - register number for RT
// [8 bits]Write_Data - data to write to R1 or RS with data from one of the 3 following:
	// [8 bits]Imm - immediate value from instruction [7:0]
	// [8 bits]ALU_result - result from ALU
	// [8 bits]mem_data - result from Data Memory

/* OUTPUT */
// DataOut_RS
// DataOut_RT
// DataOut_R1
// DataOut_R0


/*** END of NOTES ***/

module RegFile (Clk,
				REG_WRITE,
				RS_addr,
				RT_addr,
				WD_SRC,
				Imm,
				mem_data,
				ALU_result,
				DataOut_RS,
				DataOut_RT, 
				DataOut_R0, 
				DataOut_R1);
				// DataOut_R6);
		parameter 		W=8, D=3;  // W = data path width (Do not change); D = pointer width (You may change)
		input           Clk;
		input[1:0]		REG_WRITE,
						WD_SRC;
		input        	[D-1:0] RS_addr,		// address pointers
								RT_addr;

		input[W-1:0]	Imm,
						mem_data,
						ALU_result;		// TODO: This will be 

		reg        		[W-1:0] Write_Data;
		
		output reg   	[W-1:0] DataOut_RS;			  
		output reg   	[W-1:0] DataOut_RT;		
		output reg 		[W-1:0] DataOut_R0;
		output reg 		[W-1:0] DataOut_R1;

		// TODO: To be deleted
		// output reg		[W-1:0] DataOut_R6;

	// W bits wide [W-1:0] and 2**4 registers deep 	 
	// reg [W-1:0] Registers[(2**D)-1:0];	  // or just registers[16-1:0] if we know D=4 always
	reg [W-1:0] Registers[(2**D)-1:0];

	// NOTE:
	// READ is combinational
	// WRITE is sequential

	always@* begin
		DataOut_RS = Registers[RS_addr];	  
		DataOut_RT = Registers[RT_addr];
	end

	// sequential (clocked) writes 
	always @ (posedge Clk) begin
		case(WD_SRC) // Mux that chooses Write_Data
			2'b00: Write_Data = Imm[7:0];				// 00 = immediate [7:0]
			2'b01: Write_Data = mem_data[7:0];			// 01 = write data is from data memory
			2'b10: Write_Data = ALU_result[7:0];		// 10 = write data is from ALU output
			default: Write_Data = 8'bzzzzzzz;
		endcase

		case(REG_WRITE)
			2'b01: Registers[RT_addr] = Write_Data;		// 01 - write to RT
			2'b10: Registers[1] = Write_Data;			// 10 - write to R1
			2'b11: Registers[RS_addr] = Write_Data;		// 11 - wrtie to RS
		endcase
		
		DataOut_R0 <= Registers[0];    
		DataOut_R1 <= Registers[1];
		// DataOut_R6 <= Registers[6]; // TODO: DELETE THIS
	end
endmodule