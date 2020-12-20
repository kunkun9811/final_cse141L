// Module Name:    DataMem 
// Project Name:   CSE141L
//
// Revision Fall 2020
// Based on SystemVerilog source code provided by John Eldon
// Comment:
// This module is your Data memory
// Similar to Instruction Memory, you may have a text file as your memory.
// You may hard code values into your memory. 
// Ex. If you just want the value 5 in memory 244 and 254 at position 16 when the program start,
// you may do so below.

/*** NOTES ***/

/* Signals */
// Clk: clock
// Reset: reset all memory to 0
// Mem_Read: 
  // 1:load  address  
  // 0:does nothing
// Mem_Write 
  // 1:write address  
  // 0:does nothing

/* Input */
// DataAddress: Address to access the memory
// WriteData: data to write to the memory

/* Output */
// ReadData: Data read from the memory

/*** END of NOTES ***/

module DataMem(Clk, Reset, MEM_READ, MEM_WRITE, DataAddress, WriteData, ReadData);
  input              Clk,
                     Reset,
                     MEM_READ,
                     MEM_WRITE;
  input [7:0]        DataAddress,   
                     WriteData;		   
  output reg[7:0]    ReadData;
  reg [7:0] Core[256-1:0];			    //the memory itself
  integer i;


  // Reads are combinational
  always@*                    
  begin
    if (MEM_READ) ReadData <= Core[DataAddress];    // Read Memory if Mem_Read = 1
    else  ReadData <= 'bz;                         // Else, tristate
  end
  
  // Writes are sequential
  always @ (posedge Clk)		 
	begin
    if(Reset) begin
      // you may initialize your memory w/ constants, if you wish
      for(i=0;i<256;i = i + 1)
        Core[i] <= 0;   
	  end
    else if(MEM_WRITE) begin
      Core[DataAddress] <= WriteData;
    end
	end
endmodule