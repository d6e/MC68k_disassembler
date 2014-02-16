#!/usr/bin/python


sz = [".B", ".W", ".L"]
src = ["D1", "A1", "(A1)", "#1", "(A1)+", "-(A1)","$10000000", "$1000"]
dest = ["D1", "A1", "(A1)", "#1", "(A1)+", "-(A1)","$10000000", "$1000"]

class Instruction:
	def __init__(self, o, s=src, d=dest, sz=sz, bd=True):
		self.opcode = o
		self.sizes = sz
		self.sources = s
		self.destinations = d
		self.bidirectional = bd

	def display(self):
		for size in self.sizes:
			for s in self.sources:
				for d in self.destinations:
					if self.bidirectional is True:
						print ''.join([self.opcode, size, " ", s, ", ", d])
						print ''.join([self.opcode, size, " ", d, ", ", s])
					else:
						print ''.join([self.opcode, size, " ", s, ", ", d])





if __name__ == "__main__":

	# This is a list of all the instructions, list all these
	instructions = [
		Instruction("MOVE", ), 
		Instruction("MOVEQ", ["#1"], ["D1"], [".L"], False), 
		Instruction("MOVEM", ["D1/D2/D3", "D1", "A1", "(A1)", "#1", "(A1)+", "-(A1)","$10000000", "$1000"], ["D1/D2/D3", "D1", "A1", "(A1)", "#1", "(A1)+", "-(A1)","$10000000", "$1000"], [".W",".L"]), 
		Instruction("ADD", src, ["D1"]),
		# Instruction("ADDA", ),
		# Instruction("ADDI", ),
		# Instruction("SUB", ),
		# Instruction("SUBA", ),
		# Instruction("SUBQ", ),
		# Instruction("MULS", ),
		# Instruction("DIVU", ),
		# Instruction("LEA", ),
		# Instruction("CLR", ),
		# Instruction("AND", ),
		# Instruction("ANDI", ),
		# Instruction("EOR", ),
		# Instruction("EORI", ),
		# Instruction("ASR", ),
		# Instruction("LSL", ),
		# Instruction("ROL", ),
		# Instruction("ROR", ),
		# Instruction("BCHG", ),
		# Instruction("CMP", ),
		# Instruction("CMPA", ),
		# Instruction("CMPI", ),
		# Instruction("BCC", ),
		# Instruction("BGT", ),
		# Instruction("BLE", ),
		# Instruction("BVS", ),
		# Instruction("JSR", ),
		# Instruction("RTS", ),
	]

	for instruction in instructions:
		instruction.display()