# R0 = address
#       output[8:0] reg target = R0     <= this will connect to InstrFetch to update PC
# Because right now our branch instruction only does
#       out = 1
#       out = 0
class Assembler():
    def __init__(self, filename_in, filename_out):
        self.opcodes = self.build_op_table()
        self.reg_table = self.build_reg_table()
        self.filename_in = filename_in
        self.filename_out = filename_out
        self.branchLUT = {}

    # Opens and parses the file by removing all spaces and then removing all comments
    def open_file_and_parse(self):
        file_contents = []

        # Create temp file which will inject assembly code outlined in branch()
        temp = open("temp.txt", "w")    # TODO: MAYBE WRONG
        f = open(self.filename_in, 'r')
        for line in f.readlines():
            if "BEQZ" in line:
                label = line.split(" ")[1]

                for branch_line in self.branch(label):
                    temp.write(branch_line+"\n")
            else:
                temp.write(line)
        f.close()
        temp.close()

        # Read asm instructions from temp file
        with open("temp.txt", 'r') as temp:
            for line in temp.readlines():
                arr  = line.split("//") 
                stripped_line = arr[0].replace(" ", "")
                
                # For some reason there are '' in our list. Ignore it.
                if line != '':
                    file_contents.append(stripped_line.strip())
        return file_contents

    def translate_asm_to_binary(self, contents):
        asm_components = []
        binary_lines = []
        
        # split each asm line into its components
        for line in contents:
            newline = line.replace("$", "#")
            newline = newline.replace(",", "")
            splitted = newline.split("#")
            asm_components.append(splitted)


        # print(asm_components)
        label_offset = 0
        # Populate LUT, if instruction is length 1. Only labels will have length 1
        for i in range(len(asm_components)):
            instruction = asm_components[i]
            if len(instruction) == 1 and instruction[0] != "HALT":

                label = (instruction[0])[0:-1]
                self.branchLUT[label] = i - label_offset
                print(instruction[0], self.branchLUT[label])
                label_offset += 1

        # Check which instruction it is and convert accordingly
        for instruction in asm_components:
            line = ""
            for entry in self.opcodes:
                
                # match instruction name to entry in opcodes dict
                if entry["instr"] == instruction[0]:
                    
                    # skip the LABELS
                    if len(instruction) == 1 and instruction[0] != "HALT":
                        continue
                    if instruction[0] == "HALT":
                        line = "000000000"
                    elif entry['type'] == 'R':
                        line = entry['opcode'] + self.reg_table[instruction[1]]
                    elif entry['type'] == 'R2':
                        line = entry['opcode'] + self.reg_table[instruction[1]] + self.reg_table[instruction[2]]
                    elif entry['type'] == 'I':
                        # if instruction is SET LABEL, replace LABEL with corresponding label address value in LUT.
                        # if not, just use immediate => Because it is the ACTUAL SET instruction
                        if instruction[1].isalpha():
                            #print(instruction[1])
                            label_bin = self.base10_to_binary(self.branchLUT[instruction[1]])
                            line = entry['opcode'] + label_bin
                        else:
                            line = entry['opcode'] + self.base10_to_binary(instruction[1])

            if line != "":
                binary_lines.append(line)

        return binary_lines

        # CL R7       # 00 0110 111
        # ADD R7, R1  # 01 0111 001
        # SET addr    # 1 + LUT
        # CL R0       # 00 0110 000
        # ADD R0, R1  # 01 000  001
        # CL R1       # 00 0110 001
        # ADD R1, R7  # 01 0001 111
        # BEQZ R0     # 0000110 000
    def branch(self, label):
        inst_list = []
        # inst_list.append(000110111) # CL R7
        # inst_list.append(010111001) # ADD R7 R1
        # inst_list.append(1 + self.branchLUT()) # SET LABEL TODO 
        # inst_list.append(000110000) # CL R0
        # inst_list.append(000110111) # ADD R0, R1
        # inst_list.append(000110001) # CL R1
        # inst_list.append(000110111) # ADD R1, R7
        # inst_list.append(000011000) # BEQZ R0

        inst_list.append("CL $R7")
        inst_list.append("ADD $R7, $R1")
        inst_list.append("SET #" + label)
        inst_list.append("CL $R0")
        inst_list.append("ADD $R0, $R1")
        inst_list.append("CL $R1")
        inst_list.append("ADD $R1, $R7")
        inst_list.append("BEQZ $R0")
        return inst_list

    def write_output_file(self, filename, bin_lines):
        with open(filename, 'w') as f:
            for bin_line in bin_lines:
                f.write(bin_line + "\n")

            f.close()

    #Generate to binary
    def base10_to_binary(self, n):
        return '{0:08b}'.format(int(n))

    # Generate opcode
    def build_op_table(self):
        opcodes = [
            {'instr': 'HALT',   'type': 'R',    'opcode' : '000000'},
            {'instr': 'SLT',    'type': 'R',    'opcode' : '000001'},
            {'instr': 'LOAD',   'type': 'R',    'opcode' : '000010'},
            {'instr': 'BEQZ',   'type': 'R',    'opcode' : '000011'},
            {'instr': 'SL',     'type': 'R',    'opcode' : '000100'},
            {'instr': 'SR',     'type': 'R',    'opcode' : '000101'},
            {'instr': 'CL',     'type': 'R',    'opcode' : '000110'},
            {'instr': 'SUB',    'type': 'R',    'opcode' : '000111'},
            {'instr': 'OFC',     'type': 'R',    'opcode' : '001000'},      # TODO: MAKE SURE IT WORKS :)
            {'instr': 'AND',    'type': 'R',    'opcode' : '001001'},
            {'instr': 'SGTE',   'type': 'R',    'opcode' : '001010'},
            {'instr': 'STORE',  'type': 'R2',   'opcode' : '011'},
            {'instr': 'ADD',     'type': 'R2',   'opcode' : '010'},
            {'instr': 'SET',    'type': 'I',    'opcode' : '1'},
            {'instr': 'ADDC',    'type': 'R',    'opcode' : '001011'},
            {'instr': 'XOR',    'type': 'R',    'opcode' : '001100'}
        ]
        return opcodes
        
    #Generate registers
    def build_reg_table(self):
        registers = {
                "R0" : "000",
                "R1" : "001",
                "R2" : "010",
                "R3" : "011",
                "R4" : "100",
                "R5" : "101",
                "R6" : "110",
                "R7" : "111",
            }   
        return registers

    def assemble(self):
        file_contents = self.open_file_and_parse()
        bin_lines = self.translate_asm_to_binary(file_contents)
        self.write_output_file(self.filename_out, bin_lines)


if __name__ == "__main__":
    assembler = Assembler("../assembly_code.txt", "../machine_code.txt")
    assembler.assemble()