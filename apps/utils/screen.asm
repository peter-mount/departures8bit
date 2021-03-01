; **********************************************************************
; Common screen routines
; **********************************************************************

; clearScreen   Clears the screen
;
; on exit:
;   A   undefined
;   X   undefined
;   Y   preserved
.clearScreen
{
IF c64
    lda #&00    ; Set border to black
    sta &d020
    sta &d021
    tax             ; LDX #0
    lda #' '        ; Set screen to spaces
.loop
    STA &0400,X
    STA &0500,X
    STA &0600,X
    STA &0700,X
    DEX
    BNE loop
    LDX #0          ; Home the cursor
    LDY #0
    JMP setPos
ELIF bbc
    LDA #12
    JMP oswrch
ELSE
    rts             ; not C64 or BBC so ignore
ENDIF
}

; setPos    Sets position on screen
;
; on entry:
;   X   column
;   Y   row
;
; on exit:
;   A   preserved
;   X   undefined
;   Y   undefined
.setPos
{
IF c64
    PHA
    TXA
    PHA
    TYA
    TAX
    PLA
    TAX
    PLA
    JMP &FFF0
ELIF bbc
    PHA
    LDA #&1F
    JSR oswrch
    TXA
    JSR oswrch
    TYA
    JSR oswrch
    PLA
    RTS
ELSE
    rts             ; not C64 or BBC so ignore
ENDIF
}

