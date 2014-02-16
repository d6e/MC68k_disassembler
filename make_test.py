#!/usr/bin/python


parts = {  # default parts
	"sizes":[".B", ".W", ".L"],
	"targets":["D1", "A1", "(A1)", "#1", "(A1)+", "-(A1)","$10000000", "$1000"],
	"destinations":["D1", "A1", "(A1)", "#1", "(A1)+", "-(A1)","$10000000", "$1000"],
}

class Instruction:
	def __init__(self, op, p=parts):
		self.opcode = op
		self.sizes = p["sizes"]
		self.targets = p["targets"]
		self.destinations = p["destinations"]

	def display(self):
		for size in self.sizes:
			for t in self.targets:
				for d in self.destinations:
					print ''.join([self.opcode, size, " ", t, ", ", d])



if __name__ == "__main__":


	instructions = [
		Instruction("MOVE"), 
		Instruction("MOVEQ"), 
		Instruction("MOVEM"), 
		Instruction("ADD"),
		Instruction("ADDA"),
		Instruction("ADDI"),
		Instruction("SUB"),
		Instruction("SUBA"),
		Instruction("SUBQ"),
		Instruction("MULS"),
		Instruction("DIVU"),
		Instruction("LEA"),
		Instruction("CLR"),
		Instruction("AND"),
		Instruction("ANDI"),
		Instruction("EOR"),
		Instruction("EORI"),
		Instruction("ASR"),
		Instruction("LSL"),
		Instruction("ROL"),
		Instruction("ROR"),
		Instruction("BCHG"),
		Instruction("CMP"),
		Instruction("CMPA"),
		Instruction("CMPI"),
		Instruction("BCC"),
		Instruction("BGT"),
		Instruction("BLE"),
		Instruction("BVS"),
		Instruction("JSR"),
		Instruction("RTS"),
	]

	for instruction in instructions:
		instruction.display()