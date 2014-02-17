#!/usr/bin/python

# Default values:
size = ['.B', '.W', '.L']
src = ['D1', 'A1', '(A1)', '#1', '(A1)+', '-(A1)','$10000000', '$1000']
dest = ['D1','$10000000', '$1000']


class Instruction:
	def __init__(self, opcode, src=src, dest=dest, size=size, bidirectional=True, label='', AnForSizeB=True):
		self.opcode = opcode
		self.sizes = size
		self.sources = src
		self.destinations = dest
		self.bidirectional = bidirectional
		self.label = label
		self.AnForSizeB = AnForSizeB

	def append(self, writeList):
		indent = "            "
		if self.label:  # if it only has a label, just print label		
			writeList.append(''.join([indent, self.opcode, ' ', self.label]))
		else:
			for sz in self.sizes:
				for s in self.sources:
					for d in self.destinations:
						if self.AnForSizeB == False and s == "A1" and sz == ".B": # Only for src: No 'An' if size is '.B' 
							pass
						else:
							if self.bidirectional is True:
								writeList.append(''.join([indent, self.opcode, sz, ' ', s, ', ', d]))
								writeList.append(''.join([indent, self.opcode, sz, ' ', d, ', ', s]))
							else:
								if d:  # Don't add commas if there's no destination
									writeList.append(''.join([indent, self.opcode, sz, ' ', s, ', ', d]))
								else:
									writeList.append(''.join([indent, self.opcode, sz, ' ', s]))


def initInstructionList():
	# This is a list of all the instructions, with their exceptions. 
	# 	I've added comments for exceptions for which I did not take into account
	return [
		###Instruct(opcode, src, dest, size, bidirectional=True, label='', AnForSizeB=True):
		Instruction('MOVE', src, dest, size, False, '', False), # Only for src: No 'An' if size is '.B' 
		Instruction('MOVEQ', ['#1'], ['D1'], ['.L'], False), 
		Instruction('MOVEM', ['A1-A6','D1-D7', 'D1'], ['(A1)','$10000000', '$1000'], ['.W','.L']), 
		Instruction('ADD', src, ['D1'], size, False, '', False), # Only for src: No 'An' if size is '.B' 
		Instruction('ADDA', src, ['A1'], ['.W','.L'], False),
		Instruction('ADDI', ['#1'], dest, size, False),
		Instruction('SUB', src, ['D1'],size,False,'',False), # Only for src: No 'An' if size is '.B'
		Instruction('SUBA', src, ['A1'], ['.W','.L'], False),
		Instruction('SUBQ', ['#1'], dest, size, False, '', False), # Only for src: No 'An' if size is '.B'
		Instruction('MULS', ['D1', '(A1)', '#1', '(A1)+', '-(A1)','$10000000', '$1000'], ['D1'], ['.W'], False),
		Instruction('DIVU', ['D1', '(A1)', '#1', '(A1)+', '-(A1)','$10000000', '$1000'], ['D1'], ['.W'], False),
		Instruction('LEA', ['(A1)','$10000000', '$1000'], ['A1'], ['.L'], False),
		Instruction('CLR', ['D1', '(A1)', '(A1)+', '-(A1)','$10000000', '$1000'], [''], size, False),  # only one operand
		Instruction('AND', ['D1', '(A1)', '(A1)+', '-(A1)','$10000000', '$1000'], ['D1']),
		Instruction('ANDI', ['#1'], dest, size, False),
		Instruction('EOR', ['D1'], dest, size, False),
		Instruction('EORI', ['#1'], dest, size, False),
		Instruction('ASR', ['D1'],['D2'], size, False),
		Instruction('ASR', ['#1'],['D2'], size, False),
		Instruction('LSL', ['D1'], ['D2'], size, False),
		Instruction('LSL', ['#1'], ['D2'], size, False),
		Instruction('ROL', ['D1'], ['D2'], size, False),
		Instruction('ROR', ['D1'], ['D2'], size, False),
		Instruction('BCHG', ['D1'], ['(A1)', '(A1)+', '-(A1)','$10000000', '$1000'], ['.B'], False), # 'Dn' can only be '.L' for dest, all others are '.B'
		Instruction('BCHG', ['D1'], ['D1'], ['.L'], False), # 'Dn' can only be '.L' for dest, all others are '.B'
		Instruction('BCHG', ['#1'], ['(A1)', '(A1)+', '-(A1)','$10000000', '$1000'], ['.B'], False), # 'Dn' can only be '.L' for dest, all others are '.B'
		Instruction('CMP', src, ['D1'], size, False, '', False), # Only for src: No 'An' if size is '.B'
		Instruction('CMPA', src, ['A1'], ['.W','.L'], False),
		Instruction('CMPI', ['#1'], dest, size, False),
		# Instruction('BCC', src, dest, size, False, 'GO_TO_SR'),  # Only label
		# Instruction('BGT', src, dest, size, False),
		# Instruction('BLE', src, dest, size, False),
		# Instruction('BVS', src, dest, size, False),
		Instruction('JSR', ['(A1)', '$10000000', '$1000'], [''], [''], False),
		Instruction('RTS', [''], [''], [''], False),
	]


def getHeader():
	return '\n'.join([
		"*-----------------------------------------------------------",
		"* Title      : Testing",
		"* Written by : Robert Brandenburg, Danielle Jenkins, Shahin Nahar",
		"* Date       : 2/13/14",
		"* Description: Disassembler test file",
		"*-----------------------------------------------------------",
		"",
		"START       ORG    $7000                ; first instruction of program",
		"            NOP",
		"            MOVE.B #10,D0",
		"",
		"* TODO: use all required opcodes in all possible combinations here",
	])

def getFooter():
	return '\n'.join([
		"",
		"            STOP   #$7700          ; halt simulator",
		"",
		"* Put variables and constants here",
		"",
		"            END    START        ; last line of source",
		"",
		"",
		"*~Font name~Courier New~",
		"*~Font size~10~",
		"*~Tab type~1~",
		"*~Tab size~4~",
	])

if __name__ == '__main__':

	instructions = initInstructionList()

	wString = list()

	wString.append(getHeader())
	for instruction in instructions:
		instruction.append(wString)  # Append all the things!
	wString.append(getFooter())

	wString = '\n'.join(wString) # convert list to a newline deliminated string

	f = open('testing.X68','w')
	f.write(wString)
	f.close()

	print wString