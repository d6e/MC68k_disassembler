*-----------------------------------------------------------
* Title      : Testing
* Written by : Robert Brandenburg, Danielle Jenkins, Shahin Nahar
* Date       : 2/13/14
* Description: Disassembler test file
*-----------------------------------------------------------
    
START       ORG    $7000                ; first instruction of program
            NOP
            MOVE.B #10,D0

* TODO: use all required opcodes in all possible combinations here

            STOP   #$7700          ; halt simulator

* Put variables and constants here

            END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
