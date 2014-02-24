*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program
 
*---------------------------- Add string to display buffer ---------------------------------------  
                        MOVEA.L    #DISPLAY_BUFFER, A0  ; Set address register A0 to refer to DISPLAY_BUFFER space
                        MOVEA.L    #MOVE_MESG,A2        ; Point the A2 register at the MOVE_MESG
                      
DISP_BUFF_ADD           MOVE.B     (A2)+,(A0)+          ; move a char from MOVE_MESG and incrememnt addr registers so they point to the next char
                        CMPI.B     #0,(A2)              ; if reached the end of the string
                        BEQ        PRINT_DISP           ; jump to print
                        BRA        DISP_BUFF_ADD        ; else loop back to the beginning

PRINT_DISP              LEA         DISPLAY_BUFFER,A1    ; Print a bunch of newlines to blank the screen
                        MOVE.B      #14,D0
                        TRAP        #15
                    
CLR_DISP_BUFF           MOVE.W      #0,(A1)+  ; There's only five words worth of data in the display buffer
                        MOVE.W      #0,(A1)+  ; It's easier just to paste this five times than make a loop
                        MOVE.W      #0,(A1)+
                        MOVE.W      #0,(A1)+
                        MOVE.W      #0,(A1)+ 
                        MOVE.W      #0,(A1)+   
                        

;                        LEA         MOVE_MESG,A1    
;                        MOVE.B      #14,D0
;                        TRAP        #15


STOP
    
    
    
* Put variables and constants here
DISPLAY_BUFFER      DCB.W        6,0              ; 6 words == 12 chars including the '0' at the end
MOVE_MESG           DC.B          'MOVE.B',0
;MOVE_MESG           DC.B          '123456789AB',0 ; 


CR                      EQU         $0D
LF                      EQU         $0A

    END    START        ; last line of source










*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
