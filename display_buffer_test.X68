*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here

        CLR  DISPLAY_BUFFER
        LEA DISPLAY_BUFFER, A3
        MOVEA.W  MOVE_MESG, A3     
        MOVEA.W    (A3)+, A1        ;DISPLAY_BUFFER
        
        ; MOVEA.L DISPLAY_BUFFER, A1
        MOVE.B #14,D0
        TRAP #15




SIMHALT             ; halt simulator

* Put variables and constants here


STOP
    
DISPLAY_BUFFER      DS.W        10           ; We need 10 words or 180 bits since each ascii character == 2 hex characters
MOVE_MESG           DC          'MOVE.B',0


    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
