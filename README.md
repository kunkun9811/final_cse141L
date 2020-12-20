# cse141L

*** Few notes for using our processor ***
1. Remember to modify the path in InstROM.v so that the path is the absolute path of the "machine_code.txt" on your machine. We aren't sure why relative path isn't working after we organized the files into different folders.
2. Before you try to compile and run our processor on ModelSIM for each program, first do step 1. Then, go to one of the program folder(div, multi_inverse, or sqrt) and copy the code of the corresponding "OFFICIAL_'program_name'.txt" file. Say division, you would go to "div" folder and copy the code in "OFFICIAL_division.txt". With the copied code, find "assembly_code.txt" in the working directory(cse141L/assembly_code.txt) and paste the copied code into that file. Then go to assembler folder, type the command "python assembler.py". This will assemble the code and put the machine code in "machine_code.txt".

*** Which programs work? ***
Division - Yes
Multiplicative Inverse - Yes
Square Root - Partially

*** Challenges we encountered ***
We finished the program in the following order: Division => Multiplicative Inverse => Square Root

1. Division:
    For division, the biggest challenge we encountered was not the algorithm in assembly code itself, it was trying to figure out the ideal ISA for our approach in implementing division. At the time, we weren't sure if we wanted to do accumulator, reg-reg, or stack type of processor. Eventually we decided on the mix of accumulator and reg-reg. This is mostly due to the little bits we have in our instructions to specify enough registers in one instruction for a FULL reg-reg type processor. After deciding the type, we solved the biggest challenge of how to write assembly code for division and the other two programs. We made 3 kinds of instructions, R-type, R2-type, and Immediate. R-type will always take the form of something like "AND $RS", where it will perform "R1 = R1 & RS", with the exception of "ADDC $RS" which it will do "$RS = $RS + $R1 + Carry". R2-type will always take the form of something like "ADD $RS, $RT" where it will either perform "RS = RS + RT" or "STORE $RS, $RT" where it will perform "MEM[RT] = RS". Immediate type only has the "SET" instruction where it performs "$R1 = 8-bit immediate". With this ISA, we were able to easily code the division program.

2. Multiplicative Inverse:
    For multiplicative inverse, the hardest challenge would be to perform 16-bit subtraction with our registers only able to hold 8-bit data. Since I remember Hadi mentioned that addition in verilog would produce one extra bit result, we utilize the concatenation method to grab the overflow bit for future use. This solved the problem for 16-bit instruction. This actually took a while because we weren't sure how to save the overflow bit to the next instruction.

3. Square Root:
    For Square Root, our biggest challenge was that the worst case scenario, the divisor would be 10 bits long and the dividend would be 16 bits long. Therefore, both divisor and dividend will have to be 2 registers/16 bits. We thought it would be the same as Multiplicative Inverse, however after implementing it once, it was vastly different. Our square root works for most of the NON-PERFECT-SQUARE numbers. However, whenever it comes to perfect squares, it definitely does not work. We were working on Multiplicative Inverse and Square Root in parallel, we implemented a new logic for 16-bit arithmetic when working on Multiplicative Inverse while Square Root was still using the old, partially correct 16-bit arithmetic. This is why Square Root did not work as expected but Multiplicative Inverse did.

*** Link ***