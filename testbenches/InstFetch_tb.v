`timescale 1ns/ 1ps

module InstFetch_tb;

reg Reset;		// init/reset, active high
reg Start;		// start next program
reg Clk;			// clock -- posedge used inside design
reg BRANCH;
reg ALU_ZERO;
reg [ 10:0] TAR;
wire [ 10:0] PC;

reg [10:0] PC_cmp = 0;

InstFetch uut (
    .Reset      (Reset),
    .Start      (Start),
    .Clk        (Clk),
    .BRANCH     (BRANCH),
    .ALU_ZERO   (ALU_ZERO),
    .Target     (TAR),
    .ProgCtr    (PC)
);

/* tests */
initial begin
    Clk = 1;
    Reset = 1;
    #10;

    Reset = 0;
    Start = 0;
    BRANCH = 0;
    ALU_ZERO = 0;
    TAR = 0; 
 

    // $display("time = %t\nPC = %d\n", $time, PC);
end

task test_instr_fetch;
    begin
        if(PC == PC_cmp)
            $display("SUCCESS!");
        else
            $display("FAIL PC_cmp = %d\n\t PC = %d", PC_cmp, PC);

        if(Clk) begin
            PC_cmp = PC_cmp + 1;
        end
    end
endtask
// generate clock to sequence tests
always begin
    #5 
    if($time == 10000)
        $stop;
    else begin
        Clk = ~Clk;
        test_instr_fetch;
    end
end

endmodule