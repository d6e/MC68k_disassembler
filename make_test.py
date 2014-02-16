#!/usr/bin/python

################################################################################
### This script generates a list of every possible x68 instruction for our
### project. To get the list run: "python make_test.py > instruction_list.txt"
################################################################################

size = ['.B', '.W', '.L']
src = dest = ['D1', 'A1', '(A1)', '#1', '(A1)+', '-(A1)','$10000000', '$1000']


class Instruction:
	def __init__(self, o, s=src, d=dest, sz=size, bd=True, label=''):
		self.opcode = o
		self.sizes = sz
		self.sources = s
		self.destinations = d
		self.bidirectional = bd
		self.label = label


	def display(self):
		if self.label:  # if it only has a label, just print label		
			print ''.join([self.opcode, ' ', self.label])

		for size in self.sizes:
			for s in self.sources:
				for d in self.destinations:


					if self.bidirectional is True:
						print ''.join([self.opcode, size, ' ', s, ', ', d])
						print ''.join([self.opcode, size, ' ', d, ', ', s])
					else:
						if d:
							print ''.join([self.opcode, size, ' ', s, ', ', d])
						else:
							print ''.join([self.opcode, size, ' ', s])


if __name__ == '__main__':

	# This is a list of all the instructions, with their exceptions. 
	# 	I've added comments for exceptions I didn't account for
	instructions = [
		Instruction('MOVE', ), 
		Instruction('MOVEQ', ['#1'], ['D1'], ['.L'], False), 
		Instruction('MOVEM', ['D1/D2/D3', 'D1', 'A1', '(A1)', '#1', '(A1)+', '-(A1)','$10000000', '$1000'], ['D1/D2/D3', 'D1', 'A1', '(A1)', '#1', '(A1)+', '-(A1)','$10000000', '$1000'], ['.W','.L']), 
		Instruction('ADD', src, ['D1']), # Only for src: No 'An' if size is '.B' 
		Instruction('ADDA', src, ['A1'], ['.W','.L'], False),
		Instruction('ADDI', ['#1'], dest, size, False),
		Instruction('SUB', src, ['D1']), # Only for src: No 'An' if size is '.B'
		Instruction('SUBA', src, ['A1'], ['.W','.L'], False),
		Instruction('SUBQ', ['#1'], dest, size, False), # Only for src: No 'An' if size is '.B'
		Instruction('MULS', src, ['D1'], ['.W'], False),
		Instruction('DIVU', src, ['D1'], ['.W'], False),
		Instruction('LEA', src, ['A1'], ['.L'], False),
		Instruction('CLR', src, [''], size, False),  # only one operand
		Instruction('AND', src, ['D1']),
		Instruction('ANDI', ['#1'], dest, size, False),
		Instruction('EOR', ['D1'], dest, size, False),
		Instruction('EORI', ['#1'], dest, size, False),
		Instruction('ASR', ['D1'],['D2'], size, False),
		Instruction('ASR', ['#1'],['D2'], size, False),
		Instruction('ASR', src, [''], size, False),  # only one operand
		Instruction('LSL', ['D1'], ['D2'], size, False),
		Instruction('LSL', ['#1'], ['D2'], size, False),
		Instruction('LSL', src, [''], size, False),
		Instruction('ROL', ['D1'], ['D2'], size, False),
		Instruction('ROR', ['D1'], ['D2'], size, False),
		Instruction('BCHG', ['D1'], dest, ['.B','.L'], False), # 'Dn' can only be '.L' for dest, all others are '.B'
		Instruction('BCHG', ['#1'], dest, ['.B','.L'], False), # 'Dn' can only be '.L' for dest, all others are '.B'
		Instruction('CMP', src, ['D1'], size, False), # Only for src: No 'An' if size is '.B'
		Instruction('CMPA', src, ['A1'], ['.W','.L'], False),
		Instruction('CMPI', ['#1'], dest, size, False),
		Instruction('BCC', src, dest, size, False, 'GO_TO_SR'),  # Only label
		# Instruction('BGT', src, dest, size, False),
		# Instruction('BLE', src, dest, size, False),
		# Instruction('BVS', src, dest, size, False),
		Instruction('JSR', src, [''], [''], False),
		Instruction('RTS', [''], [''], [''], False),
	]

	for instruction in instructions:
		instruction.display()  # Print all the things!