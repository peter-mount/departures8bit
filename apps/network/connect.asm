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
.connect
IF c64
    EQUS "CONNECTING...", 13, 0
ELSE
    EQUS "Connecting...", 13, 0
ENDIF

.connected
IF c64
    EQUS "CONNECTED", 13, 0
ELSE
    EQUS "Connected", 13, 0
ENDIF
.cmdStart
IF c64
    EQUS "HELO C64", 13, 10
ELIF bbc
    EQUS "HELO BBC", 13, 10
ENDIF
.cmdEnd
}