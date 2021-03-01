; **********************************************************************
; Common screen routines
; **********************************************************************

; initScreen    Initialises the screen
.initScreen
IF c64
    LDA #&00        ; Set border to black
    STA &d020       ; Border colour
    STA &d021       ; Background colour
    LDA #COL_GREY1  ; Set text colour
    JSR setColour
                    ; fall through to clearScreen
ELIF bbcmaster
    LDA #22         ; VDU 22 to select screen mode
    JSR oswrch
    LDA #128+7      ; Mode 7 but using shadow ram
    JMP oswrch
ELIF bbc
    ; TODO this is for the bbcmaster
    LDA #22         ; VDU 22 to select screen mode
    JSR oswrch
    LDA #7          ; Mode 7 no shadow ram on BBC B
    JMP oswrch
ENDIF

; clearScreen   Clears the screen
;
; on exit:
;   A   undefined
;   X   undefined
;   Y   preserved
.clearScreen
{
IF c64
    JMP CLSR        ; Kernal clear screen
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
    PHA                 ; On C64 x is row & y is column but we use it the more
    TXA                 ; logical X for column & Y for row
    PHA                 ; So just swap them over
    TYA
    TAX
    PLA
    TAX
    PLA
    JMP PLOT
ELIF bbc
    PHA                 ; BBC uses VDU &1F,x,y to set the position
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

; setColour sets the current text colour
;
; on entry:
;   A   Colour code, platform dependent
;
; on exit:
;   A   undefined, preserved on C64
;   X   undefined, preserved on C64
;   Y   undefined, preserved on C64
.setColour
IF c64
    STA &0286       ; 0286 holds the current text colour
    RTS
ELIF bbc
    RTS             ; TODO define mode7 parameters here
ENDIF
