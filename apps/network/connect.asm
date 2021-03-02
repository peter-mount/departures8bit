; **********************************************************************
; Handles the basic connection handling
; **********************************************************************

; connectAPI            Connect to the remote server
.connectAPI
{
    LDX #<connect
    LDY #>connect
    JSR writeString

    JSR dialServer              ; Dial the remote server

    LDA #cmdEnd-cmdStart        ; Command length
    LDX #<cmdStart
    LDY #>cmdStart
    JSR serialSendBlock         ; SEND HELO

    LDX #<connected
    LDY #>connected
    JSR writeString
    RTS     ; TODO implement response
.connect    EQUS "Connecting...", 13, 0

.connected  EQUS "Connected", 13, 0
.cmdStart   EQUS "HELO "
IF c64
            EQUS "C64"
ELIF bbc
            EQUS "BBC"
ENDIF
            EQUB 13, 0
.cmdEnd
}