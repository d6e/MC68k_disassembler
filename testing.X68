*-----------------------------------------------------------
* Title      : Testing
* Written by : Robert Brandenburg, Danielle Jenkins, Shahin Nahar
* Date       : 2/13/14
* Description: Disassembler test file
*-----------------------------------------------------------

START       ORG    $7000                ; first instruction of program
            NOP
            MOVE.B #10,D0
MUHAHAHA    DS.B            1     
* TODO: use all required opcodes in all possible combinations here
            MOVE.B D1, D2
            MOVE.B D1, $10000000
            MOVE.B D1, $1000
            MOVE.B (A1), D1
            MOVE.B (A1), $10000000
            MOVE.B (A1), $1000
            MOVE.B #1, D1
            MOVE.B #1, $10000000
            MOVE.B #1, $1000
            MOVE.B (A1)+, D1
            MOVE.B (A1)+, $10000000
            MOVE.B (A1)+, $1000
            MOVE.B -(A1), D1
            MOVE.B -(A1), $10000000
            MOVE.B -(A1), $1000
            MOVE.B $10000000, D1
            MOVE.B $10000000, $10000000
            MOVE.B $10000000, $1000
            MOVE.B $1000, D1
            MOVE.B $1000, $10000000
            MOVE.B $1000, $1000
            MOVE.W D1, D1
            MOVE.W D1, $10000000
            MOVE.W D1, $1000
            MOVE.W A1, D1
            MOVE.W A1, $10000000
            MOVE.W A1, $1000
            MOVE.W (A1), D1
            MOVE.W (A1), $10000000
            MOVE.W (A1), $1000
            MOVE.W #1, D1
            MOVE.W #1, $10000000
            MOVE.W #1, $1000
            MOVE.W (A1)+, D1
            MOVE.W (A1)+, $10000000
            MOVE.W (A1)+, $1000
            MOVE.W -(A1), D1
            MOVE.W -(A1), $10000000
            MOVE.W -(A1), $1000
            MOVE.W $10000000, D1
            MOVE.W $10000000, $10000000
            MOVE.W $10000000, $1000
            MOVE.W $1000, D1
            MOVE.W $1000, $10000000
            MOVE.W $1000, $1000
            MOVE.L D1, D1
            MOVE.L D1, $10000000
            MOVE.L D1, $1000
            MOVE.L A1, D1
            MOVE.L A1, $10000000
            MOVE.L A1, $1000
            MOVE.L (A1), D1
            MOVE.L (A1), $10000000
            MOVE.L (A1), $1000
            MOVE.L #1, D1
            MOVE.L #1, $10000000
            MOVE.L #1, $1000
            MOVE.L (A1)+, D1
            MOVE.L (A1)+, $10000000
            MOVE.L (A1)+, $1000
            MOVE.L -(A1), D1
            MOVE.L -(A1), $10000000
            MOVE.L -(A1), $1000
            MOVE.L $10000000, D1
            MOVE.L $10000000, $10000000
            MOVE.L $10000000, $1000
            MOVE.L $1000, D1
            MOVE.L $1000, $10000000
            MOVE.L $1000, $1000
            MOVEQ.L #1, D1
            MOVEM.W A1-A6, (A1)
            MOVEM.W (A1), A1-A6
            MOVEM.W A1-A6, $10000000
            MOVEM.W $10000000, A1-A6
            MOVEM.W A1-A6, $1000
            MOVEM.W $1000, A1-A6
            MOVEM.W D1-D7, (A1)
            MOVEM.W (A1), D1-D7
            MOVEM.W D1-D7, $10000000
            MOVEM.W $10000000, D1-D7
            MOVEM.W D1-D7, $1000
            MOVEM.W $1000, D1-D7
            MOVEM.W D1, (A1)
            MOVEM.W (A1), D1
            MOVEM.W D1, $10000000
            MOVEM.W $10000000, D1
            MOVEM.W D1, $1000
            MOVEM.W $1000, D1
            MOVEM.L A1-A6, (A1)
            MOVEM.L (A1), A1-A6
            MOVEM.L A1-A6, $10000000
            MOVEM.L $10000000, A1-A6
            MOVEM.L A1-A6, $1000
            MOVEM.L $1000, A1-A6
            MOVEM.L D1-D7, (A1)
            MOVEM.L (A1), D1-D7
            MOVEM.L D1-D7, $10000000
            MOVEM.L $10000000, D1-D7
            MOVEM.L D1-D7, $1000
            MOVEM.L $1000, D1-D7
            MOVEM.L D1, (A1)
            MOVEM.L (A1), D1
            MOVEM.L D1, $10000000
            MOVEM.L $10000000, D1
            MOVEM.L D1, $1000
            MOVEM.L $1000, D1
            ADD.B D1, D1
            ADD.B (A1), D1
            ADD.B (A1)+, D1
            ADD.B -(A1), D1
            ADD.B $10000000, D1
            ADD.B $1000, D1
            ADD.W D1, D1
            ADD.W A1, D1
            ADD.W (A1), D1
            ADD.W (A1)+, D1
            ADD.W -(A1), D1
            ADD.W $10000000, D1
            ADD.W $1000, D1
            ADD.L D1, D1
            ADD.L A1, D1
            ADD.L (A1), D1
            ADD.L (A1)+, D1
            ADD.L -(A1), D1
            ADD.L $10000000, D1
            ADD.L $1000, D1
            ADDA.W D1, A1
            ADDA.W A1, A1
            ADDA.W (A1), A1
            ADDA.W (A1)+, A1
            ADDA.W -(A1), A1
            ADDA.W $10000000, A1
            ADDA.W $1000, A1
            ADDA.L D1, A1
            ADDA.L A1, A1
            ADDA.L (A1), A1
            ADDA.L (A1)+, A1
            ADDA.L -(A1), A1
            ADDA.L $10000000, A1
            ADDA.L $1000, A1
            ADDI.B #9, D1
            ADDI.B #9, $10000000
            ADDI.B #9, $1000
            ADDI.W #9, D1
            ADDI.W #9, $10000000
            ADDI.W #9, $1000
            ADDI.L #9, D1
            ADDI.L #9, $10000000
            ADDI.L #9, $1000
            SUB.B D1, D1
            SUB.B (A1), D1
            SUB.B #1, D1
            SUB.B (A1)+, D1
            SUB.B -(A1), D1
            SUB.B $10000000, D1
            SUB.B $1000, D1
            SUB.W D1, D1
            SUB.W A1, D1
            SUB.W (A1), D1
            SUB.W #1, D1
            SUB.W (A1)+, D1
            SUB.W -(A1), D1
            SUB.W $10000000, D1
            SUB.W $1000, D1
            SUB.L D1, D1
            SUB.L A1, D1
            SUB.L (A1), D1
            SUB.L #1, D1
            SUB.L (A1)+, D1
            SUB.L -(A1), D1
            SUB.L $10000000, D1
            SUB.L $1000, D1
            SUBA.W D1, A1
            SUBA.W A1, A1
            SUBA.W (A1), A1
            SUBA.W #1, A1
            SUBA.W (A1)+, A1
            SUBA.W -(A1), A1
            SUBA.W $10000000, A1
            SUBA.W $1000, A1
            SUBA.L D1, A1
            SUBA.L A1, A1
            SUBA.L (A1), A1
            SUBA.L #1, A1
            SUBA.L (A1)+, A1
            SUBA.L -(A1), A1
            SUBA.L $10000000, A1
            SUBA.L $1000, A1
            SUBQ.B #1, D1
            SUBQ.B #1, $10000000
            SUBQ.B #1, $1000
            SUBQ.W #1, D1
            SUBQ.W #1, $10000000
            SUBQ.W #1, $1000
            SUBQ.L #1, D1
            SUBQ.L #1, $10000000
            SUBQ.L #1, $1000
            MULS.W D1, D1
            MULS.W (A1), D1
            MULS.W #1, D1
            MULS.W (A1)+, D1
            MULS.W -(A1), D1
            MULS.W $10000000, D1
            MULS.W $1000, D1
            DIVU.W D1, D1
            DIVU.W (A1), D1
            DIVU.W #1, D1
            DIVU.W (A1)+, D1
            DIVU.W -(A1), D1
            DIVU.W $10000000, D1
            DIVU.W $1000, D1
            LEA.L (A1), A1
            LEA.L $10000000, A1
            LEA.L $1000, A1
            CLR.B D1
            CLR.B (A1)
            CLR.B (A1)+
            CLR.B -(A1)
            CLR.B $10000000
            CLR.B $1000
            CLR.W D1
            CLR.W (A1)
            CLR.W (A1)+
            CLR.W -(A1)
            CLR.W $10000000
            CLR.W $1000
            CLR.L D1
            CLR.L (A1)
            CLR.L (A1)+
            CLR.L -(A1)
            CLR.L $10000000
            CLR.L $1000
            AND.B D1, D1
            AND.B D1, D1
            AND.B (A1), D1
            AND.B D1, (A1)
            AND.B (A1)+, D1
            AND.B D1, (A1)+
            AND.B -(A1), D1
            AND.B D1, -(A1)
            AND.B $10000000, D1
            AND.B D1, $10000000
            AND.B $1000, D1
            AND.B D1, $1000
            AND.W D1, D1
            AND.W D1, D1
            AND.W (A1), D1
            AND.W D1, (A1)
            AND.W (A1)+, D1
            AND.W D1, (A1)+
            AND.W -(A1), D1
            AND.W D1, -(A1)
            AND.W $10000000, D1
            AND.W D1, $10000000
            AND.W $1000, D1
            AND.W D1, $1000
            AND.L D1, D1
            AND.L D1, D1
            AND.L (A1), D1
            AND.L D1, (A1)
            AND.L (A1)+, D1
            AND.L D1, (A1)+
            AND.L -(A1), D1
            AND.L D1, -(A1)
            AND.L $10000000, D1
            AND.L D1, $10000000
            AND.L $1000, D1
            AND.L D1, $1000
            ANDI.B #1, D1
            ANDI.B #1, $10000000
            ANDI.B #1, $1000
            ANDI.W #1, D1
            ANDI.W #1, $10000000
            ANDI.W #1, $1000
            ANDI.L #1, D1
            ANDI.L #1, $10000000
            ANDI.L #1, $1000
            EOR.B D1, D1
            EOR.B D1, $10000000
            EOR.B D1, $1000
            EOR.W D1, D1
            EOR.W D1, $10000000
            EOR.W D1, $1000
            EOR.L D1, D1
            EOR.L D1, $10000000
            EOR.L D1, $1000
            EORI.B #1, D1
            EORI.B #1, $10000000
            EORI.B #1, $1000
            EORI.W #1, D1
            EORI.W #1, $10000000
            EORI.W #1, $1000
            EORI.L #1, D1
            EORI.L #1, $10000000
            EORI.L #1, $1000
            ASR.B D1, D2
            ASR.W D1, D2
            ASR.L D1, D2
            ASR.B #1, D2
            ASR.W #1, D2
            ASR.L #1, D2
            LSL.B D1, D2
            LSL.W D1, D2
            LSL.L D1, D2
            LSL.B #1, D2
            LSL.W #1, D2
            LSL.L #1, D2
            ROL.B D1, D2
            ROL.W D1, D2
            ROL.L D1, D2
            ROR.B D1, D2
            ROR.W D1, D2
            ROR.L D1, D2
            BCHG.B D1, (A1)
            BCHG.B D1, (A1)+
            BCHG.B D1, -(A1)
            BCHG.B D1, $10000000
            BCHG.B D1, $1000
            BCHG.L D1, D1
            BCHG.B #1, (A1)
            BCHG.B #1, (A1)+
            BCHG.B #1, -(A1)
            BCHG.B #1, $10000000
            BCHG.B #1, $1000
            CMP.B D1, D1
            CMP.B (A1), D1
            CMP.B #1, D1
            CMP.B (A1)+, D1
            CMP.B -(A1), D1
            CMP.B $10000000, D1
            CMP.B $1000, D1
            CMP.W D1, D1
            CMP.W A1, D1
            CMP.W (A1), D1
            CMP.W #1, D1
            CMP.W (A1)+, D1
            CMP.W -(A1), D1
            CMP.W $10000000, D1
            CMP.W $1000, D1
            CMP.L D1, D1
            CMP.L A1, D1
            CMP.L (A1), D1
            CMP.L #1, D1
            CMP.L (A1)+, D1
            CMP.L -(A1), D1
            CMP.L $10000000, D1
            CMP.L $1000, D1
            CMPA.W D1, A1
            CMPA.W A1, A1
            CMPA.W (A1), A1
            CMPA.W #1, A1
            CMPA.W (A1)+, A1
            CMPA.W -(A1), A1
            CMPA.W $10000000, A1
            CMPA.W $1000, A1
            CMPA.L D1, A1
            CMPA.L A1, A1
            CMPA.L (A1), A1
            CMPA.L #1, A1
            CMPA.L (A1)+, A1
            CMPA.L -(A1), A1
            CMPA.L $10000000, A1
            CMPA.L $1000, A1
            CMPI.B #1, D1
            CMPI.B #1, $10000000
            CMPI.B #1, $1000
            CMPI.W #1, D1
            CMPI.W #1, $10000000
            CMPI.W #1, $1000
            CMPI.L #1, D1
            CMPI.L #1, $10000000
            CMPI.L #1, $1000
            JSR (A1)
            JSR $10000000
            JSR $1000
            RTS 

            STOP   #$7700          ; halt simulator

* Put variables and constants here

            END    START        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
