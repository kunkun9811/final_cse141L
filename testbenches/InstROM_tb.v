`timescale 1ns/ 1ps     // time unit / time precision


/* This testes the actual instruction fetch */
module instROM_tb;

reg         Reset;		        // init/reset, active high
reg         Start;		        // start next program
reg         Clk = 0;		    // clock -- posedge used inside design
reg         BRANCH;
reg         ALU_ZERO;
reg [10:0]  TAR;
wire [10:0] PC;

wire [10:0] InstAddress;
wire [8:0]  Instruction;     // initialized to HALT

reg [10:0]  PC_cmp = 0;
reg [8:0]   Instruction_expected = 0;

/* Get the correct program counter first */
InstFetch uut (
    .Reset      (Reset),
    .Start      (Start),
    .Clk        (Clk),
    .BRANCH     (BRANCH),
    .ALU_ZERO   (ALU_ZERO),
    .Target     (TAR),
    .ProgCtr    (PC)
);

assign InstAddress = PC;

/* Use the program counter above to grab the correct instruction */
InstROM uut2 (
    .InstAddress    (InstAddress),
    .InstOut        (Instruction)
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

end

/* Whenever something changes, check if Instruction_expected needs to be updated */
always @*
begin
    /* Update instruction_expected before checking */
    case (InstAddress)
            // 000110001 = CL R1
            0 : Instruction_expected = 'b000110001;  // load from address at reg 0 to reg 1  

            // 100000010 = SET #2  
            1 : Instruction_expected = 'b100000010;  // addi reg 1 and 1
            
            // 000110011 = CL R3
            2 : Instruction_expected = 'b000110011;  // sw reg 1 to address in reg 0
            
            // 010011001 = ADD R3, R1
            3 : Instruction_expected = 'b010011001;  // beqz reg1 to absolute address 1
            
            default : Instruction_expected = 'bxxxxxxxxx;
    endcase
end

/* Task to check if Instruction == Instruction_expected */
task test_instr_ROM;
    begin
        /* Check if equal */
        if(Instruction === Instruction_expected)
            $display("SUCCESS! Instuction_expected = %b\n\t   Instruction = %b\n\t   Time = %t\n", Instruction_expected, Instruction, $time);
        else
            $display("FAIL Instuction_expected = %b\n\t   Instruction = %b\n\t   Time = %t\n", Instruction_expected, Instruction, $time);

        /* increment PC_cmp */
        if(Clk) begin
            PC_cmp = PC_cmp + 1;
        end
    end
endtask

/* generate clock to sequence tests */
always begin
    #5 
    if($time == 100)
        $stop;
    else begin
        Clk = ~Clk;
        if(Clk)
            test_instr_ROM;
    end
end

endmodule