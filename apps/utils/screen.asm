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
    STXY stringPointer      ; Save text location

IF bbc
baseLine = &7C00 + (24*40)  ; Address of first char on screen
    JSR switchShadowRam
ENDIF

IF c64
baseLine = &0400 + (24*40)  ; Address of first char
ENDIF

    LDX #39                 ; Max chars to write
    LDY #0
.loop
    LDA (stringPointer),Y   ; Next char
    BEQ endOfString         ; End of string

IF c64
    JSR ascii2petscii       ; Convert to petscii
ENDIF

    STA baseLine,Y
    INY
    DEX
    BNE loop                ; Loop until we hit max chars
.endStatus
IF bbcmaster
    BRA switchMainRam       ; BBC Master switch back to main ram
ELSE
    RTS                     ; All others just exit
ENDIF
; Clear status clears the status line
.*clearStatus
    LDX #39                 ; Max chars to write
    LDY #0
.endOfString
    LDA #' '                ; Clear rest of line
.loop1
    STA baseLine,Y
    INY
    DEX
    BNE loop1               ; loop for next space
}
IF bbcmaster
; switchMainRam uses main ram   *** MUST follow showStatus **
.switchMainRam
    LDA #&6C
    LDX #0                  ; 0 = main ram
    JMP osbyte
ELSE
    RTS                     ; All others just exit
ENDIF

IF bbcmaster

; switchShadowRam uses shadow ram
.switchShadowRam
    LDA #&6C
    LDX #1                  ; 1 = shadow ram
    JMP osbyte

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
