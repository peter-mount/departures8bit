; **********************************************************************
; Main - The main application entry point
; **********************************************************************

; Include the rest of the application
    INCLUDE "../utils/mathstr.asm"      ; Math string routines
    ;INCLUDE "../utils/outputbuffer.asm" ; Output buffer handling
    ;INCLUDE "../utils/prompt.asm"       ; Prompts
    INCLUDE "../utils/screen.asm"       ; Screen handling
    INCLUDE "../utils/strings.asm"      ; String handling
    INCLUDE "../utils/welcome.asm"      ; Welcome page
    ;INCLUDE "../network/serial.asm"     ; RS232 handler
    ;INCLUDE "../network/dialer.asm"     ; WiFi Modem dialer
    ;INCLUDE "../network/api.asm"        ; Our API
    INCLUDE "../lang/lang.asm"          ; Our "language"
    INCLUDE "../lang/memviewer.asm"     ; Debug

.entryPoint
IF bbc
    JSR initScreen          ; Initialise the screen
ELSE
    JSR initNetwork         ; Initialise RS232
ENDIF
    JSR welcome             ; Show the welcome screen
    JSR dialServer          ; Connect to API server

    ;;JSR debug

.mainMenu                   ; Entry point to show the main menu

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


; showPrompt        Show our prompt text at the top left of the screen
;
; on exit:
;   A   undefined
;   X   undefined
;   Y   undefined
;.showPrompt
;{
;    LDX #<prompt
;    LDY #>prompt
;    JMP writeString
;.prompt
;    EQUS 30, 134, "departureboards.mobi", 135, 0
;}
