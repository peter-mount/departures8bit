; **********************************************************************
; Common screen routines - BBC specific
; **********************************************************************

; initScreen    Initialises the screen
.initScreen
    LDA #22                 ; VDU 22 to select screen mode
    JSR oswrch
IF bbcmaster
    LDA #128+7              ; Mode 7 but using shadow ram
ELSE
    LDA #7                  ; Mode 7 no shadow ram on BBC B
ENDIF
    JMP oswrch

; clearScreen   Clears the screen
;
; on exit:
;   A   undefined
;   X   undefined
;   Y   preserved
.clearScreen
    LDA #12                 ; VDU 12
    JMP oswrch

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
    PHA                     ; BBC uses VDU &1F,x,y to set the position
    LDA #&1F
    JSR oswrch
    TXA
    JSR oswrch
    TYA
    JSR oswrch
    PLA
    RTS
