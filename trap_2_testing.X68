*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
START                   ORG         $1000
                ; first instruction of program


                        LEA         START_ADDR_MSG,A1
                        MOVE.B      #14,D0
                        TRAP        #15

TAKE_USER_IN            MOVE.L      #$00000000,D1
                        MOVE.L      #$00000000,D4    
                        MOVE.L      #$00000000,D5    
                        MOVE.L      #$00000000,D6
                        MOVE.L      #$00000000,D7    

                        MOVE.B      #2,D0           ; Take user input for starting address.
                        MOVEA.W     #$2000,A1       ; Store the ascii input in A1,
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
          
                        LEA         INVALID_LEN_MSG,A1         ; TODO: branch back to asking for input.
                        MOVE.B      #14,D0
                        TRAP        #15

                        BRA         TAKE_USER_IN   
            
                        SIMHALT             ; halt simulator
          
; when we get here, A1 is the ascii representation of the least significant digit (i.e., the ones place)
ASCII_TO_HEX            MOVE.L   #$00000000,D6      ; running total of converted hex number
                
                        ;first digit
                        MOVE.B   -(A1),D4  ; Move the raw ascii value of first digit into 3007.
                        CMP      #$30,D4
                        BLT      INVALID_ADDR_INPUT ;comes  from inputting invalid characters
                        CMP      #$40,D4
                        BEQ      INVALID_ADDR_INPUT
                        CMP      #$46,D4
                        BGT      INVALID_ADDR_INPUT   
                        ; Convert ascii to hex for that digit.
                        SUB      #$30,D4   ;
                        CMP      #$A,D4
                        BLT      DIG_CONV_DONE_1 ; Necessary to convert some ASCII values.
                        SUB.B    #7, D4                      ; TODO: errors for invalid ASCII values.
                
DIG_CONV_DONE_1         ADD.W    D4,D6
                        CMP      #1,D1
                        BEQ      CONVERSION_DONE
                
                        ;second digit
                        MOVE.L   #$00000000,D4
                        MOVE.B   -(A1),D4
                        CMP      #$30,D4
                        BLT      INVALID_ADDR_INPUT ;comes  from inputting invalid characters
                        CMP      #$40,D4
                        BEQ      INVALID_ADDR_INPUT
                        CMP      #$46,D4
                        BGT      INVALID_ADDR_INPUT   
                        SUB      #$30,D4
                        CMP      #$A,D4             
                        BLT      DIG_CONV_DONE_2    ;digit conversion done 1
                        SUB.B    #7, D4             ; if we have A or greater, then we need to subtract 1.
             
DIG_CONV_DONE_2         MULU.W   #$00000010,D4  ; this part adds $10 * (2nd digit) to our running total.
                        ADD.W    D4,D6 
                  
                        CMP      #2,D1
                        BEQ      CONVERSION_DONE
                
                        ;third digit
                        MOVE.L   #$00000000,D4
                        MOVE.B   -(A1),D4
                        CMP      #$30,D4
                        BLT      INVALID_ADDR_INPUT ;comes  from inputting invalid characters
                        CMP      #$40,D4
                        BEQ      INVALID_ADDR_INPUT
                        CMP      #$46,D4
                        BGT      INVALID_ADDR_INPUT   
                        SUB      #$30,D4
                        CMP      #$A,D4
                        BLT      DIG_CONV_DONE_3 
                        SUB.B    #7, D4
                
DIG_CONV_DONE_3         MULU.W   #$00000100,D4
                        ADD.W    D4,D6 
    
                        CMP      #3,D1
                        BEQ      CONVERSION_DONE
                
                        ;fourth digit
                        MOVE.L   #$00000000,D4
                        MOVE.B   -(A1),D4
                        CMP      #$30,D4
                        BLT      INVALID_ADDR_INPUT ;comes  from inputting invalid characters
                        CMP      #$40,D4
                        BEQ      INVALID_ADDR_INPUT
                        CMP      #$46,D4
                        BGT      INVALID_ADDR_INPUT   
                        SUB      #$30,D4
                        CMP      #$A,D4
                        BLT      DIG_CONV_DONE_4
                        SUB.B    #7, D4
                
DIG_CONV_DONE_4         MULU.W   #$00001000,D4
                        ADD.W    D4,D6 
    
                        CMP      #4,D1
                        BEQ      CONVERSION_DONE
                
                        ;fifth digit
                        MOVE.L   #$00000000,D4
                        MOVE.B   -(A1),D4
                        CMP      #$30,D4
                        BLT      INVALID_ADDR_INPUT ;comes  from inputting invalid characters
                        CMP      #$40,D4
                        BEQ      INVALID_ADDR_INPUT
                        CMP      #$46,D4
                        BGT      INVALID_ADDR_INPUT   
                        SUB      #$30,D4
                        CMP      #$A,D4
                        BLT      DIG_CONV_DONE_5
                        SUB.B    #$7, D4
                
DIG_CONV_DONE_5         MULU.W   #$0001,D4
                        ADD.W    D4,D7 

                        CMP      #5,D1
                        BEQ      CONVERSION_DONE
                
                        ;sixth digit
                        MOVE.L   #$00000000,D4
                        MOVE.B   -(A1),D4
                        CMP      #$30,D4
                        BLT      INVALID_ADDR_INPUT ;comes  from inputting invalid characters
                        CMP      #$40,D4
                        BEQ      INVALID_ADDR_INPUT
                        CMP      #$46,D4
                        BGT      INVALID_ADDR_INPUT   
                        SUB      #$30,D4
                        CMP      #$A,D4 
                        BLT      DIG_CONV_DONE_6
                        SUB.B    #$7, D4
                
DIG_CONV_DONE_6         MULU.W   #$0010,D4
                        ADD.W    D4,D7
    
                        CMP      #6,D1
                        BEQ      CONVERSION_DONE
                
                        ;seventh digit
                        MOVE.L   #$00000000,D4
                        MOVE.B   -(A1),D4
                        CMP      #$30,D4
                        BLT      INVALID_ADDR_INPUT ;comes  from inputting invalid characters
                        CMP      #$40,D4
                        BEQ      INVALID_ADDR_INPUT
                        CMP      #$46,D4
                        BGT      INVALID_ADDR_INPUT   
                        SUB      #$30,D4
                        CMP      #$A,D4
                        BLT      DIG_CONV_DONE_7
                        SUB.B    #7, D4
                
DIG_CONV_DONE_7         MULU.W   #$0100,D4
                        ADD.W    D4,D7
    
                        CMP      #7,D1
                        BEQ      CONVERSION_DONE
                
                        ;eighth digit
                        MOVE.L   #$00000000,D4
                        MOVE.B   -(A1),D4
                        CMP      #$30,D4
                        BLT      INVALID_ADDR_INPUT ;comes  from inputting invalid characters
                        CMP      #$40,D4
                        BEQ      INVALID_ADDR_INPUT
                        CMP      #$46,D4
                        BGT      INVALID_ADDR_INPUT   
                        SUB      #$30,D4
                        CMP      #$A,D4
                        BLT      DIG_CONV_DONE_8
                        SUB.B    #7, D4
                
DIG_CONV_DONE_8         MULU.W   #$1000,D4
                        ADD.W    D4,D7
    
                        CMP      #8,D1
                        BEQ      CONVERSION_DONE    ;the input was valid and we are done with the conversion
                
INVALID_ADDR_INPUT      LEA      INVALID_ADDR_MSG,A1    ;tell the user the address was invalid and prompt input again.
                        MOVE.B   #14,D0
                        TRAP     #15
                        
                        BRA      TAKE_USER_IN
               
CONVERSION_DONE         LSL.L    #8,D7   ; Prepare for concatenation
                        LSL.L    #8,D7   ; Got to perform the same operation twice to get it all the way to the left
                        ADD.W    D6,D7  ; concatenate the two data registers into one value
                        
                        LEA      THANK_YOU,A1
                        MOVE.B   #14,D0
                        TRAP     #15
                        
                        MOVE.L   D7,D1
                        MOVE.B   #16,D2
                        MOVE.B   #15,D0
                        TRAP     #15
                        
                        LEA      RETURN, A1
                        MOVE.B   #14,D0
                        TRAP     #15
                        
                        LEA      MORE_ADDR_MSG,A1
                        MOVE.B   #14,D0
                        TRAP     #15
                        
                        
                        
                        BRA      TAKE_USER_IN
                        ;SIMHALT ;TODO: show what is in D6. It should be the same as the intended hex input.

* Put variables and constants here

CR                      EQU         $0D
LF                      EQU         $0A
RETURN                  DC.B        CR,LF,0      

START_ADDR_MSG          DC.B        'Enter a starting hex address.',CR,LF,0

INVALID_LEN_MSG         DC.B        'Not a valid length for input address.',CR,LF
                        DC.B        'Please enter a valid-length address.',CR,LF,0
                    
INVALID_ADDR_MSG        DC.B        'Not a valid address.',CR,LF
                        DC.B        'Please enter a valid address.',CR,LF,0
                        
THANK_YOU               DC.B        'Thank you. You entered address $',0        ;TEMPORARY
MORE_ADDR_MSG           DC.B        'Please enter another address.',CR,LF,0     ;TEMPORARY

START_ADDR_IN           DS.B        20

    END    START        ; last line of source




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
