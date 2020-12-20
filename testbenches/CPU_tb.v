`timescale 1ns/ 1ps

module CPU_tb;

reg Reset;		    // init/reset, active high
reg Start;		    // start next program
reg Clk;			// clock -- posedge used inside design
wire Halt;          



// later
reg[63:0] dividend;
reg[15:0] divisor;
reg[63:0] quotient;
reg[15:0] result;

reg [10:0] PC = 0;
integer i;

CPU uut (
    .Reset      (Reset),
    .Start      (Start),
    .Clk        (Clk),
    .Ack        (Halt)
);

/* tests */
initial begin
    Clk = 1;
    Reset = 1;
    #400;

    Reset = 0;
    Start = 0;
    wait(Halt);

    test_CPU;

end

task test_CPU;
    begin
        // $display("///// INSTRUCTIONS MEMORY /////\n\n");
        // for(i = 0; i < 2048; i = i + 1)begin
        //     $display("Instr[%d] = %b\n", i, uut.IR1.inst_rom[i]);
        // end
        // $display("///// END /////\n\n");


        /***** TEST ARITHMETIC *****/
        $display("*******FINAL REGISTER FILE*******\n\n");

        for(i = 0; i < 8; i = i + 1) begin
            $display("R%d = %d\n", i, uut.RF1.Registers[i]);
        end

        $display("*******END OF REGISTER FILE*******\n\n\n");

        // if(uut.RF1.Registers[2] == 35)begin
        //     $display("YOU GOOD BRO!\n");
        // end
        // else begin
        //     $display("YOU ARE SO FKING DUMB!\n");
        // end

        // /***** TEST MEMORY *****/
        // $display("///////FINAL DATA MEMORY///////\n");

        // for(i = 0; i<30; i = i+1) begin
        //     $display("DataMemory[%d] = %d\n", i, uut.DM1.Core[i]);
        // end

        // $display("///////END OF DATA MEMORY///////\n");
        
        // if(uut.DM1.Core[11] == 24) begin
        //     $display("SUCCESS! 24 is correctly stored into DataMemory[11]!\n");
        // end
        // else begin
        //     $display("FAIL! 24 is not stored in the right address\n");
        // end

        /***** TEST BRANCH *****/
    //     $display("/////// Test Branch ///////\n");

    //    if(uut.RF1.Registers[2] == 100) begin
    //     $display("Added up to 100 yay!\n");
    //    end
    //    else begin
    //        $display("no :c\n");
    //    end

    //     $display("///////END OF TEST BRANCH ///////\n");


        $stop;
    end
endtask

// generate clock to sequence tests
always begin
    #100 
    Clk = ~Clk;
    PC = PC + 1;
    // $display("*******REGISTER FILE @ PC = [%d]*******\n\n", PC);

    //     for(i = 0; i < 8; i = i + 1) begin
    //         $display("R%d = %d\n", i, uut.RF1.Registers[i]);
    //     end

    // $display("///////FINAL DATA MEMORY///////\n");

    //     for(i = 0; i<30; i = i+1) begin
    //         $display("DataMemory[%d] = %d\n", i, uut.DM1.Core[i]);
    //     end

end

endmodule