; **********************************************************************
; Commodore 64 program loader
; **********************************************************************
;
; This prefixes the program with a simple 1 line basic program to invoke
; the machine code.
;
    CPU     0       ; 6502
    GUARD   &A000   ; Guard to upper memory limit

start = &0801       ; Base of basic program
    ORG start-2     ; Start 2 bytes earlier so we can inject the load address
    EQUW start      ; Load address in prg file
{
    EQUW basicEnd   ; pointer to next line
    EQUW 10         ; line 10
    EQUB &9E, &20   ; SYS BASIC token followed by space
    EQUS "2304"     ; ASCII of entry point address 2304 = &0900
;    EQUS "4096"     ; ASCII of entry point address 4096 = &1000
    EQUB 0          ; End of line
.basicEnd
    EQUW 0          ; pointer to next line, 0 = end of program
}
    SKIPTO &0900    ; Skip to the next page
;    SKIPTO &1000
;   The program's entry point
.entryPoint
    JSR initScreen          ; Initialise the screen
    JSR welcome             ; Show the welcome screen
    JSR serialInit          ; Initialise RS232
    JSR connectAPI          ; Connect to API

    ;;JSR debug


    JSR outputReset         ; clear output buffer
    LDXY test               ; append test command
    JSR outputAppendString
    JSR outputTerminate
    JMP sendCommand


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
