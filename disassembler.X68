*-----------------------------------------------------------
* Title      : Disassembler
* Written by : Robert Brandenburg, Danielle Jenkins, Shahin Nahar
* Date       : 2/13/14
* Description: Disassemble hex machine code instructions into 68K instructions
*-----------------------------------------------------------

START           ORG     $1000        ; first instruction of program

* TODO: write disassembler

READ_FIRST      MOVEA.W     TEST_ORIGIN,A2      ; test the first word of the program
                CMP.W       #NOP_CODE,A2
                BEQ         NOP_FOUND

                STOP        #$2700        ; halt simulator

NOP_FOUND       LEA         DOLLAR,A1     ; '$'
                MOVE.B      #14,D0
                TRAP        #15
                
                *MOVEA.W     $7000,A1
                MOVE.L      #NEXT_ADDR,D1
                MOVE.B      #16,D2
                MOVE.B      #15,D0
                TRAP        #15
                ;TODO: put memory address NOP was found at here 

                LEA         SPACE,A1      ; ' '
                MOVE.B      #14,D0      
                TRAP        #15

                LEA         NOP_MSG,A1    ; 'NOP'
                MOVE.B      #14,D0
                TRAP        #15
                
                MOVE.B      #9,D0         ; terminate the program
                TRAP        #15

* Put variables and constants here

TEST_ORIGIN     EQU         $00007000
NEXT_ADDR       SET         TEST_ORIGIN
NOP_CODE        EQU         $4E71
DOLLAR          DC.B        '$',0
SPACE           DC.B        ' ',0
NOP_MSG         DC.B        'NOP',0   
        ;TODO: replace Xs with address of instruction and make message more general.
    
                END     START        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
