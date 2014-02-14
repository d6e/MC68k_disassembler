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
                
                MOVE.B      #4,D0   ;TODO: store D0's input data somewhere.
                TRAP        #15     ;also, consider other input methods.
; TODO: actually store and use start address and end address.
; (start address first, since this iteration of the project stops immediately after READ_FIRST.

                LEA         INPUT_MSG_2,A1  ; prompt user for ending address
                MOVE.B      #14,D0
                TRAP        #15

READ_FIRST      MOVEA.W     TEST_ORIGIN,A2      ; test the first word of the program
                CMP.W       #NOP_CODE,A2
                BEQ         NOP_FOUND

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

*address variables
TEST_ORIGIN     EQU         $00007000
NEXT_ADDR       SET         TEST_ORIGIN

*constant OPcodes
NOP_CODE        EQU         $4E71
DOLLAR          DC.B        '$',0

        ;TODO: replace Xs with address of instruction and make message more general.
    
                END     START        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
