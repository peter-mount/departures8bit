; **********************************************************************
; Common screen routines
; **********************************************************************

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

IF bbc
; Disable the flashing cursor
.disableCursor
    LDX #1                  ; Disable cursor
    LDY #0
    JMP vdu23

; Enable the flashing cursor
.enableCursor
    LDX #1                  ; Enable cursor
    LDY #1
    JMP vdu23

; vdu23 handles simple flag settings
;
; Equivalent to VDU 23,X,Y;0;0;0
;
.vdu23
{
    LDA #23                 ; VDU 23,X,Y;0;0;0
    JSR oswrch
    TXA
    JSR oswrch
    TYA
    JSR oswrch
    LDY #7                  ; Remaining 7 bytes are 0
    LDA #0
.vdu23Loop
    JSR oswrch
    DEY
    BNE vdu23Loop
    RTS
}
ENDIF
