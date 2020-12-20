// CSE141L  Fall 2020
// test bench to be used to verify student projects
// pulses start while loading program 2 operand into DUT
//  waits for done pulse from DUT
//  reads and verifies result from DUT against its own computation
// Based on SystemVerilog source code provided by John Eldon
 
module test_bench_2();

  // to be deleted
  integer i;
  // end

  reg           clk   = 1'b0   ;      // advances simulation step-by-step
  reg           init  = 1'b1   ;      // init (reset) command to DUT
  reg           start = 1'b1   ;      // req (start program) command to DUT
  wire          done           ;      // done flag returned by DUT
  
// ***** instantiate your top level design here *****
  CPU dut(
    .Clk      (clk  ),   // input: use your own port names, if different
    .Reset    (init ),   // input: some prefer to call this ".reset"
    .Start    (start),   // input: launch program
    .Ack      (done )    // output: "program run complete"
  );


// program 1 variables
reg[63:0] dividend;      // fixed for pgm 1 at 64'h8000_0000_0000_0000;
reg[15:0] divisor1;	   // divisor 1 (sole operand for 1/x) to DUT
reg[63:0] quotient1;	   // internal wide-precision result
reg[15:0] result1,	   // desired final result, rounded to 16 bits
            result1_DUT;   // actual result from DUT
real quotientR;			   // quotient in $real format


// program 2 variables
reg[15:0] div_in2;	   // dividend 2 to DUT
reg[ 7:0] divisor2;	   // divisor 2 to DUT
reg[23:0] result2,	   // desired final result, rounded to 24 bits
            result2_DUT;   // actual result from DUT
			
// program 3 variables
reg[15:0] dat_in3;	   // operand to DUT
reg[ 7:0] result3;	   // expected SQRT(operand) result from DUT
reg[47:0] square3;	   // internal expansion of operand
reg[ 7:0] result3_DUT;   // actual SQRT(operand) result from DUT
real argument, result, 	   // reals used in test bench square root algorithm
     error, result_new;
	 
// clock -- controls all timing, data flow in hardware and test bench
always begin
      clk = 0;
  #5; clk = 1;
  #5;
end

initial begin

  // preload operands and launch program 2
  #10; start = 1;	
  init = 0;
  

  // $display("Ella was HERE!\n");

  // The test below is calculating 3/255
  // insert dividend and divisor
  div_in2 = 385;	   	// *** try various values here ***
  divisor2 = 6;		    // *** try various values here ***
  // *** change names of memory or its guts as needed ***
  dut.DM1.Core[0] = div_in2[15:8];
  dut.DM1.Core[1] = div_in2[ 7:0];
  dut.DM1.Core[2] = divisor2;

  if(divisor2) div2; 							             // divisor2 is "true" only if nonzero
  else result2 = '1; // same as program 1: limit to max.

  // $display("Ella is about to START!\n");

  /* Debug - Print out instruction memory */
  // $display("///// INSTRUCTIONS MEMORY /////\n\n");
  // for(i = 0; i < 2048; i = i + 1)begin
  //   $display("Instr[%d] = %b\n", i, dut.IR1.inst_rom[i]);
  // end
  // $display("///// END /////\n\n");

  #20; start = 0;
  #20; wait(done);

    /* Debug = Print out data memory */
  // $display("///// DATA MEMORY /////\n\n");
  // for(i = 0; i < 256; i = i + 1)begin
  //   $display("data[%d] = %b\n", i, dut.DM1.Core[i]);
  // end
  // $display("///// END /////\n\n");


  /* Debug - Print out registers */
  $display("///// REGISTERS  /////\n\n");
  for(i = 0; i < 8; i = i + 1)begin
    $display("reg[%d] = %8b\n", i, dut.RF1.Registers[i]);
  end
  $display("///// END /////\n\n");


  // *** change names of memory or its guts as needed ***
  result2_DUT[23:16] = dut.DM1.Core[4];
  result2_DUT[15: 8] = dut.DM1.Core[5];
  result2_DUT[ 7: 0] = dut.DM1.Core[6];
  $display ("dividend = %h, divisor2 = %h, quotient = %h, result2 = %h, equiv to %10.5f",
              dividend,     divisor2,       quotient1,    result2,              quotientR); 
  if(result2==result2_DUT) $display("success -- match2");
  else $display("OOPS2! expected %b, got %b",result2,result2_DUT); 
  #10;
  $stop;
end

task automatic div2;
begin
  dividend = div_in2<<48;
  quotient1 = dividend/divisor2;
  // result2 = quotient1[63:40]+quotient1[39]; // half-LSB upward rounding (Uncomment this line to use rounding)
  result2 = quotient1[63:40];                 // No rounding
  quotientR = $itor(div_in2)/$itor(divisor2);
end
endtask

endmodule