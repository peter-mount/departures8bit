; **********************************************************************
; Handles the basic connection handling
; **********************************************************************

; connectAPI            Connect to the remote server
.connectAPI
{
    LDX #<connect
    LDY #>connect
    JSR writeString
    LDA #cmdEnd-cmdStart        ; Command length
    LDX #<cmdStart
    LDY #>cmdStart
    JSR serialSendBlock         ; SEND HELO
    RTS     ; TODO implement response
.connect
IF c64
    EQUS "CONNECTING...", 13, 0
ELSE
    EQUS "Connecting...", 13, 0
ENDIF
.cmdStart
    EQUS "HELO C64", 10
.cmdEnd
}