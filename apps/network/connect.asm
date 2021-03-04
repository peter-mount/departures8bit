; **********************************************************************
; Handles the basic connection handling
; **********************************************************************

; connectAPI            Connect to the remote server
.connectAPI
{
    WRITESTRING connect

    JSR dialServer              ; Dial the remote server

    JSR outputReset             ; clear output buffer
    LDXY heloCmd                ; append heloCmd
    JSR outputAppendString
    JSR serialStart
    JSR serialSendOutput        ; Send command
    JSR serialWaitUntilSent     ; Wait for command to be sent
    JSR debug
    JSR serialEnd

    WRITESTRING connected
    RTS     ; TODO implement response
.connect    EQUS "Connecting...", 13, 0

.connected  EQUS "Connected", 13, 0
.heloCmd    EQUS "helo "
IF c64
            EQUS "C64"
ELIF bbc
            EQUS "BBC"
ENDIF
            EQUS 13, 0
}