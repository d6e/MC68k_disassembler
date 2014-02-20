*-----------------------------------------------------------
* Title      : Disassembler
* Written by : Robert Brandenburg, Danielle Jenkins, Shahin Nahar
* Date       : 2/13/14
* Description: Disassemble hex machine code instructions into 68K instructions
*-----------------------------------------------------------

* TODO: write disassembler
* TODO: more specific TODOs for our plan
* TODO: comments saying who is working where


* Commenting Key: 
*    "----------"  <-- subroutine commenting
*    "##########"  <-- section/role commenting

* Notes on saving registers on run:
*    MOVEM.L A0-A3/D0-D7, -(A7) * copies all working registers to stack
*    MOVEM.L (A7)+, A0-A3/D0-D7 *Restore the registers

* Notes on AND filters (bit masking):
* Example:
*       0001 000 001 111 100   (say you want "001")
*   AND 0000 000 111 000 000   (0 <-- don't want, 1 <-- do want)
*       --------------------
*     = 0000 000 001 000 000
*
* Relevant wiki page:
*   https://en.wikipedia.org/wiki/Mask_(computing)#Masking_bits_to_0
*

*################ BEGIN MAIN ###############################
*** All subroutine calls are made here ***
START                   ORG        $1000       ; first instruction of program
                        BSR        PROMPT_INPUT            ; prompt the user for input
                  ;      BSR        READ_FIRST              ; read the first instruction


STOP                    STOP       #$2700          ; halt simulator, end of main

*################ END MAIN ###############################
*################ BEGIN IO ###############################
*** IO Subroutines are kept here ***

*-------------------- Print ASCII logo ----------------------
PROMPT_INPUT            BSR         TAKE_USER_IN_S ;TODO: change to welcome/ASCII logo
*------------------- Prompt user for input -------------------

                
TAKE_USER_IN_S          MOVE.B      #1,D3
                        LEA         START_ADDR_MSG,A1  ; Prompt user for starting address
                        MOVE.B      #14,D0
                        TRAP        #15

                        BSR         TAKE_USER_INPUT

TAKE_USER_IN_E          MOVE.B      #0,D3
                        LEA         END_ADDR_MSG,A1  ; prompt user for ending address
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        BSR         TAKE_USER_INPUT
                        
TAKE_USER_INPUT         MOVE.L      #$00000000,D1   ; need to clear out the data registers we are about to use to avoid junk data.   
                        MOVE.L      #$00000000,D5    
                        MOVE.L      #$00000000,D6
                        MOVE.L      #$00000000,D7

                        MOVE.B      #2,D0           ; Take user input for next address.
                        MOVEA.W     #$2000,A1       ; Store the ascii input in A1,(note that we might not want to use 2000 here)
                        TRAP        #15             ; and the length in D1.W.  

COUNT_INPUT_DIGITS      MOVEA.W     #$2001,A1
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
          
                        LEA         INVALID_LEN_MSG,A1         ; If we get an invalid length, give and error message and... branch back asking user for input again
                        MOVE.B      #14,D0
                        TRAP        #15

                        BEQ         TAKE_USER_INPUT               



*------------------- Convert to hex subroutine -------------------

ASCII_TO_HEX            MOVE.L      #$00000000,D6      ; running total of converted hex number
                
                        ;first digit
                        MOVE.B      -(A1),D5  ; Move the raw ascii value of first digit into 3007.
                        CMP         #$30,D5
                        BLT         INVALID_ADDR_INPUT ;comes  from inputting invalid characters
                        CMP         #$40,D5
                        BEQ         INVALID_ADDR_INPUT
                        CMP         #$46,D5
                        BGT         INVALID_ADDR_INPUT   
                        ; Convert ascii to hex for that digit.
                        SUB         #$30,D5   ;
                        CMP         #$A,D5
                        BLT         DIG_CONV_DONE_1 ; Necessary to convert some ASCII values.
                        SUB.B       #7, D5                      ; TODO: errors for invalid ASCII values.
                
DIG_CONV_DONE_1         ADD.W       D5,D6
                        CMP         #1,D1
                        BEQ         CONVERSION_DONE
                
                        ;second digit
                        MOVE.L      #$00000000,D5
                        MOVE.B      -(A1),D5
                        CMP         #$30,D5
                        BLT         INVALID_ADDR_INPUT ;comes  from inputting invalid characters
                        CMP         #$40,D5
                        BEQ         INVALID_ADDR_INPUT
                        CMP         #$46,D5
                        BGT         INVALID_ADDR_INPUT   
                        SUB         #$30,D5
                        CMP         #$A,D5            
                        BLT         DIG_CONV_DONE_2    ;digit conversion done 1
                        SUB.B       #7, D5             ; if we have A or greater, then we need to subtract 1.
             
DIG_CONV_DONE_2         MULU.W      #$00000010,D5  ; this part adds $10 * (2nd digit) to our running total.
                        ADD.W       D5,D6 
                  
                        CMP         #2,D1
                        BEQ         CONVERSION_DONE
                
                        ;third digit
                        MOVE.L      #$00000000,D5
                        MOVE.B      -(A1),D5
                        CMP         #$30,D5
                        BLT         INVALID_ADDR_INPUT ;comes  from inputting invalid characters
                        CMP         #$40,D5
                        BEQ         INVALID_ADDR_INPUT
                        CMP         #$46,D5
                        BGT         INVALID_ADDR_INPUT   
                        SUB         #$30,D5
                        CMP         #$A,D5
                        BLT         DIG_CONV_DONE_3 
                        SUB.B       #7, D5
                
DIG_CONV_DONE_3         MULU.W      #$00000100,D5
                        ADD.W       D5,D6 
    
                        CMP         #3,D1
                        BEQ         CONVERSION_DONE
                
                        ;fourth digit
                        MOVE.L      #$00000000,D5
                        MOVE.B      -(A1),D5
                        CMP         #$30,D5
                        BLT         INVALID_ADDR_INPUT ;comes  from inputting invalid characters
                        CMP         #$40,D5
                        BEQ         INVALID_ADDR_INPUT
                        CMP         #$46,D5
                        BGT         INVALID_ADDR_INPUT   
                        SUB         #$30,D5
                        CMP         #$A,D5
                        BLT         DIG_CONV_DONE_4
                        SUB.B       #7,D5
                
DIG_CONV_DONE_4         MULU.W      #$00001000,D5
                        ADD.W       D5,D6 
    
                        CMP         #4,D1
                        BEQ         CONVERSION_DONE
                
                        ;fifth digit
                        MOVE.L      #$00000000,D5
                        MOVE.B      -(A1),D5
                        CMP         #$30,D5
                        BLT         INVALID_ADDR_INPUT ;comes  from inputting invalid characters
                        CMP         #$40,D5
                        BEQ         INVALID_ADDR_INPUT
                        CMP         #$46,D5
                        BGT         INVALID_ADDR_INPUT   
                        SUB         #$30,D5
                        CMP         #$A,D5
                        BLT         DIG_CONV_DONE_5
                        SUB.B       #$7, D5
                
DIG_CONV_DONE_5         MULU.W      #$0001,D5
                        ADD.W       D5,D7 

                        CMP         #5,D1
                        BEQ         CONVERSION_DONE
                
                        ;sixth digit
                        MOVE.L      #$00000000,D5
                        MOVE.B      -(A1),D5
                        CMP         #$30,D5
                        BLT         INVALID_ADDR_INPUT ;comes  from inputting invalid characters
                        CMP         #$40,D5
                        BEQ         INVALID_ADDR_INPUT
                        CMP         #$46,D5
                        BGT         INVALID_ADDR_INPUT   
                        SUB         #$30,D5
                        CMP         #$A,D5
                        BLT         DIG_CONV_DONE_6
                        SUB.B       #$7, D5
                
DIG_CONV_DONE_6         MULU.W      #$0010,D5
                        ADD.W       D5,D7
    
                        CMP         #6,D1
                        BEQ         CONVERSION_DONE
                
                        ;seventh digit
                        MOVE.L      #$00000000,D5
                        MOVE.B      -(A1),D5
                        CMP         #$30,D5
                        BLT         INVALID_ADDR_INPUT ;comes  from inputting invalid characters
                        CMP         #$40,D5
                        BEQ         INVALID_ADDR_INPUT
                        CMP         #$46,D5
                        BGT         INVALID_ADDR_INPUT   
                        SUB         #$30,D5
                        CMP         #$A,D5
                        BLT         DIG_CONV_DONE_7
                        SUB.B       #7, D5
                
DIG_CONV_DONE_7         MULU.W      #$0100,D5
                        ADD.W       D5,D7
    
                        CMP         #7,D1
                        BEQ         CONVERSION_DONE
                
                        ;eighth digit
                        MOVE.L      #$00000000,D5
                        MOVE.B      -(A1),D5
                        CMP         #$30,D5
                        BLT         INVALID_ADDR_INPUT ;comes  from inputting invalid characters
                        CMP         #$40,D5
                        BEQ         INVALID_ADDR_INPUT
                        CMP         #$46,D5
                        BGT         INVALID_ADDR_INPUT   
                        SUB         #$30,D5
                        CMP         #$A,D5
                        BLT         DIG_CONV_DONE_8
                        SUB.B       #7, D5
                
DIG_CONV_DONE_8         MULU.W      #$1000,D5
                        ADD.W       D5,D7
    
                        CMP         #8,D1
                        BEQ         CONVERSION_DONE    ;the input was valid and we are done with the conversion
                
INVALID_ADDR_INPUT      LEA         INVALID_ADDR_MSG,A1    ;tell the user the address was invalid and prompt input again.
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        BSR         TAKE_USER_INPUT
                        
INVALID_END_ADDR        LEA         INVALID_END_ADDR_MSG,A1
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        BSR         TAKE_USER_INPUT
                        
INVALID_ADDR_LOW        LEA         INVALID_ADDR_L_MSG,A1    ;tell the user the address was invalid and prompt input again.
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        BSR         TAKE_USER_INPUT

INVALID_ADDR_HIGH       LEA         INVALID_ADDR_H_MSG,A1    ;tell the user the address was invalid and prompt input again.
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        BSR         TAKE_USER_INPUT
               
CONVERSION_DONE         LSL.L       #8,D7   ; Prepare for concatenation
                        LSL.L       #8,D7   ; Got to perform the same operation twice to get it all the way to the left
                        ADD.W       D6,D7  ; concatenate the two data registers into one value
                        
                        CMP.L       #MIN_ADDRESS,D7
                        BLT         INVALID_ADDR_LOW ;Not a valid address-- too low.
                        
                        CMP.L       #MAX_ADDRESS,D7
                        BGT         INVALID_ADDR_HIGH  ;Not a valid address-- too high.
                        
VALID_ADDR              CMPI        #1,D3
                        
                        BEQ         SET_START_ADDR
                        BSR         SET_END_ADDR              
                                               
SET_START_ADDR          MOVEA.L     D7,A5  ;when a valid start address is inputted, store and ask the user for an end address.
                        BSR         TAKE_USER_IN_E

SET_END_ADDR            CMP.L       A5,D7    ;if end address is lower than start address, we get an error.
                        BLT         INVALID_END_ADDR           
                        
                        MOVEA.L     D7,A6  ;when a valid start address is inputted, store and ask the user for an end address.
                        BSR         BEGIN_READ
                        
BEGIN_READ              MOVEA.L      A5,A4 ; keep track of address to print with A4. TODO: could also add this value to the display buffer.
                        MOVE.W      (A5)+,CURRENT_WORD ;look at the first instruction word at the starting address.
                        BSR         PREPARE_DISPLAY

*------------------- Add to display buffer -------------------
;At this point A5 is a valid start address and A6 is a valid end address.
;TODO: prepare the display buffer
PREPARE_DISPLAY         BSR         READ_CURRENT_OP    ;TEMP (though we might still call this after the display buffer is prepared)                       
               
*------------------- Move address pointer for data reading -------------------
; This method is specifically for reading the next OPword.
GO_TO_NEXT_OP           BSR         CHECK_DONE_READING
                         
CONFIRMED_NEXT_OP       CLR         CURRENT_WORD
                        MOVEA.L      A5,A4 ; keep track of address to print with A4. 
                        MOVE.W      (A5)+,CURRENT_WORD
                        BSR         READ_CURRENT_OP
*------------------- Print display buffer -------------------
*------------------- Check if end of data -------------------
CHECK_DONE_READING      CMPA        A6,A5       ; TODO: this comparison is not sufficient, because it will say that $8000 is less than $7000 (since $8000 is negative.)
                        BLT         CONFIRMED_NEXT_OP
                        BSR         DONE_READING
*------------------- Ask user for input -------------------
DONE_READING            LEA         DONE_READING_MSG,A1 ; when we reach the end address, say so and halt the program. TODO: ask user whether we want to read the data again.
                        MOVE.B      #14,D0
                        TRAP        #15
                        JMP         STOP
*################## END IO  #####################################
*################## BEGIN OPCODE ##########################
*** OPcode Subroutines are kept here ***

*------------------- Read current OPcode -------------------
; By this point, CURRENT_WORD should store a potential beginning of an instruction, so we should not increment A5.
READ_CURRENT_OP         BSR         CHECK_CONSTANTS
                        ;CLR         D3  
                        ;CLR         D4
                        ;MOVE.W          
                        ;ANDI.W      #FILT_2BIT_1,D3 ; and A5 (current address we are reading) should have just been incremented to a point immediately after that word.
 
*------------------ Check current word for constants---------
; By this point, the current word should store a potential beginning of an instruction                   
CHECK_CONSTANTS         BSR         CHECK_NOP

CHECK_RESET             CMP         #RESET_CODE,(CURRENT_WORD) ; TODO: test that this is correct syntax
                        BNE         CHECK_NOP
                       
RESET_FOUND             JMP         STOP  ;TODO: case for reset found    
 
CHECK_NOP               CMP         #NOP_CODE,(CURRENT_WORD) ; TODO: test that this is correct syntax
                        BNE         CHECK_STOP

;NOTE: this SR is temporary. Once we have the display buffer, it will work differently.                 
NOP_FOUND               LEA         DOLLAR,A1     ; '$'
                        MOVE.B      #14,D0
                        TRAP        #15
                
                        MOVE.L      A4,D1         ; display the address NOP was found at
                        MOVE.B      #16,D2
                        MOVE.B      #15,D0
                        TRAP        #15

                        LEA         SPACE,A1      ; ' '
                        MOVE.B      #14,D0      
                        TRAP        #15

                        LEA         NOP_MSG,A1    ; 'NOP'
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        LEA         RETURN,A1    ; (return)
                        MOVE.B      #14,D0
                        TRAP        #15
               
                        BSR         GO_TO_NEXT_OP   ; when we are done parsing and displaying the MOVE instruction, go to the next OPcode.
                        
CHECK_STOP              CMP         #STOP_CODE,(CURRENT_WORD)
                        BNE         CHECK_NON_CONSTANTS

STOP_FOUND              JMP         STOP  ;TODO: case for stop found               

;TODO: add cases for rest of valid constant OPcodes here

*----------------- Check current word for non-constants---------
;NOTE: we currently know that CURRENT_WORD is not a constant by the time we reach this SR.

CHECK_NON_CONSTANTS     CLR         D3
                        BSR         CHECK_MOVE_B
                        
CHECK_MOVE_B            MOVE.W      CURRENT_WORD,D3
                        ANDI.W      #FILT_NIB_1,D3
                        CMP         #CONST_MOVE_B,D3
                        BNE         CHECK_MOVE_W
                        
;NOTE: this SR is temporary. will be different with display buffer.
MOVE_B_FOUND            MOVE.B      #BYTE_SIZE,CURRENT_OP_SIZE

                        LEA         DOLLAR,A1     ; '$'
                        MOVE.B      #14,D0
                        TRAP        #15
                
                        MOVE.L      A4,D1 ;display the address MOVE.B was found at
                        MOVE.B      #16,D2
                        MOVE.B      #15,D0
                        TRAP        #15

                        LEA         SPACE,A1         ; ' '
                        MOVE.B      #14,D0      
                        TRAP        #15

                        ;FROM TEST:
                        ;MOVE.B #10,D0
                        ;MOVE.B D1, D1
                        ;MOVE.B D1, $10000000
                        ;MOVE.B D1, $1000
                        
                        ; TODO: error checking first
                        ;
                        ; possible errors:
                        ;       CURRENT_DEST_MD = CONST_IMMEDIATE_REG (immediate data cannot be a destination)
                        ;       CURRENT_SRC_MD  = CONST_ADDR_REG_MD   (byte is not a valid size for this move)
                        ;       CURRENT_DEST_MD = CONST_ADDR_REG_MD   (byte is not a valid size, although we should be using MOVEA at this point, not MOVE.)
                        ;       TODO: figure out other possible errors.
                        
                        ; after we confirm that there are no errors, we begin sending information about the MOVE instruction to our temp variables.
                        
                        
                        ; at this point, need to read more information (parsed by EA, probably)
                        ; now that we have a move instruction, we set our EA variables accordingly:
                        BSR         READ_DEST_REG      ; EA will set CURRENT_DEST_REG.
                        BSR         READ_DEST_MODE     ; EA will set CURRENT_DEST_MD.
                        BSR         READ_SOURCE_MODE   ; EA will set CURRENT_SRC_MD.
                        BSR         READ_SOURCE_REG    ; EA will set CURRENT_SRC_REG.
                        
                        ;      need to check whether we need to read additional data before we start displaying the
                        ;      instruction (for instance, this is necessary for MOVE.B #10,D0).
                        BSR         READ_SOURCE_DATA    ; EA will set CURRENT_SOURCE_DATA if necessary.
                        BSR         READ_DEST_DATA      ; EA will set CURRENT_DEST_DATA if necessary. 
                       
                        LEA         MOVE_B_MSG,A1    ; 'MOVE.B'
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        LEA         SPACE,A1         ; ' '
                        MOVE.B      #14,D0      
                        TRAP        #15
                        
                        ; once we have the four (or five, or six) values, proceed to parse the instruction accordingly.
                        BSR         DISPLAY_SOURCE  ; Tell EA to parse and display the source. EX: (A1)   D3    #10   $1000 etc
                        
                        LEA         COMMA,A1         ; ','
                        MOVE.B      #14,D0      
                        TRAP        #15
                        
                        BSR         DISPLAY_DEST    ; Tell EA to parse and display the destination.
                        
                        LEA         RETURN,A1    ; (return)
                        MOVE.B      #14,D0
                        TRAP        #15
               
                        BSR         GO_TO_NEXT_OP
                        
CHECK_MOVE_W            MOVE.W      CURRENT_WORD,D3
                        ANDI.W      #FILT_NIB_1,D3
                        CMP         #CONST_MOVE_W,D3
                        BNE         CHECK_MOVE_L
                        
MOVE_W_FOUND            JMP         STOP ;TODO: MOVE.W
                        
CHECK_MOVE_L            MOVE.W      CURRENT_WORD,D3
                        ANDI.W      #FILT_NIB_1,D3
                        CMP         #CONST_MOVE_L,D3
                        ;BNE         CHECK_MOVE_W
                        JMP         STOP ;TODO: keep checking for more possible instructions
                        
MOVE_L_FOUND            JMP         STOP ;TODO: MOVE.L
                        

                        JMP         STOP    ;TODO: CURRENT_WORD still holds current possible 16 bit instruction, so read it for current word.        

                       

                                                            
       
                ;TODO: process for reading hex instructions (after the first instruction):
                ;           1) Go to start of instruction reading loop, passing in the address of next instruction.
                ;           2) Store a word (16 bits) from that address.
                ;           3) Read the first 4 bits of the word using a filter.
                ;           4) branch to one of the following paths based on these bits:
                ;               a) 0000: Read the next 3 bits (i.e., the destination mode). Branch:
                ;                   i.   000: Read the bits at 0000 0000 XXXX XXXX (may want to make this filter) Branch:
                ;                       1) 00 111 100: ORI TO CCR (need to read data, I think)
                ;                       2) 01 111 100: ORI TO SR (need to read data, I think)
                ;                       3) (default) ORI. Now, read and store:
                ;                           SIZE:       0000 0000 XX00 0000 (need to make this filter)
                ;                           MODE:       0000 0000 00XX X000 (need to make this filter)
                ;                           REGISTER:   0000 0000 0000 0XXX (need to make this filter)
                ;                           only mandatory additional data is the immediate data.
                ;                   ii.  001: Read the bits at 0000 0000 XXXX XXXX (may want to make this filter) Branch:
                ;                       1) 00 111 100: ANDI TO CCR (need to read data, I think)
                ;                       2) 01 111 100: ANDI TO SR (need to read data, I think)
                ;                       3) (default) ANDI. Now, read and store:
                ;                           SIZE:       0000 0000 XX00 0000 (need to make this filter)
                ;                           MODE:       0000 0000 00XX X000 (need to make this filter)
                ;                           REGISTER:   0000 0000 0000 0XXX (need to make this filter)
                ;                           only mandatory additional data is the immediate data.
                ;                   iii. 101: Read the bits at 0000 0000 XXXX XXXX (may want to make this filter) Branch:
                ;                       1) 00 111 100: EORI TO CCR (need to read data, I think)
                ;                       2) 01 111 100: EORI TO SR (need to read data, I think)
                ;                       3) (default) EORI. Now, read and store:
                ;                           SIZE:       0000 0000 XX00 0000 (need to make this filter)
                ;                           MODE:       0000 0000 00XX X000 (FILT_SRC_MODE)
                ;                           REGISTER:   0000 0000 0000 0XXX (FILT_SRC_REG)
                ;                           only mandatory additional data is the immediate data.
                ;                   iv.  011: ADDI. Now read and store:
                ;                           SIZE:       0000 0000 XX00 0000 (need to make this filter)
                ;                           MODE:       0000 0000 00XX X000 (FILT_SRC_MODE)
                ;                           REGISTER:   0000 0000 0000 0XXX (FILT_SRC_REG)
                ;                           only mandatory additional data is the immediate data.
                ;                   v.   010: SUBI. Now read and store:
                ;                           SIZE:       0000 0000 XX00 0000 (need to make this filter)
                ;                           MODE:       0000 0000 00XX X000 (FILT_SRC_MODE)
                ;                           REGISTER:   0000 0000 0000 0XXX (FILT_SRC_REG)
                ;                           only mandatory additional data is the immediate data.
                ;                   vi.  110: CMPI. Now read and store:
                ;                           SIZE:       0000 0000 XX00 0000 (need to make this filter)
                ;                           MODE:       0000 0000 00XX X000 (FILT_SRC_MODE)
                ;                           REGISTER:   0000 0000 0000 0XXX (FILT_SRC_REG)
                ;                           only mandatory additional data is the immediate data.
                ;                   vii. 100: BTST, BCHG, BCLR, BSET (TODO: expand this section if we need these OPcodes)
                ;                   viii.(default): BTST, BCHG, BCLR, BSET (with data register)(TODO: expand this section if we need these OPcodes)
                ;               b) 0001: (MOVE.B). Now read and store:
                ;                           DESTINATION REGISTER: 0000 XXX0 0000 0000 (FILT_DEST_REG)
                ;                           DESTINATION MODE:     0000 000X XX00 0000 (FILT_DEST_MODE)
                ;                           SOURCE MODE:          0000 0000 00XX X000 (FILT_SCR_MODE)
                ;                           SOURCE REGISTER:      0000 0000 0000 0XXX (FILT_SRC_REG)
                ;                           The modes (and maybe register) will tell us whether we need to read additional data for this MOVE.
                ;               c) 0011: (MOVE.W). Now read and store:
                ;                           DESTINATION REGISTER: 0000 XXX0 0000 0000 (FILT_DEST_REG)
                ;                           DESTINATION MODE:     0000 000X XX00 0000 (FILT_DEST_MODE)
                ;                           SOURCE MODE:          0000 0000 00XX X000 (FILT_SCR_MODE)
                ;                           SOURCE REGISTER:      0000 0000 0000 0XXX (FILT_SRC_REG)
                ;                           The modes (and maybe register) will tell us whether we need to read additional data for this MOVE.
                ;               d) 0010: (MOVE.L). Now read and store:
                ;                           DESTINATION REGISTER: 0000 XXX0 0000 0000 (FILT_DEST_REG)
                ;                           DESTINATION MODE:     0000 000X XX00 0000 (FILT_DEST_MODE)
                ;                           SOURCE MODE:          0000 0000 00XX X000 (FILT_SCR_MODE)
                ;                           SOURCE REGISTER:      0000 0000 0000 0XXX (FILT_SRC_REG)
                ;                           The modes (and maybe register) will tell us whether we need to read additional data for this MOVE.
                ;               e) 0100: Read the bits at 0000 XXXX 0000 0000 (need filter) Branch:
                ;                   i.      0000: Read the bits at 0000 0000 XX00 0000 (need filter) Branch:
                ;                               1. 11: MOVE from SR. (TODO)
                ;                               2. (DEFAULT) NEGX. (the two bits are size) (TODO)
                ;                   ii.     0100: Read the bits at 0000 0000 XX00 0000 (need filter) Branch:
                ;                               1. 11 MOVE to CCR. (TODO)
                ;                               2. (DEFAULT) NEG. (the two bits are size) (TODO)
                ;                   iii.    0110: Read the bits at 0000 0000 XX00 0000 (need filter) Branch:
                ;                               1. 11 MOVE to SR. (TODO)
                ;                               2. (DEFAULT) NOT. (the two bits are size) (TODO)
                ;                   iv.     0010: CLR. (TODO)
                ;                    v.     1000: (EXT, NBCD, SWAP, PEA, MOVEM (dir 0)) (TODO)
                ;                   vi.     1010: Check the bits at 0000 XX00 0000 0000 (need filter) Branch:
                ;                           1. 11: check the bits at 0000 00XX XXXX XXXX (need filter) Branch:
                ;                               a. 11 1100: ILLEGAL (TODO)
                ;                               b. (default) TAS (TODO)
                ;                           2. (default) TST (TODO)
                ;                  vii.     1110: (TRAP, LINK, UNLK, MOVE USP, RESET, NOP, STOP, RTE, RTS, TRAPV, RTR, JSR, JMP) (TODO)
                ;                 viii.     (DEFAULT): (MOVEM, LEA, CHK,) (TODO)    
                ;               f) 0101: (ADDQ, SUBQ, Scc, DBcc): Read the bits at 0000 0000 XX00 0000 (need filter) Branch:
                ;                    i. 11: Read the bit at 0000 000X 0000 0000 (need filter) Branch:
                ;                           1. 0: ADDQ (TODO)
                ;                           2. 1: SUBQ (TODO)
                ;                   ii. (default) (bits are size) read the bits at 0000 00XX X000 (FILT_SRC_MODE). Branch:
                ;                           1. 001: DBCC (TODO)
                ;                           2. (default): Scc (TODO)
                ;               g) 0110: Read the bit at 0000 XXXX 0000 0000 (need filter) Branch:
                ;                    i. 0000: BRA (TODO)
                ;                   ii. 0001: BSR (TODO)
                ;                  iii. (default) Bcc (TODO)
                ;               h) 0111: MOVEQ (TODO)
                ;               i) 1000: (DIVU, DIVS, SBCD, OR) (TODO)
                ;               j) 1001: (SUB, SUBX, SUBA) (TODO)
                ;               k) 1011: (EOR, CMPM, CMP, CMPA) (TODO)
                ;               l) 1100: (MULU, MULS, ABCD, EXG, AND) (TODO)
                ;               m) 1101: (ADD, ADDX, ADDA) (TODO)
                ;               n) 1110: (ASd, LSd, ROXd, ROd, ASd, LSd, ROXd, ROd) (TODO)
                ;               o) (default) The code is invalid. Not yet sure what we do in this case.
                ;   
                ;   
                ;
                
                ;TODO: Use AND operations with filters to create values which can be
                ;      checked against constants to narrow down OPcodes.
                
                ;TODO: Since it will take a while to decode every possible OPcode, we
                ;      should first have a default "Error" subroutine which the program
                ;      branches to once all other possibilities have been ruled out.

*###################### END OPCODE ##################################
*###################### BEGIN EA ##################################
*** EA Subroutines are kept here ***
*----------------------Check the destination register of the current word.-------------
READ_DEST_REG           CLR         D4
                        MOVE.W      CURRENT_WORD,D4
                        ANDI.W      #FILT_DEST_REG,D4       ; turn D4 into 0000 XXX0 0000 0000
                        LSR.W       #8,D4                   ; turn D4 into 0000 0000 0000 0XXX
                        LSR.W       #1,D4                   ; 9 would be invalid, so we shift 8, then 1
                        MOVE.B      D4,CURRENT_DEST_REG
                        MOVE.B      D4,CURRENT_REG
                        RTS

*----------------------Check the destination mode of the current word.-------------
*(assuming the destination is where it would be in MOVE).
READ_DEST_MODE          CLR         D4
                        MOVE.W      CURRENT_WORD,D4
                        ANDI.W      #FILT_DEST_MD,D4        ; turn D4 into 0000 000X XX00 0000
                        LSR.W       #6,D4                   ; turn D4 into 0000 0000 0000 0XXX
                        MOVE.B      D4,CURRENT_DEST_MD
                        MOVE.B      D4,CURRENT_MD
                        RTS

;By this point, CURRENT WORD holds the first 16 bits of an instruction we are looking at.
;(we should already know the OPcode by this point, so this will be called by various OPcode subroutines.)
*---------------------- Check the source mode of the current word.--------------------
*(assuming the source is where it would be in MOVE).
READ_SOURCE_MODE        CLR         D4
                        MOVE.W      CURRENT_WORD,D4
                        ANDI.W      #FILT_SRC_MD,D4                 ; turn source mode into 0000 0000 00XX X000
                        LSR.W       #3,D4                           ; turn source mode into 0000 0000 0000 0XXX
                        MOVE.B      D4,CURRENT_SRC_MD
                        MOVE.B      D4,CURRENT_MD
                        RTS
                        
*----------------------Check the source register of the current word.-----------------
READ_SOURCE_REG         CLR         D4
                        MOVE.W      CURRENT_WORD,D4
                        ANDI.W      #FILT_SRC_REG,D4        ; turn D4 into 0000 0000 0000 0XXX. (no need for LSR in this case.)
                        MOVE.B      D4,CURRENT_SRC_REG
                        MOVE.B      D4,CURRENT_REG
                        RTS
                        
*----------------------Read additional source data associated with the current word (if necessary).----------------- 
*This needs to postincrement A5 as necessary.
READ_SOURCE_DATA        CLR         D4
                        MOVE.W      CURRENT_WORD,D4
                        ANDI.W      #FILT_SRC_MD,D4         ; check the source mode of D4
                        LSR.W       #3,D4
                        CMP         #CONST_ADDR_MISC_MD,D4  ; see if we have a source mode that requires additional data.
                        BEQ         CONFIRM_READ_SRC_DATA   ; if so, we then we read the register for more information about the type of additional data we need to read.                    
                        RTS
                        
CONFIRM_READ_SRC_DATA   CLR         D4                           
                        MOVE.W      CURRENT_WORD,D4
                        ANDI.W      #FILT_SRC_REG,D4             ; put the source register in D4  

                        BSR         CONFIRM_READ_DATA
                        MOVE.L      CURRENT_DATA,CURRENT_SRC_DATA
                        RTS
 
*----------------------Read additional destination data associated with the current word (if necessary).----------------- 
*This needs to postincrement A5 as necessary.                       
READ_DEST_DATA          CLR         D4
                        MOVE.W      CURRENT_WORD,D4
                        ANDI.W      #FILT_DEST_MD,D4         ; check the destination mode of D4
                        LSR.W       #6,D4
                        CMP         #CONST_ADDR_MISC_MD,D4   ; see if we have a destination mode that requires additional data.
                        BEQ         CONFIRM_READ_DEST_DATA   ; if so, we then we read the register for more information about the type of additional data we need to read.                    
                        RTS
                                            
CONFIRM_READ_DEST_DATA  CLR         D4                           
                        MOVE.W      CURRENT_WORD,D4
                        ANDI.W      #FILT_SRC_REG,D4             ; put the destination register in D4  
                        LSR.W       #8,D4
                        LSR.W       #1,D4
                        
                        BSR         CONFIRM_READ_DATA
                        MOVE.L      CURRENT_DATA,CURRENT_DEST_DATA
                        RTS

*-----------------------Read some additional data.----------------------------------------------------------
      ; This same subroutine is used for reading source and destination data.
      ; By this point, D4 holds whatever register we currently care about. (could also use CURRENT_REG)         
CONFIRM_READ_DATA       CMP         #CONST_COUNTR_DISPLC_REG,D4  ; see if we are reading counter w/ displacement
                        BEQ         READ_COUNTR_DISPLC_DATA
                   
                        CMP         #CONST_COUNTR_INDEX_REG,D4   ; see if we are reading counter w/ index
                        BEQ         READ_COUNTR_INDEX_DATA
                        
                        CMP         #CONST_ABS_SHORT_REG,D4      ; see if we are reading absolute short address
                        BEQ         READ_ABS_SHORT_DATA
                        
                        CMP         #CONST_ABS_LONG_REG,D4       ; see if we are reading absolute long address
                        BEQ         READ_ABS_LONG_DATA 
                        
                        CMP         #CONST_IMMEDIATE_REG,D4       ; see if we are reading immediate data
                        BEQ         READ_IMMEDIATE_DATA
     
                        RTS
                        
; TODO: each of these SRs should increment A5 by the proper amount while also storing the correct data in CURRENT_DATA.
READ_COUNTR_DISPLC_DATA RTS ; TODO: read data for counter w/ displacement (d16,PC)

READ_COUNTR_INDEX_DATA  RTS ; TODO: read data for counter w/ index        (d16,PC,Xn)

READ_ABS_SHORT_DATA     RTS ; TODO: read data for absolute short address  (xxx).W

READ_ABS_LONG_DATA      RTS ; TODO: read data for absolute long address   (xxx).L

READ_IMMEDIATE_DATA     BSR         CHECK_IMM_BYTE
                        RTS

    ; if this is a byte operation, we read an additional word.
CHECK_IMM_BYTE          CLR         D4
                        MOVE.B      CURRENT_OP_SIZE,D4
                        CMP         #BYTE_SIZE,D4
                        BEQ         READ_IMMEDIATE_DATA_W
                        CLR         D4                          ; this redundancy might be necessary for this subroutine to work
                        MOVE.B      CURRENT_OP_SIZE,D4
                        CMP         #BYTE_SIZE,D4  
                        BNE         CHECK_IMM_WORD              ; only go to next SR if we are not reading a byte. otherwise, return now.
                        RTS

    ; if this is a word operation, we read an additional word.                        
CHECK_IMM_WORD          CLR         D4
                        MOVE.B      CURRENT_OP_SIZE,D4
                        CMP         #WORD_SIZE,D4
                        BEQ         READ_IMMEDIATE_DATA_W
                        CMP         #WORD_SIZE,(CURRENT_OP_SIZE) ;TODO: change this part to be like CHECK_IMM_BYTE once that method is working.
                        BNE         CHECK_IMM_LONG
                        RTS

    ; if this is a long operation, we read an additional long.                        
CHECK_IMM_LONG          CLR         D4
                        MOVE.B      CURRENT_OP_SIZE,D4
                        CMP         #LONG_SIZE,D4
                        BEQ         READ_IMMEDIATE_DATA_L
                        CMP         #LONG_SIZE,(CURRENT_OP_SIZE) ;TODO: change this part to be like CHECK_IMM_BYTE once that method is working.
                        BNE         CHECK_IMM_WORD
                        RTS

READ_IMMEDIATE_DATA_W   MOVE.W      (A5)+,CURRENT_DATA ; read an additional word and store its value in CURRENT_DATA
                        RTS
                        
READ_IMMEDIATE_DATA_L   MOVE.L      (A5)+,CURRENT_DATA
                        RTS
                        
; TODO: need to check for all these possibilities
;CONST_COUNTR_DISPLC_REG EQU         $02      ; Counter w/ displacement:      XXXX X010
;CONST_COUNTR_INDEX_REG  EQU         $03      ; Counter w/ index:          XXXX X011
;CONST_ABS_SHORT_REG     EQU         $00      ; Absolute word:          (xxx).W       XXXX X000
;CONST_ABS_LONG_REG      EQU         $01      ; Absolute long:          (xxx).L       XXXX X001
;CONST_IMMEDIATE_REG 
                        ;TODO: finish writing this method (Robert)
                        
*----------------------Read additional destination data associated with the current word (if necessary).----------------- 
*NOTE: pretty sure we will not use this method at all.
;READ_DEST_DATA          CLR         D4
;                        MOVE.W      CURRENT_WORD,D4
;                        ;TODO: finish writing this method (Robert)
                        
*----------------------Display the source for the current instruction.-----------------
*by this point, error checking should already be done and CURRENT_SRC_MD and CURRENT_SRC_REG should have the data we need.
DISPLAY_SOURCE          MOVE.B      CURRENT_SRC_MD,CURRENT_MD
                        MOVE.B      CURRENT_SRC_REG,CURRENT_REG    ; necessary for some cases, like absolute addressing or immediate data.
                        MOVE.L      CURRENT_SRC_DATA,CURRENT_DATA
                        BSR         CHECK_ADDRESSING_MODES   
                        RTS  
                        
*----------------------Display the destination for the current instruction.-----------------
*by this point, error checking should already be done and CURRENT_DEST_MD and CURRENT_DEST_REG should have the data we need.
DISPLAY_DEST            MOVE.B      CURRENT_DEST_MD,CURRENT_MD
                        MOVE.B      CURRENT_DEST_REG,CURRENT_REG    ; necessary for some cases, like absolute addressing or immediate data.
                        MOVE.L      CURRENT_DEST_DATA,CURRENT_DATA
                        BSR         CHECK_ADDRESSING_MODES     
                        RTS  
                        

                        
*-----------------------Mode checks (for displaying)---------
*these do not care whether the mode is for source or destination.
CHECK_ADDRESSING_MODES  BSR         CHECK_DATA_REG_MD
                        RTS
           
CHECK_DATA_REG_MD       CMP.B       #CONST_DATA_REG_MD,CURRENT_MD   ; check for CURRENT_MD = ...0000
                        BNE         CHECK_ADDR_REG_MD
                        ;case for source mode is data register mode.
                       
                        ;TEMP. should send some instruction to display buffer, instead.
                        LEA         MSG_D,A1               ;print out 'D'
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        LEA         CURRENT_SRC_REG,A1      ;print out the number of the data register.
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        RTS
                        
CHECK_ADDR_REG_MD       CMP.B       #CONST_ADDR_REG_MD,CURRENT_MD   ; check for CURRENT_MD = ...0001
                        BNE         CHECK_ADDR_IND_MD
                        ;TODO: case for source mode is address register mode.
                        RTS
                        
CHECK_ADDR_IND_MD       CMP.B       #CONST_ADDR_IND_MD,CURRENT_MD   ; check for CURRENT_MD = ...0010
                        BNE         CHECK_ADDR_INCR_MD
                        ;TODO: case for source mode is address indirect mode.
                        RTS

CHECK_ADDR_INCR_MD      CMP.B       #CONST_ADDR_INCR_MD,CURRENT_MD  ; check for CURRENT_MD = ...0011
                        BNE         CHECK_ADDR_DECR_MD
                        ;TODO: case for source mode is address indirect postincrement mode.
                        RTS

CHECK_ADDR_DECR_MD      CMP.B       #CONST_ADDR_DECR_MD,CURRENT_MD  ; check for CURRENT_MD = ...0100
                        BNE         CHECK_ADDR_DISPLC_MD
                        ;TODO: case for source mode is address indirect postdecrement mode.
                        RTS     

CHECK_ADDR_DISPLC_MD    CMP.B       #CONST_ADDR_DISPLC_MD,CURRENT_MD  ; check for CURRENT_MD = ...0101
                        BNE         CHECK_ADDR_INDEX_MD
                        ;TODO: case for source mode is address with displacement mode.
                        RTS    

CHECK_ADDR_INDEX_MD     CMP.B       #CONST_ADDR_INDEX_MD,CURRENT_MD  ; check for CURRENT_MD = ...0110
                        BNE         CHECK_ADDR_MISC_MD
                        ;TODO: case for source mode is address with index mode.
                        RTS 
                         
CHECK_ADDR_MISC_MD      CMP.B       #CONST_ADDR_MISC_MD,CURRENT_MD  ; check for CURRENT_MD = ...0111
                        ;BNE         ;where to branch if it's not MISC? anything else should be impossible at this point. Maybe error?
 
                        ;TODO: instead of immediate, branch in order to: CHECK_COUNTR_DISPLC_REG, CHECK_COUNTR_INDEX_REG, CHECK_ABS_SHORT_REG, 
                        ;       CHECK_ABS_LONG_REG, then CHECK_IMMEDIATE_REG 
                        BSR         CHECK_IMMEDIATE_REG
                        RTS   
*-----------------------Register checks (for displaying only)---------
*these do not care whether the register is for source or destination.
*not for cases where reg is simply a number (like D5, A5, (A5), etc)

; TODO: change this method once we have the additional data stored in CURRENT_DATA.
CHECK_IMMEDIATE_REG     CMP.B       #CONST_IMMEDIATE_REG,CURRENT_REG
                        ;TODO: BNE for not immediate
                        LEA         HASH,A1               ; print out '#'. (NOTE: should send this to display buffer instead.)
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        LEA         DOLLAR,A1             ; print out '$'. (this saves time since we can more easily find the hex value of the immediate data.)
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        LEA         CURRENT_DATA,A1       ; print out the immediate data we are concerned with. (NOTE: this doesn't work right now.)
                        MOVE.B      #14,D0  
                        TRAP        #15
                        
                        RTS
                        
                        ;TODO: in this case, we need to use MOVE.?  (A5)+,X where ? is the correct size and X is some temp value for printing.

*###################### END EA ##################################
*############# BEGIN VARIABLES/CONSTANTS #########################
*** Variables and Constants are kept here ***

*output characters
CR                      EQU         $0D
LF                      EQU         $0A
RETURN                  DC.B        CR,LF,0
SPACE                   DC.B        ' ',0
DOLLAR                  DC.B        '$',0
COMMA                   DC.B        ',',0
HASH                    DC.B        '#',0

*output messages
    ;TODO: consider also giving the user the range of valid start/end addresses
START_ADDR_MSG          DC.B        'Please enter a starting hex address to read from.',CR,LF,0
END_ADDR_MSG            DC.B        'Please enter an ending hex address to read from.',CR,LF,0

INVALID_LEN_MSG         DC.B        'Not a valid length for input address.',CR,LF
                        DC.B        'Please enter a valid-length address.',CR,LF,0
INVALID_ADDR_MSG        DC.B        'Not a valid address.',CR,LF
                        DC.B        'Please enter a valid address.',CR,LF,0
INVALID_END_ADDR_MSG    DC.B        'Not a valid end address.',CR,LF
                        DC.B        'Please enter an end address after the start address.',CR,LF,0
                      
INVALID_ADDR_L_MSG      DC.B        'Not a valid address (too low).',CR,LF
                        DC.B        'Please enter a valid address.',CR,LF,0
                        
INVALID_ADDR_H_MSG      DC.B        'Not a valid address (too high).',CR,LF
                        DC.B        'Please enter a valid address.',CR,LF,0
                        
DONE_READING_MSG        DC.B        'Done reading the program.',CR,LF,0

*output instruction names (OPcodes)
    ;constants
RESET_MSG               DC.B        'RESET',0
NOP_MSG                 DC.B        'NOP',0
STOP_MSG                DC.B        'STOP',0
    ;moves
MOVE_B_MSG              DC.B        'MOVE.B',0
MOVE_W_MSG              DC.B        'MOVE.W',0
MOVE_L_MSG              DC.B        'MOVE.L',0

*other output instruction message constans
MSG_D                   DC.B        'D',0
MSG_A                   DC.B        'A',0

*storage locations for input
START_ADDR_IN           DS.B        20

*other I/O-related variables/constants
INPUTTING_START         SET         1 ;if 1, we are inputting start address. If 0, we are inputting end address.
DISPLAY_BUFFER          DS.W        5

*EA/OPcode parsed instruction variables/constants
CURRENT_WORD            DS.W        1 ; current first 16 bits of an instruction.
CURRENT_OP_SIZE         DS.B        1 ; current operation size. Byte = 01, Word = 11, Long = 10

CURRENT_MD              DS.B        1 ; current mode we are concerened with (ex: 000 for data register mode.)
CURRENT_REG             DS.B        1 ; current register number we are concerned with(address, data, etc) that we are looking at. Ex: D0,A5,etc

CURRENT_SRC_MD          DS.B        1 ; current source mode
CURRENT_SRC_REG         DS.B        1 ; current source register
CURRENT_DEST_MD         DS.B        1 ; current desination mode
CURRENT_DEST_REG        DS.B        1 ; current desination register

CURRENT_DATA            DS.L        1 ; current addition data we are concerned with
CURRENT_SRC_DATA        DS.L        1 ; current additional data for source (like absolute addresses, immediate data, etc)
CURRENT_DEST_DATA       DS.L        1 ; current additional data for destination (like absolute addresses, immediate data, etc) 

*size constans
BYTE_SIZE               EQU         $01 ; 0000 0001
WORD_SIZE               EQU         $03 ; 0000 0011
LONG_SIZE               EQU         $02 ; 0000 0010

*address constants
MIN_ADDRESS             EQU         $00003000
MAX_ADDRESS             EQU         $0FFF0000

*address variables
TEST_ORIGIN             SET         $00007000
NEXT_ADDR               SET         TEST_ORIGIN
END_ADDR                SET         $00009000

*filters for isolating parts of a hexa instruction. X means 'unknown' and can be 0 or one after ANDI filter.
*To filter an instruction, ANDI it with the desired filter.
FILT_2BIT_1             EQU         $C000   ;first 2 bits:                          XX00 0000 0000 0000
FILT_NIB_1              EQU         $F000   ;first nibble:                          XXXX 0000 0000 0000
FILT_MOVE_SIZE          EQU         $3000   ;Size of a move operation:              00XX 0000 0000 0000
FILT_DEST_REG           EQU         $0E00   ;destination register:                  0000 XXX0 0000 0000
FILT_DEST_MD            EQU         $01A0   ;destination mode:                      0000 000X XX00 0000
FILT_SRC_MD             EQU         $0038   ;source mode:                           0000 0000 00XX X000
FILT_SRC_REG            EQU         $0007   ;source register:                       0000 0000 0000 0XXX

*constants for comparing with filtered instructions. X means 'don't care' (and will be set to 0 by previous filter)
*(These do not represent the complete insturctions.)
*(Also note that repetition is allowed for clarity's sake, so two constants can share a value.)
CONST_ALL_0             EQU         $0000   ; all 0s:                               0000 0000 0000 0000
    ;MOVE
CONST_MOVE_B            EQU         $1000   ; MOVE.B (use first nib)                0001 0000 0000 0000
CONST_MOVE_W            EQU         $3000   ; MOVE.W (use first nib)                0011 0000 0000 0000
CONST_MOVE_L            EQU         $2000   ; MOVE.L (use first nib)                0010 0000 0000 0000
    ;Mode values
CONST_DATA_REG_MD       EQU         $00      ; Data register mode:     Dn            XXXX X000
CONST_ADDR_REG_MD       EQU         $01      ; Address register mode:  An            XXXX X001
CONST_ADDR_IND_MD       EQU         $02      ; Address indirect mode:  (An)          XXXX X010
CONST_ADDR_INCR_MD      EQU         $03      ; Address postincr. mode: (An)+         XXXX X011
CONST_ADDR_DECR_MD      EQU         $04      ; Address predecr. mode:  -(An)         XXXX X100
CONST_ADDR_DISPLC_MD    EQU         $05      ; Address w/ displacement:(d16,An)      XXXX X101
CONST_ADDR_INDEX_MD     EQU         $06      ; Address w/ index:       (d8,PC,Xn)    XXXX X110
CONST_ADDR_MISC_MD      EQU         $07      ; Various other addressing modes        XXXX X111
     ;Constant register values (should not be necessary for register numbers like D5)
CONST_COUNTR_DISPLC_REG EQU         $02      ; Counter w/ displacement:(d16,PC)      XXXX X010
CONST_COUNTR_INDEX_REG  EQU         $03      ; Counter w/ index:       (d16,PC,Xn)   XXXX X011
CONST_ABS_SHORT_REG     EQU         $00      ; Absolute word:          (xxx).W       XXXX X000
CONST_ABS_LONG_REG      EQU         $01      ; Absolute long:          (xxx).L       XXXX X001
CONST_IMMEDIATE_REG     EQU         $04      ; Immediate data:         #imm          XXXX X100

*full OPcode contstants
RESET_CODE              EQU         $4E70   ; RESET                                 0100 1110 0111 0001
NOP_CODE                EQU         $4E71   ; NOP                                   0100 1110 0111 0001
STOP_CODE               EQU         $4E72   ; STOP                                  0100 1110 0111 0010

  
*############# END VARIABLES/CONSTANTS #########################

    END START        ; last line of source, very end of the program



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
