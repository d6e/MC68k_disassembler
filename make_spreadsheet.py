#!/usr/bin/python

import csv

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
		self.as_opcds = {
			'MOVE':'00',
			'MOVEQ':'0111',
			'MOVEM':'0100',
			'ADD':'1101',
			'ADDA':'1101',
			'ADDI':'0000',
			'SUB':'1001',
			'SUBA':'1001',
			'SUBQ':'0101',
			'MULS':'1100',
			'DIVU':'1000',
			'LEA':'0100',
			'CLR':'0100',
			'AND':'1100',
			'ANDI':'0000',
			'EOR':'1011',
			'EORI':'0000',
			'ASR':'1110',
			'LSL':'1110',
			'ROL':'1110',
			'ROR':'1110',
			'BCHG':'0000',
			'CMP':'1011',
			'CMPA':'1011',
			'CMPI':'0000',
			'BGT':'0110',
			'BLE':'0110',
			'BVS':'0110',
			'JSR':'0100',
			'RTS':'0100',
		}
		self.addrMode = {
			# Format:['mode','Xn']
			'D1':['000','001'],
			'A1':['001','001'],
			'(A1)':['010','001'],
			'#1':['111','100'],
			'(A1)+':['011','001'],
			'-(A1)':['100','001'],
			'$1000':['111','000'],
			'$10000000':['111','001'],
		}
	def smallSize(self, ascii_size):
		if ascii_size == ".W":
			return '0'
		if ascii_size == ".L":
			return '1'
	def normSize(self, ascii_size):
		if ascii_size == ".B":
			return '00'
		if ascii_size == ".W":
			return '01'
		if ascii_size == ".L":
			return '10'
	def moveSize(self, ascii_size):
		if ascii_size == ".B":
			return '01'
		if ascii_size == ".W":
			return '11'
		if ascii_size == ".L":
			return '10'

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
							row = list()

							row.append(indent)
							row.append(self.opcode)
							row.append(sz)
							row.append(' ')
							row.append(s)
							row.append(' ')
							row.append(d)
							self.assembled(row, self.opcode,sz,s,d)

							writeList.append(''.join(row))

	def assembled(self, rlist, opcode,size, s, d):
		rlist.append(' ')
		rlist.append(self.as_opcds[self.opcode])
		# rlist.append(' ')

		#take care of move exception
		if self.opcode == "MOVE":
			rlist.append(self.moveSize(size))
			rlist.append(''.join([self.addrMode[s][1],self.addrMode[s][0],self.addrMode[s][0],self.addrMode[s][1]]))

		elif self.opcode == "MOVEQ":
			rlist.append(''.join([self.addrMode[s][1],'0']))

		elif self.opcode == "MOVEM":
			rlist.append(''.join(['1','1','001']))
			rlist.append(self.smallSize(size))
			rlist.append(''.join([self.addrMode[s][0],self.addrMode[s][1]]))

		elif self.opcode == "ADD":
			rlist.append(''.join([self.addrMode[s][1],'1',self.normSize(size),self.addrMode[s][0],self.addrMode[s][1],]))

		elif self.opcode == "ADDA":
			rlist.append(''.join([self.addrMode[s][1],self.smallSize(size),'11',self.addrMode[s][0],self.addrMode[s][1],]))

		elif self.opcode == "ADDI":
			rlist.append(''.join(['0110',self.normSize(size),self.addrMode[s][0],self.addrMode[s][1],]))

		elif self.opcode == "SUB":
			rlist.append(''.join([self.addrMode[s][1],'1',self.normSize(size),self.addrMode[s][0],self.addrMode[s][1],]))

		elif self.opcode == "SUBA":
			rlist.append(''.join([self.addrMode[s][1],self.smallSize(size),'11',self.addrMode[s][0],self.addrMode[s][1],]))
		elif self.opcode == "SUBQ":
			rlist.append(''.join([]))
		elif self.opcode == "MULS":
			rlist.append(''.join([self.addrMode[s][1],'111',self.addrMode[s][0],self.addrMode[s][1],]))
		elif self.opcode == "DIVU":
			rlist.append(''.join([self.addrMode[s][1],'011',self.addrMode[s][0],self.addrMode[s][1],]))
		elif self.opcode == "LEA":
			rlist.append(''.join([self.addrMode[s][1],'111',self.addrMode[s][0],self.addrMode[s][1],]))
		elif self.opcode == "CLR":
			rlist.append(''.join(['0010',self.normSize(size),self.addrMode[s][0],self.addrMode[s][1],]))
		elif self.opcode == "AND":
			rlist.append(''.join([self.addrMode[s][1],'1',self.normSize(size),self.addrMode[s][0],self.addrMode[s][1],]))
		elif self.opcode == "ANDI":
			rlist.append(''.join(['0010',self.normSize(size),self.addrMode[s][0],self.addrMode[s][1],]))
		elif self.opcode == "EOR":
			rlist.append(''.join([self.addrMode[s][1],'2',self.normSize(size),self.addrMode[s][0],self.addrMode[s][1],]))
		elif self.opcode == "EORI":
			rlist.append(''.join(['1010',self.normSize(size),self.addrMode[s][0],self.addrMode[s][1],]))
		elif self.opcode == "ASR":
			rlist.append(''.join(['000011',self.addrMode[s][0],self.addrMode[s][1],]))
		elif self.opcode == "LSL":
			rlist.append(''.join(['001111',self.addrMode[s][0],self.addrMode[s][1],]))
		elif self.opcode == "ROL":
			rlist.append(''.join(['011111',self.addrMode[s][0],self.addrMode[s][1],]))
		elif self.opcode == "ROR":
			rlist.append(''.join(['011011',self.addrMode[s][0],self.addrMode[s][1],]))
		elif self.opcode == "BCHG":
			rlist.append(''.join(['100001',self.addrMode[s][0],self.addrMode[s][1],]))
		elif self.opcode == "CMP":
			rlist.append(''.join([self.addrMode[s][1],'0',self.normSize(size),self.addrMode[s][0],self.addrMode[s][1],]))
		elif self.opcode == "CMPA":
			rlist.append(''.join([self.addrMode[s][1],self.smallSize(size),'11',self.addrMode[s][0],self.addrMode[s][1],]))
		elif self.opcode == "CMPI":
			rlist.append(''.join(['1100',self.normSize(size),self.addrMode[s][0],self.addrMode[s][1],]))
		elif self.opcode == "BGT":
			rlist.append(''.join([]))
		elif self.opcode == "BVE":
			rlist.append(''.join([]))
		elif self.opcode == "BLE":
			rlist.append(''.join([]))
		elif self.opcode == "BVS":
			rlist.append(''.join([]))
		elif self.opcode == "JSR":
			rlist.append(''.join(['111010',self.addrMode[s][0],self.addrMode[s][1],]))
		elif self.opcode == "RTS":
			rlist.append(''.join(['111001110101']))

		rlist.append(' ')

		# extra data
		if s =='#1':
			rlist.append('0001')
		if s =='$1000' or s == '$10000000':
			s = s.replace("$","")
			rlist.append(s)
		rlist.append(' ')
		if d =='#1':
			rlist.append('0001')
		if d =='$1000' or d == '$10000000':
			d = d.replace("$","")
			rlist.append(d)


def initInstructionList():
	# This is a list of all the instructions, with their exceptions. 
	# 	I've added comments for exceptions for which I did not take into account
	return [
		###Instruct(opcode, src, dest, size, bidirectional=True, label='', AnForSizeB=True):
		Instruction('MOVE', src, dest, size, False, '', False), # Only for src: No 'An' if size is '.B' 
		Instruction('MOVEQ', ['#1'], ['D1'], ['.L'], False), 
		Instruction('MOVEM', ['D1'], ['(A1)','$10000000', '$1000'], ['.W','.L'],False), 
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
		Instruction('AND', ['D1', '(A1)', '(A1)+', '-(A1)','$10000000', '$1000'], ['D1'],size,False),
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

	# wString.append(getHeader())
	for instruction in instructions:
		instruction.append(wString)  # Append all the things!
	# wString.append(getFooter())

	# wString = '\n'.join(wString) # convert list to a newline deliminated string

	ofile = open('spreadsheet.csv','wb')
	writer = csv.writer(ofile, delimiter='\t', quotechar='"', quoting=csv.QUOTE_ALL)

	for row in wString:
		row = row.split()
		print row
		writer.writerow(row)

	ofile.close()

	# print wString