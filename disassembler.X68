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
                        
                        ;MOVE.L      #$DEADBEEF,$7000

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
                        
BEGIN_READ              MOVE.W      (A5)+,CURRENT_WORD ;look at the first instruction word at the starting address.
                        BSR         PREPARE_DISPLAY
                        ;CLR         D3
                        ;MOVE.W      CURRENT_WORD,D3

*------------------- Add to display buffer -------------------
;At this point A5 is a valid start address and A6 is a valid end address.
;TODO: prepare the display buffer
PREPARE_DISPLAY         BSR          READ_CURRENT_OP    ;TEMP (though we might still call this after the display buffer is prepared)                       
                        JMP         STOP
                        
                        

*------------------- Move address pointer for data reading -------------------
*------------------- Print display buffer -------------------
*------------------- Check if end of data -------------------
*------------------- Ask user for input -------------------


*################## END IO  #####################################
*################## BEGIN OPCODE ##########################
*** OPcode Subroutines are kept here ***

*------------------- Read current OPcode -------------------
READ_CURRENT_OP         BSR         CHECK_CONSTANTS
                        ;CLR         D3  
                        ;CLR         D4
                        ;;MOVE.W      CURRENT_WORD,D3 ; By this point, the current word should store a potential beginning of an instruction     
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
                
                        MOVE.L      #NEXT_ADDR,D1 ;display the address NOP was found at
                        MOVE.B      #16,D2
                        MOVE.B      #15,D0
                        TRAP        #15

                        LEA         SPACE,A1      ; ' '
                        MOVE.B      #14,D0      
                        TRAP        #15

                        LEA         NOP_MSG,A1    ; 'NOP'
                        MOVE.B      #14,D0
                        TRAP        #15
                
                        MOVE.B      #9,D0         ; terminate the program
                        TRAP        #15
                        JMP         STOP          ; quit the program (TODO: once this works, keep reading instead.)
                        
CHECK_STOP              CMP         #STOP_CODE,(CURRENT_WORD)
                        BNE         CHECK_NON_CONSTANTS

STOP_FOUND              JMP         STOP  ;TODO: case for stop found               

;TODO: add cases for rest of valid constant OPcodes

*----------------- Check current word for non-constants---------
;NOTE: we currently know that CURRENT_WORD is not a constant by the time we reach this SR.

CHECK_NON_CONSTANTS     JMP         STOP    ;TODO: CURRENT_WORD still holds current possible 16 bit instruction, so read it for current word.        

                       

                                                            
                ;MOVE.W      NEXT_ADDR,D4    ;this would be a good place to postincrement.
                ;CMP.W       #NOP_CODE,D4
                ;BEQ         NOP_FOUND
                
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


*###################### END EA ##################################
*############# BEGIN VARIABLES/CONSTANTS #########################
*** Variables and Constants are kept here ***

*output characters
CR                      EQU         $0D
LF                      EQU         $0A
RETURN                  DC.B        CR,LF,0
SPACE                   DC.B        ' ',0
DOLLAR                  DC.B        '$',0

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

*output instruction names
RESET_MSG               DC.B        'RESET',0
NOP_MSG                 DC.B        'NOP',0
STOP_MSG                DC.B        'STOP',0

*storage locations for input
START_ADDR_IN           DS.B        20

*other I/O-related variables/constants
INPUTTING_START         SET         1 ;if 1, we are inputting start address. If 0, we are inputting end address.
DISPLAY_BUFFER          DS.W        5
CURRENT_WORD            DS.W        1 ;current first 16 bits of an instruction.

*address constants
MIN_ADDRESS             EQU         $00003000
MAX_ADDRESS             EQU         $0FFF0000

*address variables
TEST_ORIGIN             SET         $00007000
NEXT_ADDR               SET         TEST_ORIGIN
END_ADDR                SET         $00009000

*filters for isolating parts of a hexa instruction.
*To filter an instruction, ANDI it with the desired filter.
FILT_2BIT_1             EQU         $C000   ;first 2 bits:              XX00 0000 0000 0000
FILT_NIB_1              EQU         $F000   ;first nibble:              XXXX 0000 0000 0000
FILT_MOVE_SIZE          EQU         $3000   ;Size of a move operation:  00XX 0000 0000 0000
FILT_DEST_REG           EQU         $0E00   ;destination register:      0000 XXX0 0000 0000
FILT_DEST_MD            EQU         $01A0   ;destination mode:          0000 000X XX00 0000
FILT_SRC_MD             EQU         $0038   ;source mode:               0000 0000 00XX X000
FILT_SRC_REG            EQU         $0007   ;source register:           0000 0000 0000 0XXX

*constants for comparing with filtered instructions.
CONST_ALL_0             EQU         $0000   ;all 0s:                    0000 0000 0000 0000

*full OPcode contstants
RESET_CODE              EQU         $4E70   ;                           0100 1110 0111 0001
NOP_CODE                EQU         $4E71   ;                           0100 1110 0111 0001
STOP_CODE               EQU         $4E72   ;                           0100 1110 0111 0010

  
*############# END VARIABLES/CONSTANTS #########################

    END START        ; last line of source, very end of the program



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
