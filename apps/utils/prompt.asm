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
    STXY stringPointer          ; Save text location

    LDX #<TX                    ; Move cursor to 21,0 & set white text
    LDY #>TX
    JSR writeString

    JSR L0

    LDX #<TE                    ; Move cursor to 0,1
    LDY #>TE
    JMP writeString

.L0 LDX #40-statusX             ; Max chars to write
    LDY #0
.L1 LDA (stringPointer),Y           ; Next char
    BEQ L2                      ; End of string

    JSR oswrch                  ; Write char
    INY
    DEX
    BNE L1                      ; Loop until we hit max chars
    RTS
.TX EQUB 31,statusX-1,0,135,0   ; TAB(21,0), WhiteText
.TE EQUB 31,0,1,0               ; TAB(0,1)

.L2 LDA #' '
.L3 JSR oswrch
    DEX
    BNE L3
    RTS
}
