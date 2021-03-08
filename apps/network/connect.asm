; **********************************************************************
; Handles the basic connection handling
; **********************************************************************

; connectAPI            Connect to the remote server
.connectAPI
    JSR dialServer              ; Dial the remote server

;    JSR outputReset             ; clear output buffer
;    LDXY heloCmd                ; append heloCmd
;    JSR outputAppendString
;    JSR serialStart
;    JSR serialSendOutput        ; Send command
;    JSR serialWaitUntilSent     ; Wait for command to be sent
;    JSR debug
;    JSR serialEnd

    RTS     ; TODO implement response

.sendCommand
    SHOWSTATUS sendingText
    JSR serialStart         ; Start serial comms
    JSR serialSendOutput    ; Send command
    JSR serialWaitUntilSent
    JSR receiveData         ; Get response object
    JSR serialEnd           ; End serial comms
    JSR relocateLang        ; relocate received code
    RTS

.sendingText
    EQUS "Sending...", 0
.receivingText
    EQUS "Receiving...", 0

.heloCmd    EQUS "helo "
IF c64
            EQUS "C64"
ELIF bbc
            EQUS "BBC"
ENDIF
            EQUS 13, 0
