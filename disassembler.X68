*-----------------------------------------------------------
* Title      : Disassembler
* Written by : Robert Brandenburg, Danielle Jenkins, Shahin Nahar
* Date       : 2/13/14
* Description: Disassemble hex machine code instructions into 68K instructions
*-----------------------------------------------------------

START           ORG     $1000        ; first instruction of program

* TODO: write disassembler
* TODO: more specific TODOs for our plan
* TODO: comments saying who is working where

* TODO: ascii logo

*------------------------BEGIN IO-----------------------------

PROMPT_INPUT    LEA         INPUT_MSG_1,A1  ; Prompt user for starting address
                MOVE.B      #14,D0
                TRAP        #15
                
                MOVE.B      #2,D0           ; Take user input for starting address.
                LEA         START_ADDR_IN,A1
                TRAP        #15        ; consider other input methods.
                ;MOVE.W      D1,TEST_ORIGIN        
                ;TODO: note that input value is stored in A1. We
                ;still need to convert it to hex before we can actually use it
                ;as an address.

; (start address first, since this iteration of the project stops immediately after READ_FIRST.

                LEA         INPUT_MSG_2,A1  ; prompt user for ending address
                MOVE.B      #14,D0
                TRAP        #15
                
                MOVE.B      #4,D0   ;Take user input for ending address.
                TRAP        #15     ;consider other input methods.
                MOVE.L      D1,END_ADDR

; To convert:
;     If the digit is 0 through 9 add $30 to convert to ASCII.
;     If the digit is A through F add $37 to convert to ASCII.



*------------------------END IO-----------------------------
*------------------------BEGIN OPCODE-----------------------------

READ_FIRST      ;MOVEA.W     TEST_ORIGIN,A2      ; test the first word of the program
                ;TODO: instead of just comparing to NOP, branch based on digits.
                MOVE.W      NEXT_ADDR,D4    ;this would be a good place to postincrement.
                CMP.W       #NOP_CODE,D4
                BEQ         NOP_FOUND
                
                STOP        #$2700        ; halt simulator
                
                ;TODO: process for reading hex instructions (after the first instruction):
                ;           1) Go to start of instruction reading loop, passing in the address of next instruction.
                ;           2) Store a word (16 bits) from that address.
                ;           3) Read the first 4 bits of the word using a filter.
                ;           4) branch to one of the following paths based on these bits:
                ;               a) 0000: Read the next 3 bits (i.e., the destination mode). Branch:
                ;                   i.   000: Read the bits at 0000 0000 XXXX XXXX (may want to make this filter) Branch:
                ;                       1) 00 111 100: ORI TO CCR (need to read data, I think)
                ;                       2) 01 111 100: ORI TO SR (need to read data, I think)
                ;                       3) (default) ORI. Now, read and store:
                ;                           SIZE:       0000 0000 XX00 0000 (need to make this filter)
                ;                           MODE:       0000 0000 00XX X000 (need to make this filter)
                ;                           REGISTER:   0000 0000 0000 0XXX (need to make this filter)
                ;                           only mandatory additional data is the immediate data.
                ;                   ii.  001: Read the bits at 0000 0000 XXXX XXXX (may want to make this filter) Branch:
                ;                       1) 00 111 100: ANDI TO CCR (need to read data, I think)
                ;                       2) 01 111 100: ANDI TO SR (need to read data, I think)
                ;                       3) (default) ANDI. Now, read and store:
                ;                           SIZE:       0000 0000 XX00 0000 (need to make this filter)
                ;                           MODE:       0000 0000 00XX X000 (need to make this filter)
                ;                           REGISTER:   0000 0000 0000 0XXX (need to make this filter)
                ;                           only mandatory additional data is the immediate data.
                ;                   iii. 101: Read the bits at 0000 0000 XXXX XXXX (may want to make this filter) Branch:
                ;                       1) 00 111 100: EORI TO CCR (need to read data, I think)
                ;                       2) 01 111 100: EORI TO SR (need to read data, I think)
                ;                       3) (default) EORI. Now, read and store:
                ;                           SIZE:       0000 0000 XX00 0000 (need to make this filter)
                ;                           MODE:       0000 0000 00XX X000 (FILT_SRC_MODE)
                ;                           REGISTER:   0000 0000 0000 0XXX (FILT_SRC_REG)
                ;                           only mandatory additional data is the immediate data.
                ;                   iv.  011: ADDI. Now read and store:
                ;                           SIZE:       0000 0000 XX00 0000 (need to make this filter)
                ;                           MODE:       0000 0000 00XX X000 (FILT_SRC_MODE)
                ;                           REGISTER:   0000 0000 0000 0XXX (FILT_SRC_REG)
                ;                           only mandatory additional data is the immediate data.
                ;                   v.   010: SUBI. Now read and store:
                ;                           SIZE:       0000 0000 XX00 0000 (need to make this filter)
                ;                           MODE:       0000 0000 00XX X000 (FILT_SRC_MODE)
                ;                           REGISTER:   0000 0000 0000 0XXX (FILT_SRC_REG)
                ;                           only mandatory additional data is the immediate data.
                ;                   vi.  110: CMPI. Now read and store:
                ;                           SIZE:       0000 0000 XX00 0000 (need to make this filter)
                ;                           MODE:       0000 0000 00XX X000 (FILT_SRC_MODE)
                ;                           REGISTER:   0000 0000 0000 0XXX (FILT_SRC_REG)
                ;                           only mandatory additional data is the immediate data.
                ;                   vii. 100: BTST, BCHG, BCLR, BSET (TODO: expand this section if we need these OPcodes)
                ;                   viii.(default): BTST, BCHG, BCLR, BSET (with data register)(TODO: expand this section if we need these OPcodes)
                ;               b) 0001: (MOVE.B). Now read and store:
                ;                           DESTINATION REGISTER: 0000 XXX0 0000 0000 (FILT_DEST_REG)
                ;                           DESTINATION MODE:     0000 000X XX00 0000 (FILT_DEST_MODE)
                ;                           SOURCE MODE:          0000 0000 00XX X000 (FILT_SCR_MODE)
                ;                           SOURCE REGISTER:      0000 0000 0000 0XXX (FILT_SRC_REG)
                ;                           The modes (and maybe register) will tell us whether we need to read additional data for this MOVE.
                ;               c) 0011: (MOVE.W). Now read and store:
                ;                           DESTINATION REGISTER: 0000 XXX0 0000 0000 (FILT_DEST_REG)
                ;                           DESTINATION MODE:     0000 000X XX00 0000 (FILT_DEST_MODE)
                ;                           SOURCE MODE:          0000 0000 00XX X000 (FILT_SCR_MODE)
                ;                           SOURCE REGISTER:      0000 0000 0000 0XXX (FILT_SRC_REG)
                ;                           The modes (and maybe register) will tell us whether we need to read additional data for this MOVE.
                ;               d) 0010: (MOVE.L). Now read and store:
                ;                           DESTINATION REGISTER: 0000 XXX0 0000 0000 (FILT_DEST_REG)
                ;                           DESTINATION MODE:     0000 000X XX00 0000 (FILT_DEST_MODE)
                ;                           SOURCE MODE:          0000 0000 00XX X000 (FILT_SCR_MODE)
                ;                           SOURCE REGISTER:      0000 0000 0000 0XXX (FILT_SRC_REG)
                ;                           The modes (and maybe register) will tell us whether we need to read additional data for this MOVE.
                ;               e) 0100: Read the bits at 0000 XXXX 0000 0000 (need filter) Branch:
                ;                   i.      0000: Read the bits at 0000 0000 XX00 0000 (need filter) Branch:
                ;                               1. 11: MOVE from SR. (TODO)
                ;                               2. (DEFAULT) NEGX. (the two bits are size) (TODO)
                ;                   ii.     0100: Read the bits at 0000 0000 XX00 0000 (need filter) Branch:
                ;                               1. 11 MOVE to CCR. (TODO)
                ;                               2. (DEFAULT) NEG. (the two bits are size) (TODO)
                ;                   iii.    0110: Read the bits at 0000 0000 XX00 0000 (need filter) Branch:
                ;                               1. 11 MOVE to SR. (TODO)
                ;                               2. (DEFAULT) NOT. (the two bits are size) (TODO)
                ;                   iv.     0010: CLR. (TODO)
                ;                    v.     1000: (EXT, NBCD, SWAP, PEA, MOVEM (dir 0)) (TODO)
                ;                   vi.     1010: Check the bits at 0000 XX00 0000 0000 (need filter) Branch:
                ;                           1. 11: check the bits at 0000 00XX XXXX XXXX (need filter) Branch:
                ;                               a. 11 1100: ILLEGAL (TODO)
                ;                               b. (default) TAS (TODO)
                ;                           2. (default) TST (TODO)
                ;                  vii.     1110: (TRAP, LINK, UNLK, MOVE USP, RESET, NOP, STOP, RTE, RTS, TRAPV, RTR, JSR, JMP) (TODO)
                ;                 viii.     (DEFAULT): (MOVEM, LEA, CHK,) (TODO)    
                ;               f) 0101: (ADDQ, SUBQ, Scc, DBcc): Read the bits at 0000 0000 XX00 0000 (need filter) Branch:
                ;                    i. 11: Read the bit at 0000 000X 0000 0000 (need filter) Branch:
                ;                           1. 0: ADDQ (TODO)
                ;                           2. 1: SUBQ (TODO)
                ;                   ii. (default) (bits are size) read the bits at 0000 00XX X000 (FILT_SRC_MODE). Branch:
                ;                           1. 001: DBCC (TODO)
                ;                           2. (default): Scc (TODO)
                ;               g) 0110: Read the bit at 0000 XXXX 0000 0000 (need filter) Branch:
                ;                    i. 0000: BRA (TODO)
                ;                   ii. 0001: BSR (TODO)
                ;                  iii. (default) Bcc (TODO)
                ;               h) 0111: MOVEQ (TODO)
                ;               i) 1000: (DIVU, DIVS, SBCD, OR) (TODO)
                ;               j) 1001: (SUB, SUBX, SUBA) (TODO)
                ;               k) 1011: (EOR, CMPM, CMP, CMPA) (TODO)
                ;               l) 1100: (MULU, MULS, ABCD, EXG, AND) (TODO)
                ;               m) 1101: (ADD, ADDX, ADDA) (TODO)
                ;               n) 1110: (ASd, LSd, ROXd, ROd, ASd, LSd, ROXd, ROd) (TODO)
                ;               o) (default) The code is invalid. Not yet sure what we do in this case.
                ;   
                ;   
                ;
                
                ;TODO: Use AND operations with filters to create values which can be
                ;      checked against constants to narrow down OPcodes.
                
                ;TODO: Since it will take a while to decode every possible OPcode, we
                ;      should first have a default "Error" subroutine which the program
                ;      branches to once all other possibilities have been ruled out.

*------------------------END OPCODE-----------------------------
*------------------------BEGIN EA-----------------------------



*------------------------END EA-----------------------------




NOP_FOUND       LEA         DOLLAR,A1     ; '$'
                MOVE.B      #14,D0
                TRAP        #15
                
                MOVE.L      #NEXT_ADDR,D1 ;display the address NOP was found at
                MOVE.B      #16,D2
                MOVE.B      #15,D0
                TRAP        #15

                LEA         SPACE,A1      ; ' '
                MOVE.B      #14,D0      
                TRAP        #15

                LEA         NOP_MSG,A1    ; 'NOP'
                MOVE.B      #14,D0
                TRAP        #15
                
                MOVE.B      #9,D0         ; terminate the program
                TRAP        #15

*--------------- PUT VARIABLES/CONSTANTS HERE -----------------

*output characters
CR              EQU         $0D
LF              EQU         $0A
SPACE           DC.B        ' ',0

*output messages
    ;TODO: consider also giving the user the range of valid start/end addresses
INPUT_MSG_1     DC.B        'Please enter a starting hex address to read from.',CR,LF,0
INPUT_MSG_2     DC.B        'Please enter an ending hex address to read from.',CR,LF,0

*output instruction names
NOP_MSG         DC.B        'NOP',0

*storage locations for input
START_ADDR_IN   DS.B        20

*address variables
TEST_ORIGIN     SET         $00007000
NEXT_ADDR       SET         TEST_ORIGIN
END_ADDR        SET         $00009000

*constant OPcodes
NOP_CODE        EQU         $4E71
DOLLAR          DC.B        '$',0

*filters for isolating parts of a hexa instruction.
*To filter an instruction, AND it with the desired filter.
FILT_NIB1       EQU        $F000   ;first nibble:              XXXX 0000 0000 0000
FILT_MOVE_SIZE  EQU        $3000   ;Size of a move operation:  00XX 0000 0000 0000
FILT_DEST_REG   EQU        $0E00   ;destination register:      0000 XXX0 0000 0000
FILT_DEST_MD    EQU        $01A0   ;destination mode:          0000 000X XX00 0000
FILT_SRC_MD     EQU        $0038   ;source mode:               0000 0000 00XX X000
FILT_SRC_REG    EQU        $0007   ;source register:           0000 0000 0000 0XXX

;TODO: consider other filters like OPmode and size.
;FILT_DEST_REG    EQU        $0E00   ;destination regilster:     0000 XXX0 0000 0000
;FILT_DEST_REG    EQU        $0E00   ;destination regilster:     0000 XXX0 0000 0000

        ;TODO: replace Xs with address of instruction and make message more general.
    
                END     START        ; last line of source






*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
