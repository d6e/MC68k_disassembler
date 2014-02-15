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

PROMPT_INPUT    LEA         INPUT_MSG_1,A1  ; prompt user for starting address
                MOVE.B      #14,D0
                TRAP        #15
                
                MOVE.B      #2,D0   ;Take user input for starting address.
                LEA         START_ADDR_IN,A1
                TRAP        #15     ;consider other input methods.
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

READ_FIRST      ;MOVEA.W     TEST_ORIGIN,A2      ; test the first word of the program
                ;TODO: instead of just comparing to NOP, branch based on digits.
                MOVE.W      NEXT_ADDR,D4    ;this would be a good place to postincrement.
                CMP.W       #NOP_CODE,D4
                BEQ         NOP_FOUND
                
                AND.W       #%1111000000000000  

                STOP        #$2700        ; halt simulator

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

* Put variables and constants here

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
FILT_NIB1        EQU        $F000   ;first nibble:              XXXX 0000 0000 0000
FILT_MOVE_SIZE   EQU        $3000   ;Size of a move operation:  00XX 0000 0000 0000
FILT_DEST_MD     EQU        $0E00   ;destination register:      0000 XXX0 0000 0000
FILT_DEST_MD     EQU        $01A0   ;destination mode:          0000 000X XX00 0000
FILT_SOURCE_MD   EQU        $0038   ;source mode:               0000 0000 00XX X000
FILT_DEST_REG    EQU        $0007   ;source register:           0000 0000 0000 0XXX

;TODO: consider other filters like OPmode and size.
;FILT_DEST_REG    EQU        $0E00   ;destination regilster:     0000 XXX0 0000 0000
;FILT_DEST_REG    EQU        $0E00   ;destination regilster:     0000 XXX0 0000 0000

        ;TODO: replace Xs with address of instruction and make message more general.
    
                END     START        ; last line of source




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
