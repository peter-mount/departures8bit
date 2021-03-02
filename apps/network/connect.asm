; **********************************************************************
; Handles the basic connection handling
; **********************************************************************

; connectAPI            Connect to the remote server
.connectAPI
{
    WRITESTRING connect

    JSR dialServer              ; Dial the remote server

    LDA #0                      ; Helo
    LDX #<cmdStart              ; APP ID
    LDY #>cmdStart
    JSR sendCommand

    JSR debug

    WRITESTRING connected
    RTS     ; TODO implement response
.connect    EQUS "Connecting...", 13, 0

.connected  EQUS "Connected", 13, 0
.cmdStart
IF c64
            EQUS "C64", 0
ELIF bbc
            EQUS "BBC", 0
ENDIF
}