*-----------------------------------------------------------
* Title      : Disassembler
* Written by : Robert Brandenburg, Danielle Jenkins, Shahin Nahar
* Date       : 2/13/14
* Description: Disassemble hex machine code instructions into 68K instructions
*-----------------------------------------------------------

START           ORG     $1000        ; first instruction of program

* TODO: write disassembler

                MOVE.W  $7000,D0    ; test the first instruction
                CMP.W   #NOP_CODE,D0
                BEQ     NOP_FOUND

                STOP    #$2700        ; halt simulator

NOP_FOUND       LEA     NOP_MSG,A1
                MOVE.B  #14,D0
                TRAP    #15
                
                MOVE.B  #9,D0
                TRAP    #15

* Put variables and constants here

TEST_ORIGIN     EQU     $7000
NOP_CODE        EQU     $4E71
NOP_MSG         DC.B    '$XXXXXXXX NOP',0   
        ;TODO: replace Xs with address of instruction and make message more general.
    
                END     START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
