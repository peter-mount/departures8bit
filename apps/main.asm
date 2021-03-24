; **********************************************************************
; Main - The main application entry point
; **********************************************************************

; Include the rest of the application
    INCLUDE "../utils/outputbuffer.asm"   ; Output buffer handling
    INCLUDE "../utils/screen.asm"         ; Screen handling
    INCLUDE "../utils/strings.asm"        ; String handling
    INCLUDE "../utils/welcome.asm"        ; Welcome page
    INCLUDE "../network/serial.asm"       ; RS232 handler
    INCLUDE "../network/dialer.asm"       ; WiFi Modem dialer
    INCLUDE "../network/api.asm"          ; Our API
    INCLUDE "../lang/lang.asm"            ; Our "language"
    INCLUDE "../lang/memviewer.asm"       ; Debug

.entryPoint
    JSR initScreen          ; Initialise the screen
    JSR welcome             ; Show the welcome screen
    JSR serialInit          ; Initialise RS232
    JSR dialServer          ; Connect to API server

    ;;JSR debug


    JSR outputReset         ; clear output buffer
    LDXY test               ; append test command
    JSR outputAppendString
    JSR outputTerminate
    JMP sendCommand

; Called at application end, free up resources
.cleanup
    JMP hangUp

.waitSecond                 ; wait loop for 1 second
{
IF c64                      ; C64 delay code
    LDX #75
.dialWait0
    LDA #&FF
.dialWait1
    CMP &d012               ; Wait for next frame
    BNE dialWait1
ENDIF
    RTS
}
.test
    EQUS "depart mde", 10, 0
.run EQUS "Running...", 0
