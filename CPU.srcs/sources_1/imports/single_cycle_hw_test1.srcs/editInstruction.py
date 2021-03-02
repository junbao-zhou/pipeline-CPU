import sys

file = open(sys.path[0] + "\\InstructionMemory2.v", 'r+')

filetext = file.read()
strarray = filetext.split("9'd0: Instruction <= 32'h")

targetText = strarray[0]
for i in range(strarray.__len__() - 1):
    targetText += f"9'd{i}: Instruction <= 32'h" + strarray[i + 1]

file.seek(0)
file.write(targetText)
