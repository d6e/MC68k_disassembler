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
ASCII_TO_HEX    MOVE.B   #0,D6      ; running total of converted hex number
                
                ;first digit
                MOVE.B   -(A1),D4  ; Move the raw ascii value of first digit into 3007.
                
               
                
                ; Convert ascii to hex for that digit.
                SUB      #$30,D4   ; TODO: once this works correctly for first two digits, change each iteration accordingly
                CMP      #9,D4
                BGT      SUBTRACT_ONE ; Necessary to convert some ASCII values.
                                      ; TODO: errors for invalid ASCII values.
                
                ADD.B   D4,D6
                CMP      #1,D1
                BEQ      CONVERSION_DONE
                
                ;second digit
                MOVE.L   #$00000000,D4
                MOVE.B   -(A1),D4
                SUB      #$30,D4
                CMP      #9,D4
                BGT      SUBTRACT_ONE
             
                MULU.W   #$00000010,D4  ; this part adds $10 * (2nd digit) to our running total.
                ADD.W    D4,D6 
                  
                CMP      #2,D1
                BEQ      CONVERSION_DONE
                
                ;third digit
                MOVE.L   #$00000000,D4
                MOVE.B   -(A1),D4
                SUB      #$30,D4
                CMP      #9,D4
                BGT      SUBTRACT_ONE
                
                MULU.W   #$00000100,D4
                ADD.W    D4,D6 
    
                CMP      #3,D1
                BEQ      CONVERSION_DONE
                
                ;fourth digit
                MOVE.L   #$00000000,D4
                MOVE.B   -(A1),D4
                SUB      #$30,D4
                CMP      #9,D4
                BGT      SUBTRACT_ONE
                
                MULU.W   #$00001000,D4
                ADD.W    D4,D6 
    
                CMP      #4,D1
                BEQ      CONVERSION_DONE
                
                ;fifth digit
                MOVE.L   #$00000000,D4
                MOVE.B   -(A1),D4
                SUB      #$30,D4
                CMP      #9,D4
                BGT      SUBTRACT_ONE
                
                MULU.W   #$0001,D4
                ADD.W    D4,D7 

                CMP      #5,D1
                BEQ      CONVERSION_DONE
                
                ;sixth digit
                MOVE.L   #$00000000,D4
                MOVE.B   -(A1),D4
                SUB      #$30,D4
                CMP      #9,D4
                BGT      SUBTRACT_ONE
                
                MULU.W   #$0010,D4
                ADD.W    D4,D7
    
                CMP      #6,D1
                BEQ      CONVERSION_DONE
                
                ;seventh digit
                MOVE.L   #$00000000,D4
                MOVE.B   -(A1),D4
                SUB      #$30,D4
                CMP      #9,D4
                BGT      SUBTRACT_ONE
                
                MULU.W   #$0100,D4
                ADD.W    D4,D7
    
                CMP      #7,D1
                BEQ      CONVERSION_DONE
                
                ;eight digit
                MOVE.L   #$00000000,D4
                MOVE.B   -(A1),D4
                SUB      #$30,D4
                CMP      #9,D4
                BGT      SUBTRACT_ONE
                
                MULU.W   #$1000,D4
                ADD.W    D4,D7
    
                CMP      #8,D1
                BEQ      CONVERSION_DONE
                
                ;TODO: need to correctly read ABCDEF for each case. 
                ;(Test by entering these values and looking at addresses $2000 and $3000 in simulator.)
                
                ;TODO: once these values are stored correctly, build the final hex value by multiplying each digit by
                ;      hex $10, $100, $1000, etc (one for each case of D1, which still has the number of digits)
                ;      and adding each product to a running total, initialized to 0.
      
               ;TODO: branch to done when we are done
               ;SIMHALT
               
CONVERSION_DONE SIMHALT ;TODO: show what is in D6. It should be the same as the intended hex input.

SUBTRACT_ONE
    SUB.B  #1, D4
    RTS             ; return

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
