; **********************************************************************
; prompt.asm        Handles the prompt line at the top of the page
; **********************************************************************


; showPrompt        Show our prompt text at the top left of the screen
;
; on exit:
;   A   undefined
;   X   undefined
;   Y   undefined
.showPrompt
{
    LDXY prompt
    JMP writeString
.prompt
    EQUS 30, 134, "departureboards.mobi", 135, 0
}

; Position on top row of true status pane
statusX = 22

; clearStatus        Clears the status line
;
; on exit:
;   A   undefined
;   X   undefined
;   Y   undefined
{
.L0 EQUB 0
.*clearStatus               ; Clear the status line
    LDXY L0                 ; A simple empty status message, fall through to showStatus
}

; showStatus        Shows status line at top right of screen
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

    LDA #31                 ; Move cursor to 0,24
    JSR oswrch
    LDA #statusX
    JSR oswrch
    LDA #0
    JSR oswrch

    JSR L0

    LDA #31                 ; Move cursor to 0,1
    JSR oswrch
    LDA #0
    JSR oswrch
    LDA #1
    JMP oswrch

.L0 LDX #40-statusX         ; Max chars to write
    LDY #0
.L1 LDA (stringPointer),Y   ; Next char
    BEQ L2                  ; End of string

    JSR oswrch              ; Write char
    INY
    DEX
    BNE L1                  ; Loop until we hit max chars
    RTS
.L2 LDA #' '
.L3 JSR oswrch
    DEX
    BNE L3
    RTS
}
