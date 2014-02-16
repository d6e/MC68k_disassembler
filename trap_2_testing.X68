*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
START     ORG         $1000
                ; first instruction of program

          ;MOVE.W      #$3000,$7000 ;TODO: try to get the correct data from somewhere

          LEA         MSG_1,A1
          MOVE.B      #14,D0
          TRAP        #15

          MOVE.B      #2,D0           ; Take user input for starting address.
          MOVEA.W     #$2000,A1       
          ;SUB.L       #$FFFFFFFF,(A1)+
          ;SUB.L       #$FFFFFFFF, (A1)
          ;MOVEA.W     #$2000,A1       ; Stores the ascii address in (A1),
          TRAP        #15             ; and the length in D1.W.
          
          MOVEA.W     #$2001,A1
          CMP         #1,D1
          BEQ         ASCII_TO_HEX  ;start converting if we have 1 digit.
          
          MOVEA.W     #$2002,A1
          CMP         #2,D1
          BEQ         ASCII_TO_HEX  ;start converting if we have 2 digits.
          
          MOVEA.W     #$2003,A1
          CMP         #3,D1
          BEQ         ASCII_TO_HEX  ;start converting if we have 3 digits.
          
          MOVEA.W     #$2004,A1
          CMP         #4,D1
          BEQ         ASCII_TO_HEX  ;start converting if we have 4 digits.
          
          MOVEA.W     #$2005,A1
          CMP         #5,D1
          BEQ         ASCII_TO_HEX  ;start converting if we have 5 digits.
          
          MOVEA.W     #$2006,A1
          CMP         #6,D1
          BEQ         ASCII_TO_HEX  ;start converting if we have 6 digits.
          
          MOVEA.W     #$2007,A1
          CMP         #7,D1
          BEQ         ASCII_TO_HEX  ;start converting if we have 7 digits.
          
          MOVEA.W     #$2008,A1
          CMP         #8,D1
          BEQ         ASCII_TO_HEX  ;start converting if we have 8 digits.
          
          LEA         INVALID_LEN_MSG,A1         ;display the length of the input
          MOVE.B      #14,D0
          TRAP        #15   
            
          ;MOVE.L      (A1),D3       ;Move the ascii value we just read in to D3
          ;MOVE.L      (A1),D4
          
          ;MOVE.W      (A1),D1
          ;MOVE.B      #16,D2
          ;MOVE.B      #15,D0    ;print the input back out
          ;TRAP        #15          

          SIMHALT             ; halt simulator
          
; when we get here, A1 is the ascii representation of the least significant digit (i.e., the ones place)
ASCII_TO_HEX    SUB.L       #$FFFFFFFF,$3000
                SUB.L       #$FFFFFFFF,$3004

                MOVE.B   -(A1),$3007
                ANDI.B   #$CF,$3007
                CMP      #1,D1
                BEQ      CONVERSION_DONE
                
                MOVE.B   -(A1),$3006
                ANDI.B   #$CF,$3006
                CMP      #2,D1
                BEQ      CONVERSION_DONE
                
                MOVE.B   -(A1),$3005
                ANDI.B   #$CF,$3005
                CMP      #3,D1
                BEQ      CONVERSION_DONE
                
                MOVE.B   -(A1),$3004
                ANDI.B   #$CF,$3004
                CMP      #4,D1
                BEQ      CONVERSION_DONE
                
                MOVE.B   -(A1),$3003
                ANDI.B   #$CF,$3003
                CMP      #5,D1
                BEQ      CONVERSION_DONE
                
                MOVE.B   -(A1),$3002
                ANDI.B   #$CF,$3002
                CMP      #6,D1
                BEQ      CONVERSION_DONE
                
                MOVE.B   -(A1),$3001
                ANDI.B   #$CF,$3001
                CMP      #7,D1
                BEQ      CONVERSION_DONE
                
                MOVE.B   -(A1),$3000
                ANDI.B   #$CF,$3000
                CMP      #8,D1
                BEQ      CONVERSION_DONE
                
                ;TODO: need to correctly read ABCDEF for each case. 
                ;(Test by entering these values and looking at addresses $2000 and $3000 in simulator.)
                
                ;TODO: once these values are stored correctly, build the final hex value by multiplying each digit by
                ;      hex $10, $100, $1000, etc (one for each case of D1, which still has the number of digits)
                ;      and adding each product to a running total, initialized to 0.
      
               ;TODO: branch to done when we are done
               ;SIMHALT
               
CONVERSION_DONE SIMHALT ;TODO

* Put variables and constants here

CR              EQU         $0D
LF              EQU         $0A

MSG_1           DC.B        'Enter a hex value.',CR,LF,0
INVALID_LEN_MSG DC.B        'Not a valid length for input string.',CR,LF,0

START_ADDR_IN   DS.B        20

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
