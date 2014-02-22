<<<<<<< HEAD
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
*################ TODO LIST ################################
*----------------OPcode TODOS (ROBERT)-----------------------------
*
* Fix the current bugs with MOVEs performed on absolute addresses. Not sure why these errors occur.
*   -consult the bug report before trying to debug.
* Continue decoding OPcodes in the following order: (with sizes)
*   NOTE: I will delete OPcodes from this list as I implement them.

*   -MOVEM  (W,L)
*   -ADD    (B,W,L) (will need shahin's size filter for this and below)
*   -ADDA   (W,L)
*   -ADDI   (B,W,L)
*   -SUB    (B,W,L)
*   -SUBA   (W,L)
*   -SUBQ   (B,W,L)
*   -MULS   (W)     (not MULU?)
*   -DIVU   (W      (not DIVU?)
*   -LEA    (?)
*   -CLR    (B,W,L)
*   -AND    (B,W,L)
*   -ANDI   (B,W,L)
*   -EOR    (B,W,L)
*   -EORI   (B,W,L)
*   -ASR    (B,W,L) (no ASL?)
*   -LSL    (B,W,L) (no LSR?)
*   -ROL    (B,W,L)
*   -ROR    (B,W,L)
*   -BCHG   (?)
*   -CMP    (B,W,L)
*   -CMPA   (W,L)
*   -CMPI   (B,W,L)
*   -JSR    (N/A)
*   (add others if we have time)
*
*----------------I/O TODOS (DANIELLE)-----------------------------
* (TODOs for I/O go here.)
*----------------EA TODOS  (SHAHIN)-----------------------------
* (TODOs for EA go here.)
*################ BEGIN MAIN ###############################
*** All subroutine calls are made here ***
START                   ORG        $1000       ; first instruction of program
                        BRA        PROMPT_INPUT            ; prompt the user for input
                 
STOP                    STOP       #$2700          ; halt simulator, end of main

*################ END MAIN ###############################
*################ BEGIN IO ###############################
*** IO Subroutines are kept here ***

*-------------------- Print ASCII logo ----------------------
PROMPT_INPUT            BRA         TAKE_USER_IN_S ;TODO: change to welcome/ASCII logo
*------------------- Prompt user for input -------------------

                
TAKE_USER_IN_S          MOVE.B      #1,D3
                        LEA         START_ADDR_MSG,A1  ; Prompt user for starting address
                        MOVE.B      #14,D0
                        TRAP        #15

                        BRA         TAKE_USER_INPUT

TAKE_USER_IN_E          MOVE.B      #0,D3
                        LEA         END_ADDR_MSG,A1  ; prompt user for ending address
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        BRA         TAKE_USER_INPUT
                        
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
                        
                        BRA         TAKE_USER_INPUT
                        
INVALID_END_ADDR        LEA         INVALID_END_ADDR_MSG,A1
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        BRA         TAKE_USER_INPUT
                        
INVALID_ADDR_LOW        LEA         INVALID_ADDR_L_MSG,A1    ;tell the user the address was invalid and prompt input again.
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        BRA         TAKE_USER_INPUT

INVALID_ADDR_HIGH       LEA         INVALID_ADDR_H_MSG,A1    ;tell the user the address was invalid and prompt input again.
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        BRA         TAKE_USER_INPUT
               
CONVERSION_DONE         LSL.L       #8,D7   ; Prepare for concatenation
                        LSL.L       #8,D7   ; Got to perform the same operation twice to get it all the way to the left
                        ADD.W       D6,D7  ; concatenate the two data registers into one value
                        
                        CMP.L       #MIN_ADDRESS,D7
                        BLT         INVALID_ADDR_LOW ;Not a valid address-- too low.
                        
                        CMP.L       #MAX_ADDRESS,D7
                        BGT         INVALID_ADDR_HIGH  ;Not a valid address-- too high.
                        
VALID_ADDR              CMPI        #1,D3
                        
                        BEQ         SET_START_ADDR
                        BRA         SET_END_ADDR              
                                               
SET_START_ADDR          MOVEA.L     D7,A5  ;when a valid start address is inputted, store and ask the user for an end address.
                        BRA         TAKE_USER_IN_E

SET_END_ADDR            CMP.L       A5,D7    ;if end address is lower than start address, we get an error.
                        BLT         INVALID_END_ADDR           
                        
                        MOVEA.L     D7,A6  ;when a valid start address is inputted, store and ask the user for an end address.
                        BRA         BEGIN_READ
                        
BEGIN_READ              MOVEA.L      A5,A4 ; keep track of address to print with A4. TODO: could also add this value to the display buffer.
                        MOVE.W      (A5)+,CURRENT_WORD ;look at the first instruction word at the starting address.
                        BRA         PREPARE_DISPLAY

*------------------- Add to display buffer -------------------
;At this point A5 is a valid start address and A6 is a valid end address.
;TODO: prepare the display buffer
PREPARE_DISPLAY         BRA         READ_CURRENT_OP    ;TEMP (though we might still call this after the display buffer is prepared)                       
               
*------------------- Move address pointer for data reading -------------------
; This method is specifically for reading the next OPword.
GO_TO_NEXT_OP           BRA         CHECK_DONE_READING
                         
CONFIRMED_NEXT_OP       CLR         CURRENT_WORD
                        MOVEA.L     A5,A4 ; keep track of address to print with A4. 
                        MOVE.W      (A5)+,CURRENT_WORD
                        BRA         READ_CURRENT_OP
                        
*------------------- Print display buffer -------------------

;TODO

*------------------- Check if end of data -------------------
CHECK_DONE_READING      CMPA        A6,A5       ; TODO: this comparison is not sufficient, because it will say that $8000 is less than $7000 (since $8000 is negative.)
                        BLT         CONFIRMED_NEXT_OP
                        BRA         DONE_READING
                        
*------------------- Confirm end of data -------------------
DONE_READING            LEA         DONE_READING_MSG,A1 ; when we reach the end address, say so and halt the program. TODO: ask user whether we want to read the data again.
                        MOVE.B      #14,D0
                        TRAP        #15
                        JMP         STOP
                        
*################## END IO  #####################################
*################## BEGIN OPCODE ##########################
*** OPcode Subroutines are kept here ***

; planned process for reading hex instructions:
        ; NOTE: this process is tentative and subject to change as OPcode person implements. 
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

*------------------- Read current OPcode -------------------
; By this point, CURRENT_WORD should store a potential beginning of an instruction, so we should not increment A5.
READ_CURRENT_OP         BRA         CHECK_CONSTANTS
                        
  
*------------------- Display current address we are reading -------------------
DISPLAY_CURRENT_ADDRESS LEA         DOLLAR,A1       ; '$'
                        MOVE.B      #14,D0
                        TRAP        #15
                
                        MOVE.L      A4,D1           ; display the address the instruction was found at
                        MOVE.B      #16,D2
                        MOVE.B      #15,D0
                        TRAP        #15

                        LEA         SPACE,A1        ; ' '
                        MOVE.B      #14,D0      
                        TRAP        #15     
                        
                        RTS
 
*------------------ Check current word for constants---------
; By this point, the current word should store a potential beginning of an instruction.                   
CHECK_CONSTANTS         CMP         #RESET_CODE,(CURRENT_WORD)
                        BEQ         RESET_FOUND
                        CMP         #NOP_CODE,(CURRENT_WORD)
                        BEQ         NOP_FOUND
                        CMP         #STOP_CODE,(CURRENT_WORD)
                        BEQ         STOP_FOUND
                        BRA         CHECK_NON_CONSTANTS     ;Once we rule out all the constants we know of, we check for non-constants.

; TODO: change the structure of these subroutines to be like the nice structure used in EA SRs.
                       
RESET_FOUND             BSR         DISPLAY_CURRENT_ADDRESS

                        LEA         RESET_MSG,A1    ; 'RESET'
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        LEA         RETURN,A1       ; (return)
                        MOVE.B      #14,D0
                        TRAP        #15
               
                        BRA         GO_TO_NEXT_OP   
 
; NOTE: this SR is temporary. Once we have the display buffer, it will work differently.                 
NOP_FOUND               BSR         DISPLAY_CURRENT_ADDRESS

                        LEA         NOP_MSG,A1    ; 'NOP'
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        LEA         RETURN,A1     ; (return)
                        MOVE.B      #14,D0
                        TRAP        #15
               
                        BRA         GO_TO_NEXT_OP   ; when we are done parsing and displaying the NOP instruction, go to the next OPcode.

STOP_FOUND              JMP         STOP  ;TODO: case for stop found. (NOTE that STOP instructions have additional data.)               

;TODO: add cases for rest of valid constant OPcodes here

*----------------- Check current word for non-constants---------
;NOTE: we currently know that CURRENT_WORD is not a constant by the time we reach this SR.

CHECK_NON_CONSTANTS     BSR         CHECK_MOVE        ; MOVE is a special case because of how its first nibble is structured.     
                        BSR         CHECK_MOVEQ       ; MOVEQ is also a special case.
                        BSR         CHECK_EXT         ; need to rule out EXT before checking MOVEM, because they have very similar OPcodes.
                        BSR         CHECK_MOVEM      
                        BSR         CHECK_NIB1_0000 
                        BSR         CHECK_NIB1_0100 
                        
                        ; TODO: BSR to checks for other special cases, along with nibbles.
                        
                        ;NOTE: we do not check for most specific instructions here.

                        ; TODO: go into the subroutines below and *fully* implement the followings:
                        *   -MOVEM  (W,L)
                        *   -ADD    (B,W,L) (will need shahin's size filter for this and below)
                        *   -ADDA   (W,L)
                        *   -ADDI   (B,W,L)
                        *   -SUB    (B,W,L)
                        ;etc
                        JMP         STOP
                        ;TODO: check for other instructions instead of stopping if it's not one of these.
  
*-----------------------First 4bit checks go here-----------------------------------
  
*-----------------------Check if the current word starts with 0000--------------------
CHECK_NIB1_0000         CLR         D3
                        MOVE.W      CURRENT_WORD,D3
                        ANDI.W      #FILT_NIB_1,D3  ; filter out the first 4 bits of the word
                        CMP         #CONST_ALL_0,D3 ; see if they are all 0
                        BEQ         CONFIRM_NIB1_0000
                        RTS 
                        
CHECK_NIB1_0100         CLR         D3 
                        MOVE.W      CURRENT_WORD,D3
                        ANDI.W      #FILT_NIB_1,D3      ; filter out the first 4 bits of the word
                        CMP         #CONST_NIB1_0100,D3 ; see if they are 0100
                        BEQ         CONFIRM_NIB1_0100
                        RTS                        
                        
*-----------------------First 4bit confirms go here--------------------------------------

*-----------------------Cases where the current word starts with 0000--------------------                       
CONFIRM_NIB1_0000       CLR         D3
                        MOVE.W      CURRENT_WORD,D3
                        ANDI.W      #FILT_BIT_8,D3  ; turn word into 0000 000X 0000 0000
                        LSR.W       #8,D3           ; turn word into 0000 0000 0000 000X
                        CMP         #CONST_ALL_0,D3 ; see if the word is still 0.
                        BEQ         CONFIRM_0000_XXX0
                        ; if we get to here, then the word must be BCHG, BCLR, BSET, or MOVEP.
                        ; BCHG is required
                        ; if our disassembler doesn't consider any of those valid, there should be an error message here.
                        RTS 
                        
; at this point, the word is of the form 0000 XXX0...
CONFIRM_0000_XXX0       CLR         D3
                        MOVE.W      CURRENT_WORD,D3
                        ANDI.W      #FILT_DEST_REG,D3  ; turn word into 0000 XXX0 0000 0000          
                        
                        ; now figure out which operation we have: (note that constants have been ruled out by this point)
                        
                        CMP         #CONST_ORI_DEST_REG,D3  ; ORI 
                        BEQ         ORI_FOUND           
                        
                        CMP         #CONST_ANDI_DEST_REG,D3 ; ANDI 
                        BEQ         ANDI_FOUND
                        
                        CMP         #CONST_SUBI_DEST_REG,D3 ; SUBI
                        BEQ         SUBI_FOUND
                        ;
                        CMP         #CONST_ADDI_DEST_REG,D3 ; ADDI
                        BEQ         ADDI_FOUND
                        
                        CMP         #CONST_EORI_DEST_REG,D3 ; EORI
                        BEQ         EORI_FOUND
                        
                        CMP         #CONST_CMPI_DEST_REG,D3 ; CMPI
                        BEQ         CMPI_FOUND
                        
                        ;TODO: remaining: BTST, BCHG, BCLR, or BSET. 
                        ;      if none of them, an error case should occur here.
                        ;     (note that BCHG is required, though we don't know which version.)
                        
                        RTS     ;change RTS to whatever branch instruction is appropriate here.
                        
*-----------------------Cases where the current word starts with 0100-----------------

    ; if we were doing every OPcode, would start by checking for MOVE from SR, MOVE to CCR, and MOVE to SR at the top of this SR.
    ; instead, we start with NEGX.
CONFIRM_NIB1_0100       CLR         D3              
                        MOVE.W      CURRENT_WORD,D3
                        ANDI.W      #FILT_BIT_5,D3  ; turn word into 0000 X000 0000 0000
                        LSR.W       #8,D3           ; turn word into 0000 0000 0000 000X
                        LSR.W       #3,D3
                        CMP         #CONST_ALL_0,D3 ; see if the word is still 0.
                        BEQ         CONFIRM_0100_0XXX   ; branch based on the 5th bit.
                        BRA         CONFIRM_0100_1XXX
                        
CONFIRM_0100_0XXX       CLR         D3              
                        MOVE.W      CURRENT_WORD,D3
                        ANDI.W      #FILT_NIB_2,D3  ; turn word into 0000 XXXX 0000 0000
                        
                        ; now figure out which operation we have:
                        
                        CMP         #CONST_NEGX_OP,D3
                        BEQ         NEGX_FOUND
                        
                        CMP         #CONST_CLR_OP,D3
                        BEQ         CLR_FOUND
                        
                        CMP         #CONST_NEG_OP,D3
                        BEQ         NEG_FOUND
                        
                        CMP         #CONST_NOT_OP,D3
                        BEQ         NOT_FOUND         ; note that we could likely make a conflicting SR name with one.
                        
                        ; TODO: we definitely have an error at this point.
                        
                        JMP         STOP     ;change STOP to whatever we want based on error. (probably some error case which will then branch to reading next OPcode.)
                        
CONFIRM_0100_1XXX       CLR         D3
                        MOVE.W      CURRENT_WORD,D3
                        ANDI.W      #FILT_NIB_2,D3  ; turn word into 0000 XXXX 0000 0000
                        
                        CMP         #CONST_NIB2_1000,D3
                        BEQ         CONFIRM_0100_1000

                        CMP         #CONST_NIB2_1010,D3
                        BEQ         CONFIRM_0100_1010 

                        CMP         #CONST_NIB2_1110,D3
                        BEQ         CONFIRM_0100_1110 
                        ; TODO: make MOVEM a special case since it has an unusual OPcode.
                        ; TODO: remaining possibilities are MOVEM, LEA, or CHK. (the first two are required.)

                        JMP         STOP                      
                   
CONFIRM_0100_1000       JMP         STOP                       
; TODO: check for EXT, NBCD, SWAP, or PEA.               
 
CONFIRM_0100_1010       JMP         STOP  
; TODO: check for TAS or TST. (ILLEGAL is already ruled out.)         
       
CONFIRM_0100_1110       JMP         STOP       
; TODO: check for TRAP, LINK, UNLK, MOVE USP, JSR, or JMP. (some of these are required.)

*-----------------------Cases where the current word starts with 0101-----------------
    ;TODO: ADDQ, SUBQ, Scc, DBcc (some of these are required)
 
*-----------------------Cases where the current word starts with 0110-----------------
    ;TODO: BRA, BSR, Bcc (some of these are required)   
    
*-----------------------Cases where the current word starts with 1000-----------------
    ;TODO: DIVU, DIVS, SBCD, OR (some of these are required)   
    
*-----------------------Cases where the current word starts with 1001-----------------
    ;TODO: SUB, SUBX, SUBA (some of these are required) 
 
*-----------------------Cases where the current word starts with 1011-----------------
    ;TODO: EOR, CMPM, CMP, CMPA (some of these are required)  
    
*-----------------------Cases where the current word starts with 1100-----------------
    ;TODO: MULU, MULS, ABCD, EXG, AND (some of these are required) 
    
*-----------------------Cases where the current word starts with 1101-----------------
    ;TODO: ADD, ADDX, ADDA (some of these are required) 
    
*-----------------------Cases where the current word starts with 1110-----------------
    ;TODO: ASR, ASL, LSR, LSL, ROXR, ROXL, ROR, ROL (these are all repeated twice on the sheet for some reason) 
                                                    ;(some of these are required) 
 
*-----------------------Special OPcode (but not constants) have checks here------------
* includes MOVE, MOVEQ, etc
                                
*-----------------------Check current word for MOVE------------------------------------
*MOVE can be B,W, or L.
CHECK_MOVE              CLR         D3
                        MOVE.W      CURRENT_WORD,D3
                        ANDI.W      #FILT_NIB_1,D3
                        CMP         #CONST_MOVE_B,D3
                        BEQ         MOVE_B_FOUND
                        CMP         #CONST_MOVE_W,D3
                        BEQ         MOVE_W_FOUND
                        CMP         #CONST_MOVE_L,D3
                        BEQ         MOVE_L_FOUND
                        RTS 
                        
*-----------------------Check current word for MOVEQ------------------------------------
*MOVEQ can only be L.                       
CHECK_MOVEQ             CLR         D3
                        MOVE.W      CURRENT_WORD,D3
                        ANDI.W      #FILT_NIB_1,D3
                        CMP         #CONST_MOVEQ,D3
                        BEQ         MOVEQ_FOUND
                        RTS 
                        

*-----------------------Check current word for EXT------------------------------------  
*check EXT before MOVEM, since they can be easily confused.
*EXT can be W or L.                  
CHECK_EXT               CLR         D3                  
                        MOVE.W      CURRENT_WORD,D3
                        ANDI.W      #FILT_EXT,D3
                        CMP         #CONST_EXT,D3
                        BEQ         EXT_FOUND
                        RTS 
                        
*-----------------------Check current word for MOVEM------------------------------------  
*MOVEM can be W or L.                  
CHECK_MOVEM             CLR         D3                         
                        MOVE.W      CURRENT_WORD,D3
                        ANDI.W      #FILT_MOVEM,D3
                        CMP         #CONST_MOVEM,D3
                        BEQ         MOVEM_FOUND
                        RTS 
                        
*---------------------- END OPWORD CHECKS -----------------------------------------

*---------------------- BEGIN CASES FOR FOUND OPCODES------------------------------

*-----------------------MOVE-related Subroutines------------------------------------

*-----------------------Cases for finding different MOVE OPcodes------------------------------------
*MOVE.B
MOVE_B_FOUND            MOVE.B      #BYTE_SIZE,CURRENT_OP_SIZE
                        BSR         DISPLAY_CURRENT_ADDRESS
                        BSR         PARSE_MOVE_DATA                           
                       
                        LEA         MOVE_B_MSG,A1      ; 'MOVE.B'
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        LEA         SPACE,A1           ; ' '
                        MOVE.B      #14,D0      
                        TRAP        #15
                        
                        BSR         DISPLAY_MOVE_DATA
                        BRA         GO_TO_NEXT_OP

*MOVE.W                        
MOVE_W_FOUND            MOVE.B      #WORD_SIZE,CURRENT_OP_SIZE
                        BSR         DISPLAY_CURRENT_ADDRESS
                        BSR         PARSE_MOVE_DATA       
                        
                        LEA         MOVE_W_MSG,A1      ; 'MOVE.W'
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        LEA         SPACE,A1           ; ' '
                        MOVE.B      #14,D0      
                        TRAP        #15
                        
                        BSR         DISPLAY_MOVE_DATA
                        BRA         GO_TO_NEXT_OP  

*MOVE.L                        
MOVE_L_FOUND            MOVE.B      #LONG_SIZE,CURRENT_OP_SIZE
                        BSR         DISPLAY_CURRENT_ADDRESS
                        BSR         PARSE_MOVE_DATA       
                        
                        LEA         MOVE_L_MSG,A1      ; 'MOVE.L'
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        LEA         SPACE,A1           ; ' '
                        MOVE.B      #14,D0      
                        TRAP        #15
                        
                        BSR         DISPLAY_MOVE_DATA
                        BRA         GO_TO_NEXT_OP 
                       
*-----------------------Parse data for any-sized MOVE instruction---------------------
*Note that the size of the MOVE is stored in CURRENT_OP_SIZE.
PARSE_MOVE_DATA         ; TODO: error checking 
                        ;(maybe after reading the first 4 instruction parts, but before reading additional data)
                        ;IMPORTANT: remember that different MOVE error are specific to different MOVE sizes.
                        ; example: MOVE.B  A0,D3 is invalid. However, MOVE.W  A0,D3 is valid.
                        ;
                        ; possible errors:
                        ;       CURRENT_DEST_MD = CONST_IMMEDIATE_REG (immediate data cannot be a destination)
                        ;       CURRENT_SRC_MD  = CONST_ADDR_REG_MD   (byte is not a valid size for this move)
                        ;       CURRENT_DEST_MD = CONST_ADDR_REG_MD   (byte is not a valid size, although we should be using MOVEA at this point, not MOVE.)
                        ;       TODO: figure out other possible errors.
                        
                        ; after we confirm that there are no errors, we know that we can safely check for additional data and display the instruction.
                        
                        
                        ; at this point, need to read more information (parsed by EA, probably)
                        ; now that we have a move instruction, we set our EA variables accordingly:
                        BSR         READ_DEST_REG      ; EA will set CURRENT_DEST_REG.
                        BSR         READ_DEST_MODE     ; EA will set CURRENT_DEST_MD.
                        BSR         READ_SOURCE_MODE   ; EA will set CURRENT_SRC_MD.
                        BSR         READ_SOURCE_REG    ; EA will set CURRENT_SRC_REG.
                        
                        ; need to check whether we need to read additional data before we start displaying the
                        ; instruction (for instance, this is necessary for MOVE.B #10,D0).
                        BSR         READ_SOURCE_DATA   ; EA will set CURRENT_SOURCE_DATA if necessary.
                        BSR         READ_DEST_DATA     ; EA will set CURRENT_DEST_DATA if necessary. 
                        RTS         

DISPLAY_MOVE_DATA       BSR         DISPLAY_SOURCE     ; Tell EA to parse and display the source. EX: (A1)   D3    #10   $1000 etc
                        
                        LEA         COMMA,A1           ; ','
                        MOVE.B      #14,D0      
                        TRAP        #15
                        
                        BSR         DISPLAY_DEST       ; Tell EA to parse and display the destination.
                        
                        LEA         RETURN,A1          ; (return)
                        MOVE.B      #14,D0
                        TRAP        #15

                        RTS  

*-----------------------MOVEQ-related Subroutines------------------------------------

*-----------------------Case for finding MOVEQ------------------------------------
MOVEQ_FOUND             MOVE.B      #LONG_SIZE,CURRENT_OP_SIZE
                        BSR         DISPLAY_CURRENT_ADDRESS
                        BSR         PARSE_MOVEQ_DATA       
                        
                        LEA         MOVEQ_MSG,A1      ; 'MOVEQ'
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        LEA         SPACE,A1           ; ' '
                        MOVE.B      #14,D0      
                        TRAP        #15
                        
                        BSR         DISPLAY_MOVEQ_DATA
                        BRA         GO_TO_NEXT_OP  

PARSE_MOVEQ_DATA        ;TODO: check that 0000 000X 0000 0000 equals zero. If not, error.
                        
                        BSR         READ_DEST_REG                       ; EA will set CURRENT_DEST_REG.
                        MOVE.B      #CONST_DATA_REG_MD,CURRENT_DEST_MD  ; data register is the only allowed destination for MOVEQ.
                        BSR         READ_MOVEQ_DATA                     ; 0000 0000 XXXX XXXX will set CURRENT_SOURCE_DATA (I think.)
                        
                        MOVE.B      #CONST_ADDR_MISC_MD,CURRENT_SRC_MD
                        MOVE.B      #CONST_IMMEDIATE_REG,CURRENT_SRC_REG
                        
                        RTS 

DISPLAY_MOVEQ_DATA      BSR         DISPLAY_SOURCE     ; Tell EA to parse and display the source. 
                        
                        LEA         COMMA,A1           ; ','
                        MOVE.B      #14,D0      
                        TRAP        #15
                        
                        BSR         DISPLAY_DEST       ; Tell EA to parse and display the destination.
                        
                        LEA         RETURN,A1          ; (return)
                        MOVE.B      #14,D0
                        TRAP        #15

                        RTS        

;NOTE: this SR is stored here and not in EA because it is specific to MOVEQ.
READ_MOVEQ_DATA         CLR         D4
                        CLR         CURRENT_SRC_DATA
                        MOVE.W      CURRENT_WORD,D4
                        ANDI.W      #FILT_MOVEQ_DATA,D4        ; turn D4 into 0000 0000 XXXX XXXX (no shift necessary)
                        MOVE.W      D4,CURRENT_SRC_DATA
                        RTS
                    
  ; TODO: (in order)
    *   -MOVEM  (W,L)
    *   -ADD    (B,W,L) (will need shahin's size filter for this and below)
    *   -ADDA   (W,L)
    *   -ADDI   (B,W,L)
    *   -SUB    (B,W,L)
  ; see comment block at the top of the program for the full list of codes.
  ; see huge comment block at the top of OPcode section for tentative OPcode parsing implementation plan.
  
*-----------------------EXT-related Subroutines------------------------------------
EXT_FOUND               JMP         STOP ;TODO: case for EXT found

;TODO: first thing: read the correct size for MOVEM
*-----------------------MOVEM-related Subroutines------------------------------------
MOVEM_FOUND             ; TODO: filter out size and set CURRENT_OP_SIZE accordingly
                        JMP         STOP ;TODO: case for MOVEM found (currently the next goal)      
  
*-----------------------ORI-related Subroutines------------------------------------
ORI_FOUND               JMP         STOP ;TODO: case for ORI found

 *----------------------ANDI-related Subroutines------------------------------------
ANDI_FOUND              JMP         STOP ;TODO: case for ANDI found

 *----------------------SUBI-related Subroutines------------------------------------
SUBI_FOUND              JMP         STOP ;TODO: case for SUBI found

 *----------------------ADDI-related Subroutines------------------------------------
ADDI_FOUND              JMP         STOP ;TODO: case for ADDI found
 
*-----------------------EORI-related Subroutines------------------------------------
EORI_FOUND              JMP         STOP ;TODO: case for EORI found
 
*-----------------------CMPI-related Subroutines------------------------------------
CMPI_FOUND              JMP         STOP ;TODO: case for CMPI found

*-----------------------NEGX-related Subroutines------------------------------------
NEGX_FOUND              JMP         STOP ;TODO: case for NEGX found 

*-----------------------CLR-related Subroutines------------------------------------
CLR_FOUND               JMP         STOP ;TODO: case for CLR found 

*-----------------------NEG-related Subroutines------------------------------------
NEG_FOUND               JMP         STOP ;TODO: case for NEG found 

*-----------------------NOT-related Subroutines------------------------------------
NOT_FOUND               JMP         STOP ;TODO: case for NOT found 
                    
*###################### END OPCODE ##################################
*###################### BEGIN EA ##################################
*** EA Subroutines are kept here ***
*----------------------Check the destination register of the current word.-------------
READ_DEST_REG           CLR         D4
                        CLR.B       CURRENT_DEST_REG
                        MOVE.W      CURRENT_WORD,D4
                        ANDI.W      #FILT_DEST_REG,D4       ; turn D4 into 0000 XXX0 0000 0000
                        LSR.W       #8,D4                   ; turn D4 into 0000 0000 0000 0XXX
                        LSR.W       #1,D4                   ; 9 would be invalid, so we shift 8, then 1
                        MOVE.B      D4,CURRENT_DEST_REG
                        RTS

*----------------------Check the destination mode of the current word.-------------
*(assuming the destination is where it would be in MOVE).
READ_DEST_MODE          CLR         D4
                        CLR.B       CURRENT_DEST_MD
                        MOVE.W      CURRENT_WORD,D4
                        ANDI.W      #FILT_DEST_MD,D4        ; turn D4 into 0000 000X XX00 0000
                        LSR.W       #6,D4                   ; turn D4 into 0000 0000 0000 0XXX
                        MOVE.B      D4,CURRENT_DEST_MD
                        RTS

;By this point, CURRENT WORD holds the first 16 bits of an instruction we are looking at.
;(we should already know the OPcode by this point, so this will be called by various OPcode subroutines.)
*---------------------- Check the source mode of the current word.--------------------
*(assuming the source is where it would be in MOVE).
READ_SOURCE_MODE        CLR         D4
                        CLR.B       CURRENT_SRC_MD
                        MOVE.W      CURRENT_WORD,D4
                        ANDI.W      #FILT_SRC_MD,D4                 ; turn source mode into 0000 0000 00XX X000
                        LSR.W       #3,D4                           ; turn source mode into 0000 0000 0000 0XXX
                        MOVE.B      D4,CURRENT_SRC_MD
                        RTS
                        
*----------------------Check the source register of the current word.-----------------
READ_SOURCE_REG         CLR         D4
                        CLR.B       CURRENT_SRC_REG
                        MOVE.W      CURRENT_WORD,D4
                        ANDI.W      #FILT_SRC_REG,D4        ; turn D4 into 0000 0000 0000 0XXX. (no need for LSR in this case.)
                        MOVE.B      D4,CURRENT_SRC_REG
                        RTS
*--------TODO: READ_OP_SIZE---------
                       
*----------------------Read additional source data associated with the current word (if necessary).----------------- 
*This needs to postincrement A5 as necessary.
READ_SOURCE_DATA        CLR         CURRENT_SRC_DATA
                        CLR         CURRENT_DATA
                        CMP.B       #CONST_ADDR_MISC_MD,CURRENT_SRC_MD ; check the source mode
                        BEQ         CONFIRM_READ_SRC_DATA              ; see if we have a source mode that requires additional data.               
                        RTS
                        
CONFIRM_READ_SRC_DATA   CLR.B       CURRENT_REG
                        MOVE.B      CURRENT_SRC_REG,CURRENT_REG
                        BSR         CONFIRM_READ_DATA
                        MOVE.L      CURRENT_DATA,CURRENT_SRC_DATA
                        RTS
 
*----------------------Read additional destination data associated with the current word (if necessary).----------------- 
*This needs to postincrement A5 as necessary.                       
READ_DEST_DATA          CLR         CURRENT_DEST_DATA
                        CLR         CURRENT_DATA
                        CMP.B       #CONST_ADDR_MISC_MD,CURRENT_DEST_MD  ; check the destination mode.
                        BEQ         CONFIRM_READ_DEST_DATA               ; see if we have a destination mode that requires additional data.                  
                        RTS
                                            
CONFIRM_READ_DEST_DATA  CLR.B       CURRENT_REG
                        MOVE.B      CURRENT_DEST_REG,CURRENT_REG
                        BSR         CONFIRM_READ_DATA
                        MOVE.L      CURRENT_DATA,CURRENT_DEST_DATA
                        RTS

*-----------------------Read some additional data.----------------------------------------------------------
      ; This same subroutine is used for reading source and destination data.
      ; By this point, CURRENT_REG holds whatever register we currently care about. (could also use CURRENT_REG)         
CONFIRM_READ_DATA       CMP.B       #CONST_COUNTR_DISPLC_REG,CURRENT_REG      ; see if we are reading counter w/ displacement
                        BEQ         READ_COUNTR_DISPLC_DATA
                   
                        CMP.B       #CONST_COUNTR_INDEX_REG,CURRENT_REG       ; see if we are reading counter w/ index
                        BEQ         READ_COUNTR_INDEX_DATA
                        
                        CMP.B       #CONST_ABS_SHORT_REG,CURRENT_REG          ; see if we are reading absolute short address
                        BEQ         READ_ABS_SHORT_DATA
                        
                        CMP.B       #CONST_ABS_LONG_REG,CURRENT_REG           ; see if we are reading absolute long address
                        BEQ         READ_ABS_LONG_DATA 
                        
                        CMP.B       #CONST_IMMEDIATE_REG,CURRENT_REG          ; see if we are reading immediate data
                        BEQ         READ_IMMEDIATE_DATA
     
                        RTS
                        
; TODO: each of these SRs should increment A5 by the proper amount while also storing the correct data in CURRENT_DATA.
READ_COUNTR_DISPLC_DATA RTS ; TODO: read data for counter w/ displacement (d16,PC)

READ_COUNTR_INDEX_DATA  RTS ; TODO: read data for counter w/ index        (d16,PC,Xn)

*-----------------------Read additional absolute word address---------------------------
READ_ABS_SHORT_DATA     MOVE.W      (A5)+,CURRENT_DATA ; read data for absolute short address  (xxx).W
                        RTS
                        
*-----------------------Read additional absolute long address---------------------------
READ_ABS_LONG_DATA      MOVE.L      (A5)+,CURRENT_DATA ; read data for absolute long address   (xxx).L
                        RTS 

*-----------------------Read additional immediate data---------------------------
READ_IMMEDIATE_DATA     CMP.B       #BYTE_SIZE,CURRENT_OP_SIZE   ; see if we are reading immediate byte data
                        BEQ         READ_IMMEDIATE_DATA_W
                        
                        CMP.B       #WORD_SIZE,CURRENT_OP_SIZE   ; see if we are reading immediate word data
                        BEQ         READ_IMMEDIATE_DATA_W
                        
                        CMP.B       #LONG_SIZE,CURRENT_OP_SIZE   ; see if we are reading immediate long data
                        BEQ         READ_IMMEDIATE_DATA_L
                        ;TODO: error case goes here
                        RTS

READ_IMMEDIATE_DATA_W   CLR         CURRENT_DATA
                        MOVE.W      (A5)+,CURRENT_DATA
                        RTS
                        
READ_IMMEDIATE_DATA_L   CLR         CURRENT_DATA
                        MOVE.L      (A5)+,CURRENT_DATA
                        RTS
                        
*----------------------Display the source for the current instruction.-----------------
*by this point, error checking should already be done and CURRENT_SRC_MD and CURRENT_SRC_REG should have the data we need.
DISPLAY_SOURCE          CLR.B       CURRENT_MD
                        CLR.B       CURRENT_REG
                        CLR.L       CURRENT_DATA
                        
                        MOVE.B      CURRENT_SRC_MD,CURRENT_MD
                        MOVE.B      CURRENT_SRC_REG,CURRENT_REG    
                        MOVE.L      CURRENT_SRC_DATA,CURRENT_DATA
                        BSR         CHECK_ADDRESSING_MODES   
                        RTS  
                        
*----------------------Display the destination for the current instruction.-----------------
*by this point, error checking should already be done and CURRENT_DEST_MD and CURRENT_DEST_REG should have the data we need.
DISPLAY_DEST            CLR.B       CURRENT_MD
                        CLR.B       CURRENT_REG
                        CLR.L       CURRENT_DATA
                        
                        MOVE.B      CURRENT_DEST_MD,CURRENT_MD
                        MOVE.B      CURRENT_DEST_REG,CURRENT_REG    
                        MOVE.L      CURRENT_DEST_DATA,CURRENT_DATA
                        BSR         CHECK_ADDRESSING_MODES     
                        RTS  
                        

                        
*-----------------------Mode checks (for displaying)---------
*these do not care whether the mode is for source or destination.
CHECK_ADDRESSING_MODES  CMP.B       #CONST_DATA_REG_MD,CURRENT_MD   ; check for CURRENT_MD = ...0000
                        BEQ         DISPLAY_DATA_REG
                        CMP.B       #CONST_ADDR_REG_MD,CURRENT_MD    ; check for CURRENT_MD = ...0001
                        BEQ         DISPLAY_ADDR_REG
                        CMP.B       #CONST_ADDR_IND_MD,CURRENT_MD    ; check for CURRENT_MD = ...0010
                        BEQ         DISPLAY_ADDR_IND
                        CMP.B       #CONST_ADDR_INCR_MD,CURRENT_MD   ; check for CURRENT_MD = ...0011
                        BEQ         DISPLAY_ADDR_INCR
                        CMP.B       #CONST_ADDR_DECR_MD,CURRENT_MD   ; check for CURRENT_MD = ...0100
                        BEQ         DISPLAY_ADDR_DECR
                        CMP.B       #CONST_ADDR_DISPLC_MD,CURRENT_MD ; check for CURRENT_MD = ...0101
                        BEQ         DISPLAY_ADDR_DISPLC
                        CMP.B       #CONST_ADDR_INDEX_MD,CURRENT_MD  ; check for CURRENT_MD = ...0110
                        BEQ         DISPLAY_ADDR_INDEX
                        CMP.B       #CONST_ADDR_MISC_MD,CURRENT_MD   ; check for CURRENT_MD = ...0111
                        BEQ         CHECK_MISC_ADDRESSINGS
                        ;TODO: error cases? 
                        RTS

; case for displaying data register.          
DISPLAY_DATA_REG        LEA         MSG_D,A1               ; print out 'D' (later, send this to dislpay buffer)
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        CLR         D1
                        MOVE.B      (CURRENT_REG),D1      ; print out the number of the data register.
                        MOVE.B      #16,D2
                        MOVE.B      #15,D0
                        TRAP        #15
                        
                        RTS

; case for displaying address register. 
DISPLAY_ADDR_REG        LEA         MSG_A,A1               ; print out 'A'
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        CLR         D1
                        MOVE.B      (CURRENT_REG),D1       ; print out the number of the data register.
                        MOVE.B      #16,D2
                        MOVE.B      #15,D0
                        TRAP        #15
                        
                        RTS

; case for displaying address register indirect.                        
DISPLAY_ADDR_IND        LEA         OPEN_PARENS,A1         ; print out '(' (later, send this to dislpay buffer)
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        LEA         MSG_A,A1               ; print out 'A'
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        CLR         D1
                        MOVE.B      (CURRENT_REG),D1      ; print out the number of the data register.
                        MOVE.B      #16,D2
                        MOVE.B      #15,D0
                        TRAP        #15
                        
                        LEA         CLOSE_PARENS,A1       ; print out ')'
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        RTS

; case for displaying address indirect postincrement.
DISPLAY_ADDR_INCR       LEA         OPEN_PARENS,A1        ; print out '(' (later, send this to dislpay buffer)
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        LEA         MSG_A,A1              ; print out 'A'
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        CLR         D1
                        MOVE.B      (CURRENT_REG),D1      ; print out the number of the data register.
                        MOVE.B      #16,D2
                        MOVE.B      #15,D0
                        TRAP        #15
                        
                        LEA         CLOSE_PARENS,A1       ; print out ')'
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        LEA         PLUS,A1               ; print out '+'
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        RTS
                        
; case for displaying address indirect preedecrement mode.
DISPLAY_ADDR_DECR       LEA         MINUS,A1               ; print out '-'
                        MOVE.B      #14,D0
                        TRAP        #15                                           

                        LEA         OPEN_PARENS,A1        ; print out '(' (later, send this to dislpay buffer)
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        LEA         MSG_A,A1              ; print out 'A'
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        CLR         D1
                        MOVE.B      (CURRENT_REG),D1      ; print out the number of the data register.
                        MOVE.B      #16,D2
                        MOVE.B      #15,D0
                        TRAP        #15
                        
                        LEA         CLOSE_PARENS,A1       ; print out ')'
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        RTS     

DISPLAY_ADDR_DISPLC     ;TODO: case for source mode is address with displacement mode.
                        RTS    

DISPLAY_ADDR_INDEX      ;TODO: case for source mode is address with index mode.
                        RTS 

*-----------------------Register checks (for displaying only)---------
*these do not care whether the register is for source or destination.
*not for cases where reg is simply a number (like D5, A5, (A5), etc),
*only for miscellaneous addressings where mode is 111.                        
CHECK_MISC_ADDRESSINGS  CMP.B       #CONST_COUNTR_DISPLC_REG,CURRENT_REG
                        BEQ         DISPLAY_COUNTR_DISPLC
                        
                        CMP.B       #CONST_COUNTR_INDEX_REG,CURRENT_REG
                        BEQ         DISPLAY_COUNTR_INDEX
                        
                        CMP.B       #CONST_ABS_SHORT_REG,CURRENT_REG
                        BEQ         DISPLAY_ABS_SHORT
                        
                        CMP.B       #CONST_ABS_LONG_REG,CURRENT_REG
                        BEQ         DISPLAY_ABS_LONG
                        
                        CMP.B       #CONST_IMMEDIATE_REG,CURRENT_REG
                        BEQ         DISPLAY_IMMEDIATE
                        
                        ; TODO: error case?
                        
                        RTS
                        
DISPLAY_COUNTR_DISPLC   RTS         ;TODO   

DISPLAY_COUNTR_INDEX    RTS         ;TODO   

DISPLAY_ABS_SHORT       LEA         DOLLAR,A1             ; print out '$'. 
                        MOVE.B      #14,D0
                        TRAP        #15

                        CLR         D1
                        MOVE.W      (CURRENT_DATA),D1     ; print out the absolute short address we are concerned with in hex. 
                        MOVE.B      #16,D2
                        MOVE.B      #15,D0
                        TRAP        #15
                        
                        RTS 

DISPLAY_ABS_LONG        LEA         DOLLAR,A1             ; print out '$'. 
                        MOVE.B      #14,D0
                        TRAP        #15

                        CLR         D1
                        MOVE.L      (CURRENT_DATA),D1     ; print out the absolute long address we are concerned with in hex. 
                        MOVE.B      #16,D2
                        MOVE.B      #15,D0
                        TRAP        #15
                        
                        RTS 

DISPLAY_IMMEDIATE       LEA         HASH,A1               ; print out '#'. (NOTE: should send this to display buffer instead.)
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        LEA         DOLLAR,A1             ; print out '$'. (this saves time since we can more easily find the hex value of the immediate data.)
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        MOVE.W      (CURRENT_DATA),D1     ; print out the immediate data we are concerned with in hex. 
                        MOVE.B      #16,D2
                        MOVE.B      #15,D0
                        TRAP        #15
                        
                        RTS
                        
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
OPEN_PARENS             DC.B        '(',0
CLOSE_PARENS            DC.B        ')',0
PLUS                    DC.B        '+',0
MINUS                   DC.B        '-',0

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
    ;sizes
BYTE_SIZE_MSG           DC.B        '.B',0
WORD_SIZE_MSG           DC.B        '.W',0
LONG_SIZE_MSG           DC.B        '.L',0

    ;constants
RESET_MSG               DC.B        'RESET',0
NOP_MSG                 DC.B        'NOP',0
STOP_MSG                DC.B        'STOP',0
    ;moves
MOVE_MSG                DC.B        'MOVE',0
MOVE_B_MSG              DC.B        'MOVE.B',0
MOVE_W_MSG              DC.B        'MOVE.W',0
MOVE_L_MSG              DC.B        'MOVE.L',0

MOVEQ_MSG               DC.B        'MOVEQ',0

*other output instruction message constants
MSG_D                   DC.B        'D',0
MSG_A                   DC.B        'A',0

*storage locations for input
START_ADDR_IN           DS.B        20

*other I/O-related variables/constants
INPUTTING_START         SET         1 ;if 1, we are inputting start address. If 0, we are inputting end address.
OPCODE_BUFFER           DS.L        1 ; can hold at most 4 characters
SIZE_BUFFER             DS.W        1 ;cand hold at most 2 characters
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

*size constants
BYTE_SIZE                EQU         $00 ; 0000 0000
WORD_SIZE                EQU         $01 ; 0000 0001
LONG_SIZE                EQU         $02 ; 0000 0010

BYTE_SIZE_M              EQU         $01 ; 0000 0001
WORD_SIZE_M              EQU         $03 ; 0000 0011
LONG_SIZE_M              EQU         $02 ; 0000 0010

*address constants
MIN_ADDRESS             EQU         $00003000
MAX_ADDRESS             EQU         $0FFF0000

*address variables
TEST_ORIGIN             SET         $00007000
NEXT_ADDR               SET         TEST_ORIGIN
END_ADDR                SET         $00009000

*filters for isolating parts of a hexa instruction. X means 'unknown' and can be 0 or one after ANDI filter.
*To filter an instruction, ANDI it with the desired filter.
*note: I'm not sure if it matters much whether you have the 4 leading 0s in these filters, but I don't want to
*risk changing it. Therefore, some filters have leading 0s and some do not.
    * general filters
FILT_2BIT_1             EQU         $0000C000   ;first 2 bits:                          XX00 0000 0000 0000
FILT_NIB_1              EQU         $0000F000   ;first nibble:                          XXXX 0000 0000 0000
FILT_NIB_2              EQU         $00000F00   ;second nibble:                         0000 XXXX 0000 0000
FILT_BIT_5              EQU         $00000800   ;5th bit:                               0000 X000 0000 0000
FILT_BIT_8              EQU         $00000100   ;8th bit:                               0000 000X 0000 0000

    * source/destination filters (not applicable for bidirectional operations)
FILT_DEST_REG           EQU         $00000E00   ;destination register:                  0000 XXX0 0000 0000
FILT_DEST_MD            EQU         $000001C0   ;destination mode:                      0000 000X XX00 0000
FILT_SRC_MD             EQU         $00000038   ;source mode:                           0000 0000 00XX X000
FILT_SRC_REG            EQU         $00000007   ;source register:                       0000 0000 0000 0XXX

    * move filters
FILT_MOVE_SIZE          EQU         $00003000   ;Size of a move operation:              00XX 0000 0000 0000
FILT_MOVEM              EQU         $FB80       ; check for a MOVEM instruction:        XXXX X0XX X000 0000

    * filters for BRA, BSR, BCC, and MOVEQ (the same filter, but named differently for clarity.)
FILT_DISPLACEMENT       EQU         $00FF       ;Displacment of branch instruction:     0000 0000 XXXX XXXX
FILT_MOVEQ_DATA         EQU         $00FF       ;Data of MOVEQ instruction:             0000 0000 XXXX XXXX

    * EXT filter
FILT_EXT                EQU         $FFB8       ; check for an EXT instruction:         XXXX XXXX X0XX X000

    

* constants for comparing with filtered instructions. X means 'don't care' (and will be set to 0 by previous filter)
*(These do not represent the complete insturctions.)
*(Also note that repetition is allowed for clarity's sake, so two constants can share a value.)
    * general filters
CONST_ALL_0             EQU         $0000    ; all 0s:                               0000 0000 0000 0000
CONST_NIB1_0100         EQU         $4000    ; first nibble is 0100                  0100 XXXX XXXX XXXX
CONST_NIB2_1000         EQU         $0800    ; second nibble is 1000                 XXXX 1000 XXXX XXXX
CONST_NIB2_1010         EQU         $0A00    ; second nibble is 1010                 XXXX 1010 XXXX XXXX
CONST_NIB2_1110         EQU         $0E00    ; second nibble is 1110                 XXXX 1110 XXXX XXXX

* Immediate operation constants
    * ANDI
CONST_ORI_DEST_REG      EQU         $0000    ; confirm ORI                           XXXX 000X XXXX XXXX
    * ANDI
CONST_ANDI_DEST_REG     EQU         $0200    ; confirm ANDI                          XXXX 001X XXXX XXXX
    * SUBI
CONST_SUBI_DEST_REG     EQU         $0400    ; confirm SUBI                          XXXX 010X XXXX XXXX
    * ADDI
CONST_ADDI_DEST_REG     EQU         $0600    ; confirm ADDI                          XXXX 011X XXXX XXXX
    * EORI
CONST_EORI_DEST_REG     EQU         $0A00    ; confirm EORI                          XXXX 101X XXXX XXXX
    * CMPI
CONST_CMPI_DEST_REG     EQU         $0C00    ; confirm CMPI                          XXXX 110X XXXX XXXX

* Constants for matching based on 2nd nibble
    *NEGX
CONST_NEGX_OP           EQU         $0000    ; confirm NEGX                          XXXX 0000 XXXX XXXX
    *CLR
CONST_CLR_OP            EQU         $0200    ; confirm CLR                           XXXX 0010 XXXX XXXX
    *NEG
CONST_NEG_OP            EQU         $0400    ; confirm NEG                           XXXX 0100 XXXX XXXX
    *NOT
CONST_NOT_OP            EQU         $0600    ; confirm NOT                           XXXX 0110 XXXX XXXX

* EXT constant
CONST_EXT               EQU         $4880    ; confirm EXT                           0100 1000 1X00 0XXX

* Other constants
    * BTST,BCHG,BCLR,BSET
CONST_B_OP              EQU         $0800    ; BTST,BCHG,BCLR,BSET                   XXXX 100X XXXX XXXX

    * MOVE
CONST_MOVE_B            EQU         $1000    ; MOVE.B (use first nib)                0001 XXXX XXXX XXXX
CONST_MOVE_W            EQU         $3000    ; MOVE.W (use first nib)                0011 XXXX XXXX XXXX
CONST_MOVE_L            EQU         $2000    ; MOVE.L (use first nib)                0010 XXXX XXXX XXXX

    * MOVEQ
CONST_MOVEQ             EQU         $7000    ; MOVEQ.L (use first nib)               0111 XXXX XXXX XXXX    
         
    * MOVEM                      
CONST_MOVEM             EQU         $8880    ; confirm MOVEM (use FILT_MOVEM)        0100 1X00 1XXX XXXX            
         
* Mode/register constants

    * Mode values
CONST_DATA_REG_MD       EQU         $00      ; Data register mode:     Dn            XXXX X000
CONST_ADDR_REG_MD       EQU         $01      ; Address register mode:  An            XXXX X001
CONST_ADDR_IND_MD       EQU         $02      ; Address indirect mode:  (An)          XXXX X010
CONST_ADDR_INCR_MD      EQU         $03      ; Address postincr. mode: (An)+         XXXX X011
CONST_ADDR_DECR_MD      EQU         $04      ; Address predecr. mode:  -(An)         XXXX X100
CONST_ADDR_DISPLC_MD    EQU         $05      ; Address w/ displacement:(d16,An)      XXXX X101
CONST_ADDR_INDEX_MD     EQU         $06      ; Address w/ index:       (d8,PC,Xn)    XXXX X110
CONST_ADDR_MISC_MD      EQU         $07      ; Various other addressing modes        XXXX X111

    * Constant register values (should not be necessary for register numbers like D5)
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
=======
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
*################ TODO LIST ################################
*----------------OPcode TODOS (ROBERT)-----------------------------
*
* Fix the current bugs with MOVEs performed on absolute addresses. Not sure why these errors occur.
*   -consult the bug report before trying to debug.
* Continue decoding OPcodes in the following order: (with sizes)
*   NOTE: I will delete OPcodes from this list as I implement them.

*   -MOVEM  (W,L)
*   -ADD    (B,W,L) (will need shahin's size filter for this and below)
*   -ADDA   (W,L)
*   -ADDI   (B,W,L)
*   -SUB    (B,W,L)
*   -SUBA   (W,L)
*   -SUBQ   (B,W,L)
*   -MULS   (W)     (not MULU?)
*   -DIVU   (W      (not DIVU?)
*   -LEA    (?)
*   -CLR    (B,W,L)
*   -AND    (B,W,L)
*   -ANDI   (B,W,L)
*   -EOR    (B,W,L)
*   -EORI   (B,W,L)
*   -ASR    (B,W,L) (no ASL?)
*   -LSL    (B,W,L) (no LSR?)
*   -ROL    (B,W,L)
*   -ROR    (B,W,L)
*   -BCHG   (?)
*   -CMP    (B,W,L)
*   -CMPA   (W,L)
*   -CMPI   (B,W,L)
*   -JSR    (N/A)
*   (add others if we have time)
*
*----------------I/O TODOS (DANIELLE)-----------------------------
* (TODOs for I/O go here.)
*----------------EA TODOS  (SHAHIN)-----------------------------
* (TODOs for EA go here.)
*################ BEGIN MAIN ###############################
*** All subroutine calls are made here ***
START                   ORG        $1000       ; first instruction of program
                        BRA        PROMPT_INPUT            ; prompt the user for input
                 
STOP                    STOP       #$2700          ; halt simulator, end of main

*################ END MAIN ###############################
*################ BEGIN IO ###############################
*** IO Subroutines are kept here ***

*-------------------- Print ASCII logo ----------------------
PROMPT_INPUT            BRA         TAKE_USER_IN_S ;TODO: change to welcome/ASCII logo
*------------------- Prompt user for input -------------------

                
TAKE_USER_IN_S          MOVE.B      #1,D3
                        LEA         START_ADDR_MSG,A1  ; Prompt user for starting address
                        MOVE.B      #14,D0
                        TRAP        #15

                        BRA         TAKE_USER_INPUT

TAKE_USER_IN_E          MOVE.B      #0,D3
                        LEA         END_ADDR_MSG,A1  ; prompt user for ending address
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        BRA         TAKE_USER_INPUT
                        
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
                        
                        BRA         TAKE_USER_INPUT
                        
INVALID_END_ADDR        LEA         INVALID_END_ADDR_MSG,A1
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        BRA         TAKE_USER_INPUT
                        
INVALID_ADDR_LOW        LEA         INVALID_ADDR_L_MSG,A1    ;tell the user the address was invalid and prompt input again.
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        BRA         TAKE_USER_INPUT

INVALID_ADDR_HIGH       LEA         INVALID_ADDR_H_MSG,A1    ;tell the user the address was invalid and prompt input again.
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        BRA         TAKE_USER_INPUT
               
CONVERSION_DONE         LSL.L       #8,D7   ; Prepare for concatenation
                        LSL.L       #8,D7   ; Got to perform the same operation twice to get it all the way to the left
                        ADD.W       D6,D7  ; concatenate the two data registers into one value
                        
                        CMP.L       #MIN_ADDRESS,D7
                        BLT         INVALID_ADDR_LOW ;Not a valid address-- too low.
                        
                        CMP.L       #MAX_ADDRESS,D7
                        BGT         INVALID_ADDR_HIGH  ;Not a valid address-- too high.
                        
VALID_ADDR              CMPI        #1,D3
                        
                        BEQ         SET_START_ADDR
                        BRA         SET_END_ADDR              
                                               
SET_START_ADDR          MOVEA.L     D7,A5  ;when a valid start address is inputted, store and ask the user for an end address.
                        BRA         TAKE_USER_IN_E

SET_END_ADDR            CMP.L       A5,D7    ;if end address is lower than start address, we get an error.
                        BLT         INVALID_END_ADDR           
                        
                        MOVEA.L     D7,A6  ;when a valid start address is inputted, store and ask the user for an end address.
                        BRA         BEGIN_READ
                        
BEGIN_READ              MOVEA.L      A5,A4 ; keep track of address to print with A4. TODO: could also add this value to the display buffer.
                        MOVE.W      (A5)+,CURRENT_WORD ;look at the first instruction word at the starting address.
                        BRA         PREPARE_DISPLAY

*------------------- Add to display buffer -------------------
;At this point A5 is a valid start address and A6 is a valid end address.
;TODO: prepare the display buffer
PREPARE_DISPLAY         BRA         READ_CURRENT_OP    ;TEMP (though we might still call this after the display buffer is prepared)                       
               
*------------------- Move address pointer for data reading -------------------
; This method is specifically for reading the next OPword.
GO_TO_NEXT_OP           BRA         CHECK_DONE_READING
                         
CONFIRMED_NEXT_OP       CLR         CURRENT_WORD
                        MOVEA.L      A5,A4 ; keep track of address to print with A4. 
                        MOVE.W      (A5)+,CURRENT_WORD
                        BRA         READ_CURRENT_OP
                        
*------------------- Print display buffer -------------------

;TODO

*------------------- Check if end of data -------------------
CHECK_DONE_READING      CMPA        A6,A5       ; TODO: this comparison is not sufficient, because it will say that $8000 is less than $7000 (since $8000 is negative.)
                        BLT         CONFIRMED_NEXT_OP
                        BRA         DONE_READING
                        
*------------------- Confirm end of data -------------------
DONE_READING            LEA         DONE_READING_MSG,A1 ; when we reach the end address, say so and halt the program. TODO: ask user whether we want to read the data again.
                        MOVE.B      #14,D0
                        TRAP        #15
                        JMP         STOP
                        
*################## END IO  #####################################
*################## BEGIN OPCODE ##########################
*** OPcode Subroutines are kept here ***

; planned process for reading hex instructions:
        ; NOTE: this process is tentative and subject to change as OPcode person implements. 
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

*------------------- Read current OPcode -------------------
; By this point, CURRENT_WORD should store a potential beginning of an instruction, so we should not increment A5.
READ_CURRENT_OP         BRA         CHECK_CONSTANTS
                        
  
*------------------- Display current address we are reading -------------------
DISPLAY_CURRENT_ADDRESS LEA         DOLLAR,A1       ; '$'
                        MOVE.B      #14,D0
                        TRAP        #15
                
                        MOVE.L      A4,D1           ; display the address the instruction was found at
                        MOVE.B      #16,D2
                        MOVE.B      #15,D0
                        TRAP        #15

                        LEA         SPACE,A1        ; ' '
                        MOVE.B      #14,D0      
                        TRAP        #15     
                        
                        RTS
 
*------------------ Check current word for constants---------
; By this point, the current word should store a potential beginning of an instruction.                   
CHECK_CONSTANTS         CMP         #RESET_CODE,(CURRENT_WORD)
                        BEQ         RESET_FOUND
                        CMP         #NOP_CODE,(CURRENT_WORD)
                        BEQ         NOP_FOUND
                        CMP         #STOP_CODE,(CURRENT_WORD)
                        BEQ         STOP_FOUND
                        BRA         CHECK_NON_CONSTANTS     ;Once we rule out all the constants we know of, we check for non-constants.

; TODO: change the structure of these subroutines to be like the nice structure used in EA SRs.
                       
RESET_FOUND             BSR         DISPLAY_CURRENT_ADDRESS

                        LEA         RESET_MSG,A1    ; 'RESET'
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        LEA         RETURN,A1       ; (return)
                        MOVE.B      #14,D0
                        TRAP        #15
               
                        BRA         GO_TO_NEXT_OP   
 
; NOTE: this SR is temporary. Once we have the display buffer, it will work differently.                 
NOP_FOUND               BSR         DISPLAY_CURRENT_ADDRESS

                        LEA         NOP_MSG,A1    ; 'NOP'
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        LEA         RETURN,A1     ; (return)
                        MOVE.B      #14,D0
                        TRAP        #15
               
                        BRA         GO_TO_NEXT_OP   ; when we are done parsing and displaying the NOP instruction, go to the next OPcode.

STOP_FOUND              JMP         STOP  ;TODO: case for stop found. (NOTE that STOP instructions have additional data.)               

;TODO: add cases for rest of valid constant OPcodes here

*----------------- Check current word for non-constants---------
;NOTE: we currently know that CURRENT_WORD is not a constant by the time we reach this SR.

CHECK_NON_CONSTANTS     BSR         CHECK_MOVE        ; MOVE is a special case because of how its first nibble is structured.     
                        BSR         CHECK_MOVEQ       ; MOVEQ is also a special case.
                        BSR         CHECK_EXT         ; need to rule out EXT before checking MOVEM, because they have very similar OPcodes.
                        BSR         CHECK_MOVEM      
                        BSR         CHECK_NIB1_0000 
                        BSR         CHECK_NIB1_0100 
                        
                        ; TODO: BSR to checks for other special cases, along with nibbles.
                        
                        ;NOTE: we do not check for most specific instructions here.

                        ; TODO: go into the subroutines below and *fully* implement the followings:
                        *   -MOVEM  (W,L)
                        *   -ADD    (B,W,L) (will need shahin's size filter for this and below)
                        *   -ADDA   (W,L)
                        *   -ADDI   (B,W,L)
                        *   -SUB    (B,W,L)
                        ;etc
                        JMP         STOP
                        ;TODO: check for other instructions instead of stopping if it's not one of these.
  
*-----------------------First 4bit checks go here-----------------------------------
  
*-----------------------Check if the current word starts with 0000--------------------
CHECK_NIB1_0000         CLR         D3
                        MOVE.W      CURRENT_WORD,D3
                        ANDI.W      #FILT_NIB_1,D3  ; filter out the first 4 bits of the word
                        CMP         #CONST_ALL_0,D3 ; see if they are all 0
                        BEQ         CONFIRM_NIB1_0000
                        RTS 
                        
CHECK_NIB1_0100         CLR         D3 
                        MOVE.W      CURRENT_WORD,D3
                        ANDI.W      #FILT_NIB_1,D3      ; filter out the first 4 bits of the word
                        CMP         #CONST_NIB1_0100,D3 ; see if they are 0100
                        BEQ         CONFIRM_NIB1_0100
                        RTS                        
                        
*-----------------------First 4bit confirms go here--------------------------------------

*-----------------------Cases where the current word starts with 0000--------------------                       
CONFIRM_NIB1_0000       CLR         D3
                        MOVE.W      CURRENT_WORD,D3
                        ANDI.W      #FILT_BIT_8,D3  ; turn word into 0000 000X 0000 0000
                        LSR.W       #8,D3           ; turn word into 0000 0000 0000 000X
                        CMP         #CONST_ALL_0,D3 ; see if the word is still 0.
                        BEQ         CONFIRM_0000_XXX0
                        ; if we get to here, then the word must be BCHG, BCLR, BSET, or MOVEP.
                        ; BCHG is required
                        ; if our disassembler doesn't consider any of those valid, there should be an error message here.
                        RTS 
                        
; at this point, the word is of the form 0000 XXX0...
CONFIRM_0000_XXX0       CLR         D3
                        MOVE.W      CURRENT_WORD,D3
                        ANDI.W      #FILT_DEST_REG,D3  ; turn word into 0000 XXX0 0000 0000          
                        
                        ; now figure out which operation we have: (note that constants have been ruled out by this point)
                        
                        CMP         #CONST_ORI_DEST_REG,D3  ; ORI 
                        BEQ         ORI_FOUND           
                        
                        CMP         #CONST_ANDI_DEST_REG,D3 ; ANDI 
                        BEQ         ANDI_FOUND
                        
                        CMP         #CONST_SUBI_DEST_REG,D3 ; SUBI
                        BEQ         SUBI_FOUND
                        ;
                        CMP         #CONST_ADDI_DEST_REG,D3 ; ADDI
                        BEQ         ADDI_FOUND
                        
                        CMP         #CONST_EORI_DEST_REG,D3 ; EORI
                        BEQ         EORI_FOUND
                        
                        CMP         #CONST_CMPI_DEST_REG,D3 ; CMPI
                        BEQ         CMPI_FOUND
                        
                        ;TODO: remaining: BTST, BCHG, BCLR, or BSET. 
                        ;      if none of them, an error case should occur here.
                        ;     (note that BCHG is required, though we don't know which version.)
                        
                        RTS     ;change RTS to whatever branch instruction is appropriate here.
                        
*-----------------------Cases where the current word starts with 0100-----------------

    ; if we were doing every OPcode, would start by checking for MOVE from SR, MOVE to CCR, and MOVE to SR at the top of this SR.
    ; instead, we start with NEGX.
CONFIRM_NIB1_0100       CLR         D3              
                        MOVE.W      CURRENT_WORD,D3
                        ANDI.W      #FILT_BIT_5,D3  ; turn word into 0000 X000 0000 0000
                        LSR.W       #8,D3           ; turn word into 0000 0000 0000 000X
                        LSR.W       #3,D3
                        CMP         #CONST_ALL_0,D3 ; see if the word is still 0.
                        BEQ         CONFIRM_0100_0XXX   ; branch based on the 5th bit.
                        BRA         CONFIRM_0100_1XXX
                        
CONFIRM_0100_0XXX       CLR         D3              
                        MOVE.W      CURRENT_WORD,D3
                        ANDI.W      #FILT_NIB_2,D3  ; turn word into 0000 XXXX 0000 0000
                        
                        ; now figure out which operation we have:
                        
                        CMP         #CONST_NEGX_OP,D3
                        BEQ         NEGX_FOUND
                        
                        CMP         #CONST_CLR_OP,D3
                        BEQ         CLR_FOUND
                        
                        CMP         #CONST_NEG_OP,D3
                        BEQ         NEG_FOUND
                        
                        CMP         #CONST_NOT_OP,D3
                        BEQ         NOT_FOUND         ; note that we could likely make a conflicting SR name with one.
                        
                        ; TODO: we definitely have an error at this point.
                        
                        JMP         STOP     ;change STOP to whatever we want based on error. (probably some error case which will then branch to reading next OPcode.)
                        
CONFIRM_0100_1XXX       CLR         D3
                        MOVE.W      CURRENT_WORD,D3
                        ANDI.W      #FILT_NIB_2,D3  ; turn word into 0000 XXXX 0000 0000
                        
                        CMP         #CONST_NIB2_1000,D3
                        BEQ         CONFIRM_0100_1000

                        CMP         #CONST_NIB2_1010,D3
                        BEQ         CONFIRM_0100_1010 

                        CMP         #CONST_NIB2_1110,D3
                        BEQ         CONFIRM_0100_1110 
                        ; TODO: make MOVEM a special case since it has an unusual OPcode.
                        ; TODO: remaining possibilities are MOVEM, LEA, or CHK. (the first two are required.)

                        JMP         STOP                      
                   
CONFIRM_0100_1000       JMP         STOP                       
; TODO: check for EXT, NBCD, SWAP, or PEA.               
 
CONFIRM_0100_1010       JMP         STOP  
; TODO: check for TAS or TST. (ILLEGAL is already ruled out.)         
       
CONFIRM_0100_1110       JMP         STOP       
; TODO: check for TRAP, LINK, UNLK, MOVE USP, JSR, or JMP. (some of these are required.)

*-----------------------Cases where the current word starts with 0101-----------------
    ;TODO: ADDQ, SUBQ, Scc, DBcc (some of these are required)
 
*-----------------------Cases where the current word starts with 0110-----------------
    ;TODO: BRA, BSR, Bcc (some of these are required)   
    
*-----------------------Cases where the current word starts with 1000-----------------
    ;TODO: DIVU, DIVS, SBCD, OR (some of these are required)   
    
*-----------------------Cases where the current word starts with 1001-----------------
    ;TODO: SUB, SUBX, SUBA (some of these are required) 
 
*-----------------------Cases where the current word starts with 1011-----------------
    ;TODO: EOR, CMPM, CMP, CMPA (some of these are required)  
    
*-----------------------Cases where the current word starts with 1100-----------------
    ;TODO: MULU, MULS, ABCD, EXG, AND (some of these are required) 
    
*-----------------------Cases where the current word starts with 1101-----------------
    ;TODO: ADD, ADDX, ADDA (some of these are required) 
    
*-----------------------Cases where the current word starts with 1110-----------------
    ;TODO: ASR, ASL, LSR, LSL, ROXR, ROXL, ROR, ROL (these are all repeated twice on the sheet for some reason) 
                                                    ;(some of these are required) 
 
*-----------------------Special OPcode (but not constants) have checks here------------
* includes MOVE, MOVEQ, etc
                                
*-----------------------Check current word for MOVE------------------------------------
*MOVE can be B,W, or L.
CHECK_MOVE              CLR         D3
                        MOVE.W      CURRENT_WORD,D3
                        ANDI.W      #FILT_NIB_1,D3
                        CMP         #CONST_MOVE_B,D3
                        BEQ         MOVE_B_FOUND
                        CMP         #CONST_MOVE_W,D3
                        BEQ         MOVE_W_FOUND
                        CMP         #CONST_MOVE_L,D3
                        BEQ         MOVE_L_FOUND
                        RTS 
                        
*-----------------------Check current word for MOVEQ------------------------------------
*MOVEQ can only be L.                       
CHECK_MOVEQ             CLR         D3
                        MOVE.W      CURRENT_WORD,D3
                        ANDI.W      #FILT_NIB_1,D3
                        CMP         #CONST_MOVEQ,D3
                        BEQ         MOVEQ_FOUND
                        RTS 
                        

*-----------------------Check current word for EXT------------------------------------  
*check EXT before MOVEM, since they can be easily confused.
*EXT can be W or L.                  
CHECK_EXT               CLR         D3                  
                        MOVE.W      CURRENT_WORD,D3
                        ANDI.W      #FILT_EXT,D3
                        CMP         #CONST_EXT,D3
                        BEQ         EXT_FOUND
                        RTS 
                        
*-----------------------Check current word for MOVEM------------------------------------  
*MOVEM can be W or L.                  
CHECK_MOVEM             CLR         D3
                        MOVE.W      CURRENT_WORD,D3
                        ANDI.W      #FILT_MOVEM,D3
                        CMP         #CONST_MOVEM,D3
                        BEQ         MOVEM_FOUND
                        RTS 
                        
*---------------------- END OPWORD CHECKS -----------------------------------------

*---------------------- BEGIN CASES FOR FOUND OPCODES------------------------------

*-----------------------MOVE-related Subroutines------------------------------------

*-----------------------Cases for finding different MOVE OPcodes------------------------------------
*MOVE.B
MOVE_B_FOUND            MOVE.B      #BYTE_SIZE,CURRENT_OP_SIZE
                        BSR         DISPLAY_CURRENT_ADDRESS
                        BSR         PARSE_MOVE_DATA                           
                       
                        LEA         MOVE_B_MSG,A1      ; 'MOVE.B'
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        LEA         SPACE,A1           ; ' '
                        MOVE.B      #14,D0      
                        TRAP        #15
                        
                        BSR         DISPLAY_MOVE_DATA
                        BRA         GO_TO_NEXT_OP

*MOVE.W                        
MOVE_W_FOUND            MOVE.B      #WORD_SIZE,CURRENT_OP_SIZE
                        BSR         DISPLAY_CURRENT_ADDRESS
                        BSR         PARSE_MOVE_DATA       
                        
                        LEA         MOVE_W_MSG,A1      ; 'MOVE.W'
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        LEA         SPACE,A1           ; ' '
                        MOVE.B      #14,D0      
                        TRAP        #15
                        
                        BSR         DISPLAY_MOVE_DATA
                        BRA         GO_TO_NEXT_OP  

*MOVE.L                        
MOVE_L_FOUND            MOVE.B      #LONG_SIZE,CURRENT_OP_SIZE
                        BSR         DISPLAY_CURRENT_ADDRESS
                        BSR         PARSE_MOVE_DATA       
                        
                        LEA         MOVE_L_MSG,A1      ; 'MOVE.L'
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        LEA         SPACE,A1           ; ' '
                        MOVE.B      #14,D0      
                        TRAP        #15
                        
                        BSR         DISPLAY_MOVE_DATA
                        BRA         GO_TO_NEXT_OP 
                       
*-----------------------Parse data for any-sized MOVE instruction---------------------
*Note that the size of the MOVE is stored in CURRENT_OP_SIZE.
PARSE_MOVE_DATA         ; TODO: error checking 
                        ;(maybe after reading the first 4 instruction parts, but before reading additional data)
                        ;IMPORTANT: remember that different MOVE error are specific to different MOVE sizes.
                        ; example: MOVE.B  A0,D3 is invalid. However, MOVE.W  A0,D3 is valid.
                        ;
                        ; possible errors:
                        ;       CURRENT_DEST_MD = CONST_IMMEDIATE_REG (immediate data cannot be a destination)
                        ;       CURRENT_SRC_MD  = CONST_ADDR_REG_MD   (byte is not a valid size for this move)
                        ;       CURRENT_DEST_MD = CONST_ADDR_REG_MD   (byte is not a valid size, although we should be using MOVEA at this point, not MOVE.)
                        ;       TODO: figure out other possible errors.
                        
                        ; after we confirm that there are no errors, we know that we can safely check for additional data and display the instruction.
                        
                        
                        ; at this point, need to read more information (parsed by EA, probably)
                        ; now that we have a move instruction, we set our EA variables accordingly:
                        BSR         READ_DEST_REG      ; EA will set CURRENT_DEST_REG.
                        BSR         READ_DEST_MODE     ; EA will set CURRENT_DEST_MD.
                        BSR         READ_SOURCE_MODE   ; EA will set CURRENT_SRC_MD.
                        BSR         READ_SOURCE_REG    ; EA will set CURRENT_SRC_REG.
                        
                        ; need to check whether we need to read additional data before we start displaying the
                        ; instruction (for instance, this is necessary for MOVE.B #10,D0).
                        BSR         READ_SOURCE_DATA   ; EA will set CURRENT_SOURCE_DATA if necessary.
                        BSR         READ_DEST_DATA     ; EA will set CURRENT_DEST_DATA if necessary. 
                        RTS         

DISPLAY_MOVE_DATA       BSR         DISPLAY_SOURCE     ; Tell EA to parse and display the source. EX: (A1)   D3    #10   $1000 etc
                        
                        LEA         COMMA,A1           ; ','
                        MOVE.B      #14,D0      
                        TRAP        #15
                        
                        BSR         DISPLAY_DEST       ; Tell EA to parse and display the destination.
                        
                        LEA         RETURN,A1          ; (return)
                        MOVE.B      #14,D0
                        TRAP        #15

                        RTS        
                         
*-----------------------MOVEQ-related Subroutines------------------------------------

*-----------------------Case for finding MOVEQ------------------------------------
MOVEQ_FOUND             MOVE.B      #LONG_SIZE,CURRENT_OP_SIZE
                        BSR         DISPLAY_CURRENT_ADDRESS
                        BSR         PARSE_MOVEQ_DATA       
                        
                        LEA         MOVEQ_MSG,A1      ; 'MOVEQ'
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        LEA         SPACE,A1           ; ' '
                        MOVE.B      #14,D0      
                        TRAP        #15
                        
                        BSR         DISPLAY_MOVEQ_DATA
                        BRA         GO_TO_NEXT_OP  

PARSE_MOVEQ_DATA        ;TODO: check that 0000 000X 0000 0000 equals zero. If not, error.
                        
                        BSR         READ_DEST_REG                       ; EA will set CURRENT_DEST_REG.
                        MOVE.B      #CONST_DATA_REG_MD,CURRENT_DEST_MD  ; data register is the only allowed destination for MOVEQ.
                        BSR         READ_MOVEQ_DATA                     ; 0000 0000 XXXX XXXX will set CURRENT_SOURCE_DATA (I think.)
                        
                        MOVE.B      #CONST_ADDR_MISC_MD,CURRENT_SRC_MD
                        MOVE.B      #CONST_IMMEDIATE_REG,CURRENT_SRC_REG
                        
                        RTS 

DISPLAY_MOVEQ_DATA      BSR         DISPLAY_SOURCE     ; Tell EA to parse and display the source. 
                        
                        LEA         COMMA,A1           ; ','
                        MOVE.B      #14,D0      
                        TRAP        #15
                        
                        BSR         DISPLAY_DEST       ; Tell EA to parse and display the destination.
                        
                        LEA         RETURN,A1          ; (return)
                        MOVE.B      #14,D0
                        TRAP        #15

                        RTS        

;NOTE: this SR is stored here and not in EA because it is specific to MOVEQ.
READ_MOVEQ_DATA         CLR         D4
                        CLR         CURRENT_SRC_DATA
                        MOVE.W      CURRENT_WORD,D4
                        ANDI.W      #FILT_MOVEQ_DATA,D4        ; turn D4 into 0000 0000 XXXX XXXX (no shift necessary)
                        MOVE.W      D4,CURRENT_SRC_DATA
                        RTS
                    
  ; TODO: (in order)
    *   -MOVEM  (W,L)
    *   -ADD    (B,W,L) (will need shahin's size filter for this and below)
    *   -ADDA   (W,L)
    *   -ADDI   (B,W,L)
    *   -SUB    (B,W,L)
  ; see comment block at the top of the program for the full list of codes.
  ; see huge comment block at the top of OPcode section for tentative OPcode parsing implementation plan.
 
*-----------------------EXT-related Subroutines------------------------------------
EXT_FOUND               JMP         STOP ;TODO: case for EXT found

*-----------------------MOVEM-related Subroutines------------------------------------
MOVEM_FOUND             JMP         STOP ;TODO: case for MOVEM found (currently the next goal)      
  
*-----------------------ORI-related Subroutines------------------------------------
ORI_FOUND               JMP         STOP ;TODO: case for ORI found

 *----------------------ANDI-related Subroutines------------------------------------
ANDI_FOUND              JMP         STOP ;TODO: case for ANDI found

 *----------------------SUBI-related Subroutines------------------------------------
SUBI_FOUND              JMP         STOP ;TODO: case for SUBI found

 *----------------------ADDI-related Subroutines------------------------------------
ADDI_FOUND              JMP         STOP ;TODO: case for ADDI found
 
*-----------------------EORI-related Subroutines------------------------------------
EORI_FOUND              JMP         STOP ;TODO: case for EORI found
 
*-----------------------CMPI-related Subroutines------------------------------------
CMPI_FOUND              JMP         STOP ;TODO: case for CMPI found

*-----------------------NEGX-related Subroutines------------------------------------
NEGX_FOUND              JMP         STOP ;TODO: case for NEGX found 

*-----------------------CLR-related Subroutines------------------------------------
CLR_FOUND               JMP         STOP ;TODO: case for CLR found 

*-----------------------NEG-related Subroutines------------------------------------
NEG_FOUND               JMP         STOP ;TODO: case for NEG found 

*-----------------------NOT-related Subroutines------------------------------------
NOT_FOUND               JMP         STOP ;TODO: case for NOT found 
                    
*###################### END OPCODE ##################################
*###################### BEGIN EA ##################################
*** EA Subroutines are kept here ***
*----------------------Check the destination register of the current word.-------------
READ_DEST_REG           CLR         D4
                        CLR.B       CURRENT_DEST_REG
                        MOVE.W      CURRENT_WORD,D4
                        ANDI.W      #FILT_DEST_REG,D4       ; turn D4 into 0000 XXX0 0000 0000
                        LSR.W       #8,D4                   ; turn D4 into 0000 0000 0000 0XXX
                        LSR.W       #1,D4                   ; 9 would be invalid, so we shift 8, then 1
                        MOVE.B      D4,CURRENT_DEST_REG
                        RTS

*----------------------Check the destination mode of the current word.-------------
*(assuming the destination is where it would be in MOVE).
READ_DEST_MODE          CLR         D4
                        CLR.B       CURRENT_DEST_MD
                        MOVE.W      CURRENT_WORD,D4
                        ANDI.W      #FILT_DEST_MD,D4        ; turn D4 into 0000 000X XX00 0000
                        LSR.W       #6,D4                   ; turn D4 into 0000 0000 0000 0XXX
                        MOVE.B      D4,CURRENT_DEST_MD
                        RTS

;By this point, CURRENT WORD holds the first 16 bits of an instruction we are looking at.
;(we should already know the OPcode by this point, so this will be called by various OPcode subroutines.)
*---------------------- Check the source mode of the current word.--------------------
*(assuming the source is where it would be in MOVE).
READ_SOURCE_MODE        CLR         D4
                        CLR.B       CURRENT_SRC_MD
                        MOVE.W      CURRENT_WORD,D4
                        ANDI.W      #FILT_SRC_MD,D4                 ; turn source mode into 0000 0000 00XX X000
                        LSR.W       #3,D4                           ; turn source mode into 0000 0000 0000 0XXX
                        MOVE.B      D4,CURRENT_SRC_MD
                        RTS
                        
*----------------------Check the source register of the current word.-----------------
READ_SOURCE_REG         CLR         D4
                        CLR.B       CURRENT_SRC_REG
                        MOVE.W      CURRENT_WORD,D4
                        ANDI.W      #FILT_SRC_REG,D4        ; turn D4 into 0000 0000 0000 0XXX. (no need for LSR in this case.)
                        MOVE.B      D4,CURRENT_SRC_REG
                        RTS
*--------TODO: READ_OP_SIZE---------
                       
*----------------------Read additional source data associated with the current word (if necessary).----------------- 
*This needs to postincrement A5 as necessary.
READ_SOURCE_DATA        CLR         CURRENT_SRC_DATA
                        CLR         CURRENT_DATA
                        CMP.B       #CONST_ADDR_MISC_MD,CURRENT_SRC_MD ; check the source mode
                        BEQ         CONFIRM_READ_SRC_DATA              ; see if we have a source mode that requires additional data.               
                        RTS
                        
CONFIRM_READ_SRC_DATA   CLR.B       CURRENT_REG
                        MOVE.B      CURRENT_SRC_REG,CURRENT_REG
                        BSR         CONFIRM_READ_DATA
                        MOVE.L      CURRENT_DATA,CURRENT_SRC_DATA
                        RTS
 
*----------------------Read additional destination data associated with the current word (if necessary).----------------- 
*This needs to postincrement A5 as necessary.                       
READ_DEST_DATA          CLR         CURRENT_DEST_DATA
                        CLR         CURRENT_DATA
                        CMP.B       #CONST_ADDR_MISC_MD,CURRENT_DEST_MD  ; check the destination mode.
                        BEQ         CONFIRM_READ_DEST_DATA               ; see if we have a destination mode that requires additional data.                  
                        RTS
                                            
CONFIRM_READ_DEST_DATA  CLR.B       CURRENT_REG
                        MOVE.B      CURRENT_DEST_REG,CURRENT_REG
                        BSR         CONFIRM_READ_DATA
                        MOVE.L      CURRENT_DATA,CURRENT_DEST_DATA
                        RTS

*-----------------------Read some additional data.----------------------------------------------------------
      ; This same subroutine is used for reading source and destination data.
      ; By this point, CURRENT_REG holds whatever register we currently care about. (could also use CURRENT_REG)         
CONFIRM_READ_DATA       CMP.B       #CONST_COUNTR_DISPLC_REG,CURRENT_REG      ; see if we are reading counter w/ displacement
                        BEQ         READ_COUNTR_DISPLC_DATA
                   
                        CMP.B       #CONST_COUNTR_INDEX_REG,CURRENT_REG       ; see if we are reading counter w/ index
                        BEQ         READ_COUNTR_INDEX_DATA
                        
                        CMP.B       #CONST_ABS_SHORT_REG,CURRENT_REG          ; see if we are reading absolute short address
                        BEQ         READ_ABS_SHORT_DATA
                        
                        CMP.B       #CONST_ABS_LONG_REG,CURRENT_REG           ; see if we are reading absolute long address
                        BEQ         READ_ABS_LONG_DATA 
                        
                        CMP.B       #CONST_IMMEDIATE_REG,CURRENT_REG          ; see if we are reading immediate data
                        BEQ         READ_IMMEDIATE_DATA
     
                        RTS
                        
; TODO: each of these SRs should increment A5 by the proper amount while also storing the correct data in CURRENT_DATA.
READ_COUNTR_DISPLC_DATA RTS ; TODO: read data for counter w/ displacement (d16,PC)

READ_COUNTR_INDEX_DATA  RTS ; TODO: read data for counter w/ index        (d16,PC,Xn)

*-----------------------Read additional absolute word address---------------------------
READ_ABS_SHORT_DATA     MOVE.W      (A5)+,CURRENT_DATA ; read data for absolute short address  (xxx).W
                        RTS
                        
*-----------------------Read additional absolute long address---------------------------
READ_ABS_LONG_DATA      MOVE.L      (A5)+,CURRENT_DATA ; read data for absolute long address   (xxx).L
                        RTS 

*-----------------------Read additional immediate data---------------------------
READ_IMMEDIATE_DATA     CMP.B       #BYTE_SIZE,CURRENT_OP_SIZE   ; see if we are reading immediate byte data
                        BEQ         READ_IMMEDIATE_DATA_W
                        
                        CMP.B       #WORD_SIZE,CURRENT_OP_SIZE   ; see if we are reading immediate word data
                        BEQ         READ_IMMEDIATE_DATA_W
                        
                        CMP.B       #LONG_SIZE,CURRENT_OP_SIZE   ; see if we are reading immediate long data
                        BEQ         READ_IMMEDIATE_DATA_L
                        ;TODO: error case goes here
                        RTS

READ_IMMEDIATE_DATA_W   CLR         CURRENT_DATA
                        MOVE.W      (A5)+,CURRENT_DATA
                        RTS
                        
READ_IMMEDIATE_DATA_L   CLR         CURRENT_DATA
                        MOVE.L      (A5)+,CURRENT_DATA
                        RTS
                        
*----------------------Display the source for the current instruction.-----------------
*by this point, error checking should already be done and CURRENT_SRC_MD and CURRENT_SRC_REG should have the data we need.
DISPLAY_SOURCE          CLR.B       CURRENT_MD
                        CLR.B       CURRENT_REG
                        CLR.L       CURRENT_DATA
                        
                        MOVE.B      CURRENT_SRC_MD,CURRENT_MD
                        MOVE.B      CURRENT_SRC_REG,CURRENT_REG    
                        MOVE.L      CURRENT_SRC_DATA,CURRENT_DATA
                        BSR         CHECK_ADDRESSING_MODES   
                        RTS  
                        
*----------------------Display the destination for the current instruction.-----------------
*by this point, error checking should already be done and CURRENT_DEST_MD and CURRENT_DEST_REG should have the data we need.
DISPLAY_DEST            CLR.B       CURRENT_MD
                        CLR.B       CURRENT_REG
                        CLR.L       CURRENT_DATA
                        
                        MOVE.B      CURRENT_DEST_MD,CURRENT_MD
                        MOVE.B      CURRENT_DEST_REG,CURRENT_REG    
                        MOVE.L      CURRENT_DEST_DATA,CURRENT_DATA
                        BSR         CHECK_ADDRESSING_MODES     
                        RTS  
                        

                        
*-----------------------Mode checks (for displaying)---------
*these do not care whether the mode is for source or destination.
CHECK_ADDRESSING_MODES  CMP.B       #CONST_DATA_REG_MD,CURRENT_MD   ; check for CURRENT_MD = ...0000
                        BEQ         DISPLAY_DATA_REG
                        CMP.B       #CONST_ADDR_REG_MD,CURRENT_MD    ; check for CURRENT_MD = ...0001
                        BEQ         DISPLAY_ADDR_REG
                        CMP.B       #CONST_ADDR_IND_MD,CURRENT_MD    ; check for CURRENT_MD = ...0010
                        BEQ         DISPLAY_ADDR_IND
                        CMP.B       #CONST_ADDR_INCR_MD,CURRENT_MD   ; check for CURRENT_MD = ...0011
                        BEQ         DISPLAY_ADDR_INCR
                        CMP.B       #CONST_ADDR_DECR_MD,CURRENT_MD   ; check for CURRENT_MD = ...0100
                        BEQ         DISPLAY_ADDR_DECR
                        CMP.B       #CONST_ADDR_DISPLC_MD,CURRENT_MD ; check for CURRENT_MD = ...0101
                        BEQ         DISPLAY_ADDR_DISPLC
                        CMP.B       #CONST_ADDR_INDEX_MD,CURRENT_MD  ; check for CURRENT_MD = ...0110
                        BEQ         DISPLAY_ADDR_INDEX
                        CMP.B       #CONST_ADDR_MISC_MD,CURRENT_MD   ; check for CURRENT_MD = ...0111
                        BEQ         CHECK_MISC_ADDRESSINGS
                        ;TODO: error cases? 
                        RTS

; case for displaying data register.          
DISPLAY_DATA_REG        LEA         MSG_D,A1               ; print out 'D' (later, send this to dislpay buffer)
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        CLR         D1
                        MOVE.B      (CURRENT_REG),D1      ; print out the number of the data register.
                        MOVE.B      #16,D2
                        MOVE.B      #15,D0
                        TRAP        #15
                        
                        RTS

; case for displaying address register. 
DISPLAY_ADDR_REG        LEA         MSG_A,A1               ; print out 'A'
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        CLR         D1
                        MOVE.B      (CURRENT_REG),D1       ; print out the number of the data register.
                        MOVE.B      #16,D2
                        MOVE.B      #15,D0
                        TRAP        #15
                        
                        RTS

; case for displaying address register indirect.                        
DISPLAY_ADDR_IND        LEA         OPEN_PARENS,A1         ; print out '(' (later, send this to dislpay buffer)
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        LEA         MSG_A,A1               ; print out 'A'
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        CLR         D1
                        MOVE.B      (CURRENT_REG),D1      ; print out the number of the data register.
                        MOVE.B      #16,D2
                        MOVE.B      #15,D0
                        TRAP        #15
                        
                        LEA         CLOSE_PARENS,A1       ; print out ')'
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        RTS

; case for displaying address indirect postincrement.
DISPLAY_ADDR_INCR       LEA         OPEN_PARENS,A1        ; print out '(' (later, send this to dislpay buffer)
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        LEA         MSG_A,A1              ; print out 'A'
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        CLR         D1
                        MOVE.B      (CURRENT_REG),D1      ; print out the number of the data register.
                        MOVE.B      #16,D2
                        MOVE.B      #15,D0
                        TRAP        #15
                        
                        LEA         CLOSE_PARENS,A1       ; print out ')'
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        LEA         PLUS,A1               ; print out '+'
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        RTS
                        
; case for displaying address indirect preedecrement mode.
DISPLAY_ADDR_DECR       LEA         MINUS,A1               ; print out '-'
                        MOVE.B      #14,D0
                        TRAP        #15                                           

                        LEA         OPEN_PARENS,A1        ; print out '(' (later, send this to dislpay buffer)
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        LEA         MSG_A,A1              ; print out 'A'
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        CLR         D1
                        MOVE.B      (CURRENT_REG),D1      ; print out the number of the data register.
                        MOVE.B      #16,D2
                        MOVE.B      #15,D0
                        TRAP        #15
                        
                        LEA         CLOSE_PARENS,A1       ; print out ')'
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        RTS     

DISPLAY_ADDR_DISPLC     ;TODO: case for source mode is address with displacement mode.
                        RTS    

DISPLAY_ADDR_INDEX      ;TODO: case for source mode is address with index mode.
                        RTS 

*-----------------------Register checks (for displaying only)---------
*these do not care whether the register is for source or destination.
*not for cases where reg is simply a number (like D5, A5, (A5), etc),
*only for miscellaneous addressings where mode is 111.                        
CHECK_MISC_ADDRESSINGS  CMP.B       #CONST_COUNTR_DISPLC_REG,CURRENT_REG
                        BEQ         DISPLAY_COUNTR_DISPLC
                        
                        CMP.B       #CONST_COUNTR_INDEX_REG,CURRENT_REG
                        BEQ         DISPLAY_COUNTR_INDEX
                        
                        CMP.B       #CONST_ABS_SHORT_REG,CURRENT_REG
                        BEQ         DISPLAY_ABS_SHORT
                        
                        CMP.B       #CONST_ABS_LONG_REG,CURRENT_REG
                        BEQ         DISPLAY_ABS_LONG
                        
                        CMP.B       #CONST_IMMEDIATE_REG,CURRENT_REG
                        BEQ         DISPLAY_IMMEDIATE
                        
                        ; TODO: error case?
                        
                        RTS
                        
DISPLAY_COUNTR_DISPLC   RTS         ;TODO   

DISPLAY_COUNTR_INDEX    RTS         ;TODO   

DISPLAY_ABS_SHORT       LEA         DOLLAR,A1             ; print out '$'. 
                        MOVE.B      #14,D0
                        TRAP        #15

                        CLR         D1
                        MOVE.W      (CURRENT_DATA),D1     ; print out the absolute short address we are concerned with in hex. 
                        MOVE.B      #16,D2
                        MOVE.B      #15,D0
                        TRAP        #15
                        
                        RTS 

DISPLAY_ABS_LONG        LEA         DOLLAR,A1             ; print out '$'. 
                        MOVE.B      #14,D0
                        TRAP        #15

                        CLR         D1
                        MOVE.L      (CURRENT_DATA),D1     ; print out the absolute long address we are concerned with in hex. 
                        MOVE.B      #16,D2
                        MOVE.B      #15,D0
                        TRAP        #15
                        
                        RTS 

DISPLAY_IMMEDIATE       LEA         HASH,A1               ; print out '#'. (NOTE: should send this to display buffer instead.)
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        LEA         DOLLAR,A1             ; print out '$'. (this saves time since we can more easily find the hex value of the immediate data.)
                        MOVE.B      #14,D0
                        TRAP        #15
                        
                        MOVE.W      (CURRENT_DATA),D1     ; print out the immediate data we are concerned with in hex. 
                        MOVE.B      #16,D2
                        MOVE.B      #15,D0
                        TRAP        #15
                        
                        RTS
                        
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
OPEN_PARENS             DC.B        '(',0
CLOSE_PARENS            DC.B        ')',0
PLUS                    DC.B        '+',0
MINUS                   DC.B        '-',0

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
    ;sizes
BYTE_SIZE_MSG           DC.B        '.B',0
WORD_SIZE_MSG           DC.B        '.W',0
LONG_SIZE_MSG           DC.B        '.L',0

    ;constants
RESET_MSG               DC.B        'RESET',0
NOP_MSG                 DC.B        'NOP',0
STOP_MSG                DC.B        'STOP',0
    ;moves
MOVE_MSG                DC.B        'MOVE',0
MOVE_B_MSG              DC.B        'MOVE.B',0
MOVE_W_MSG              DC.B        'MOVE.W',0
MOVE_L_MSG              DC.B        'MOVE.L',0

MOVEQ_MSG               DC.B        'MOVEQ',0

*other output instruction message constants
MSG_D                   DC.B        'D',0
MSG_A                   DC.B        'A',0

*storage locations for input
START_ADDR_IN           DS.B        20

*other I/O-related variables/constants
INPUTTING_START         SET         1 ;if 1, we are inputting start address. If 0, we are inputting end address.
OPCODE_BUFFER           DS.L        1 ; can hold at most 4 characters
SIZE_BUFFER             DS.W        1 ;cand hold at most 2 characters
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

*size constants
BYTE_SIZE                EQU         $00 ; 0000 0000
WORD_SIZE                EQU         $01 ; 0000 0001
LONG_SIZE                EQU         $02 ; 0000 0010

BYTE_SIZE_M              EQU         $01 ; 0000 0001
WORD_SIZE_M              EQU         $03 ; 0000 0011
LONG_SIZE_M              EQU         $02 ; 0000 0010

*address constants
MIN_ADDRESS             EQU         $00003000
MAX_ADDRESS             EQU         $0FFF0000

*address variables
TEST_ORIGIN             SET         $00007000
NEXT_ADDR               SET         TEST_ORIGIN
END_ADDR                SET         $00009000

*filters for isolating parts of a hexa instruction. X means 'unknown' and can be 0 or one after ANDI filter.
*To filter an instruction, ANDI it with the desired filter.
*note: I'm not sure if it matters much whether you have the 4 leading 0s in these filters, but I don't want to
*risk changing it. Therefore, some filters have leading 0s and some do not.
    * general filters
FILT_2BIT_1             EQU         $0000C000   ;first 2 bits:                          XX00 0000 0000 0000
FILT_NIB_1              EQU         $0000F000   ;first nibble:                          XXXX 0000 0000 0000
FILT_NIB_2              EQU         $00000F00   ;second nibble:                         0000 XXXX 0000 0000
FILT_BIT_5              EQU         $00000800   ;5th bit:                               0000 X000 0000 0000
FILT_BIT_8              EQU         $00000100   ;8th bit:                               0000 000X 0000 0000

    * source/destination filters (not applicable for bidirectional operations)
FILT_DEST_REG           EQU         $00000E00   ;destination register:                  0000 XXX0 0000 0000
FILT_DEST_MD            EQU         $000001C0   ;destination mode:                      0000 000X XX00 0000
FILT_SRC_MD             EQU         $00000038   ;source mode:                           0000 0000 00XX X000
FILT_SRC_REG            EQU         $00000007   ;source register:                       0000 0000 0000 0XXX

    * move filters
FILT_MOVE_SIZE          EQU         $00003000   ;Size of a move operation:              00XX 0000 0000 0000
FILT_MOVEM              EQU         $FB80       ; check for a MOVEM instruction:        XXXX X0XX X000 0000

    * filters for BRA, BSR, BCC, and MOVEQ (the same filter, but named differently for clarity.)
FILT_DISPLACEMENT       EQU         $00FF       ;Displacment of branch instruction:     0000 0000 XXXX XXXX
FILT_MOVEQ_DATA         EQU         $00FF       ;Data of MOVEQ instruction:             0000 0000 XXXX XXXX

    * EXT filter
FILT_EXT                EQU         $FFB8       ; check for an EXT instruction:         XXXX XXXX X0XX X000

    

* constants for comparing with filtered instructions. X means 'don't care' (and will be set to 0 by previous filter)
*(These do not represent the complete insturctions.)
*(Also note that repetition is allowed for clarity's sake, so two constants can share a value.)
    * general filters
CONST_ALL_0             EQU         $0000    ; all 0s:                               0000 0000 0000 0000
CONST_NIB1_0100         EQU         $4000    ; first nibble is 0100                  0100 XXXX XXXX XXXX
CONST_NIB2_1000         EQU         $0800    ; second nibble is 1000                 XXXX 1000 XXXX XXXX
CONST_NIB2_1010         EQU         $0A00    ; second nibble is 1010                 XXXX 1010 XXXX XXXX
CONST_NIB2_1110         EQU         $0E00    ; second nibble is 1110                 XXXX 1110 XXXX XXXX

* Immediate operation constants
    * ANDI
CONST_ORI_DEST_REG      EQU         $0000    ; confirm ORI                           XXXX 000X XXXX XXXX
    * ANDI
CONST_ANDI_DEST_REG     EQU         $0200    ; confirm ANDI                          XXXX 001X XXXX XXXX
    * SUBI
CONST_SUBI_DEST_REG     EQU         $0400    ; confirm SUBI                          XXXX 010X XXXX XXXX
    * ADDI
CONST_ADDI_DEST_REG     EQU         $0600    ; confirm ADDI                          XXXX 011X XXXX XXXX
    * EORI
CONST_EORI_DEST_REG     EQU         $0A00    ; confirm EORI                          XXXX 101X XXXX XXXX
    * CMPI
CONST_CMPI_DEST_REG     EQU         $0C00    ; confirm CMPI                          XXXX 110X XXXX XXXX

* Constants for matching based on 2nd nibble
    *NEGX
CONST_NEGX_OP           EQU         $0000    ; confirm NEGX                          XXXX 0000 XXXX XXXX
    *CLR
CONST_CLR_OP            EQU         $0200    ; confirm CLR                           XXXX 0010 XXXX XXXX
    *NEG
CONST_NEG_OP            EQU         $0400    ; confirm NEG                           XXXX 0100 XXXX XXXX
    *NOT
CONST_NOT_OP            EQU         $0600    ; confirm NOT                           XXXX 0110 XXXX XXXX

* EXT constant
CONST_EXT               EQU         $4880    ; confirm EXT                           0100 1000 1X00 0XXX

* Other constants
    * BTST,BCHG,BCLR,BSET
CONST_B_OP              EQU         $0800    ; BTST,BCHG,BCLR,BSET                   XXXX 100X XXXX XXXX

    * MOVE
CONST_MOVE_B            EQU         $1000    ; MOVE.B (use first nib)                0001 XXXX XXXX XXXX
CONST_MOVE_W            EQU         $3000    ; MOVE.W (use first nib)                0011 XXXX XXXX XXXX
CONST_MOVE_L            EQU         $2000    ; MOVE.L (use first nib)                0010 XXXX XXXX XXXX

    * MOVEQ
CONST_MOVEQ             EQU         $7000    ; MOVEQ.L (use first nib)               0111 XXXX XXXX XXXX    
         
    * MOVEM                      
CONST_MOVEM             EQU         $8880    ; confirm MOVEM (use FILT_MOVEM)        0100 1X00 1XXX XXXX            
         
* Mode/register constants

    * Mode values
CONST_DATA_REG_MD       EQU         $00      ; Data register mode:     Dn            XXXX X000
CONST_ADDR_REG_MD       EQU         $01      ; Address register mode:  An            XXXX X001
CONST_ADDR_IND_MD       EQU         $02      ; Address indirect mode:  (An)          XXXX X010
CONST_ADDR_INCR_MD      EQU         $03      ; Address postincr. mode: (An)+         XXXX X011
CONST_ADDR_DECR_MD      EQU         $04      ; Address predecr. mode:  -(An)         XXXX X100
CONST_ADDR_DISPLC_MD    EQU         $05      ; Address w/ displacement:(d16,An)      XXXX X101
CONST_ADDR_INDEX_MD     EQU         $06      ; Address w/ index:       (d8,PC,Xn)    XXXX X110
CONST_ADDR_MISC_MD      EQU         $07      ; Various other addressing modes        XXXX X111

    * Constant register values (should not be necessary for register numbers like D5)
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
>>>>>>> 8ff82382e5ddd6e2c1e60fce03f83e9d368d05f4
