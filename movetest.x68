*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here

    MOVE.B      #10,         D0
;    MOVE.B      #1000,       D1
;    MOVE.B      #10000000,   D2
    MOVE.W      #10,         D3
    MOVE.W      #1000,       D4
;    MOVE.W      #10000000,   D5
    MOVE.L      #10,         D6
    MOVE.L      #1000,       D7
    
    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
