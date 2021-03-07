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

    LDA #23         ; Select mixed case font
    STA &D018
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
ELSE
    RTS             ; not C64 or BBC so ignore
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
    LDA #12         ; VDU 12
    JMP oswrch
ELSE
    RTS             ; not C64 or BBC so ignore
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
    RTS             ; not C64 or BBC so ignore
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
ELSE
    RTS             ; not C64 or BBC so ignore
ENDIF

; showStatus        Shows status line at bottom
;
; on entry:
;   XY  Address of status text, 0 terminated
;
; on exit:
;   A   undefined
;   X   undefined
;   Y   undefined
.showStatus
{
IF c64
baseLine = &0400 + (24*40)  ; Address of first char
    STXY stringPointer      ; Save text location
;    SEC                     ; Get current cursor position
;    JSR PLOT
;    STXY tempAddr           ; Save it for later
;
;    LDX #24                 ; Bottom row
;    LDY #0                  ; Column 0
;    CLC                     ; Set cursor position
;    JSR PLOT

    LDX #39                 ; Max chars to write
    LDY #0
.loop
    LDA (stringPointer),Y   ; Next char
    BEQ endOfString         ; End of string
    JSR ascii2petscii       ; Convert to petscii
    STA baseLine,Y
;    JSR oswrch              ; Write char converting to PETSCI as required
    INY
    DEX
    BNE loop                ; Loop until we hit max chars
.endStatus
    RTS
;    LDXY tempAddr           ; Now restore the original cursor position
;    SEC                     ; Get current cursor position
;    JMP PLOT                ; End routine
.endOfString
    LDA #' '                ; Clear rest of line
.loop1
    STA baseLine,Y
    INY
;    JSR CHROUT              ; write to screen, no need for PETSCI conversion here
    DEX
    BNE loop1               ; loop for next space
    BEQ endStatus           ; BRA but valid here as X is zero
ELSE
    ERROR "TODO implement"
ENDIF
}
