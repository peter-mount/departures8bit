; ********************************************************************************
; Dialer - handles hanging up and dialing the server using the WiFi modem
; ********************************************************************************

; dialServer        Dial remote server
.dialServer
{
IF c64
    LDX #2                          ; Select serial device
    JSR CHKOUT
ENDIF

    LDY #0                          ; Start dialing
.dial1
    LDA dialText,Y
    BNE dial2                       ; Finish when we hit 0

IF c64
    JMP CLRCHN                      ; Reset I/O channels
ELSE
    RTS                             ; we are connected (hopefully)
ENDIF

.dial2
    INY
    CMP #1                          ; A=1 then wait 1 second
    BEQ dialWaitSecond
    JSR CHROUT                      ; write to serial port
    CMP #10                         ; A=10 then wait for a short while
    BNE dial1

.dailWait                           ; wait 100 tics loop between commands
IF c64                              ; C64 delay code
    LDX #30                         ; Wait for 10 frames
    JMP dialWait0
ELIF bbc                            ; BBC delay code using MOS
    LDA #100
    LDX #0
    BRA dialWait0
ENDIF

.dialWaitSecond                     ; wait loop for 1 second

IF c64                              ; C64 delay code
    LDX #75
.dialWait0
    LDA #&FF
.dialWait1
    CMP &d012                       ; Wait for next frame
    BNE dialWait1
.dialWait2
    CMP &d012                       ; Wait until it hits next frame before changing else we'll be too quick
    BEQ dialWait2

    DEX                             ; Loop X times
    BNE dialWait0
    JMP dial1                       ; return to main loop

ELIF bbc                            ; BBC delay code using MOS
    LDA #0
    LDX #1
.dialWait0
    STA currentStation              ; Store timer val
    STX currentStation+1
    STY tempChar                    ; Store Y
    STZ tmpaddr                     ; Reset timer
    STZ tmpaddr+1
    STZ tmpaddr+2
    STZ tmpaddr+3
    STZ tmpaddr+4
    JSR writeTimer

.dialWait1
    LDA #&91                        ; Read character from buffer
    LDX #1                          ; RS423 input buffer
    JSR osbyte
    BCS dialWait2                   ; No data read so skip
    TYA                             ; Write received char to screen
    JSR oswrch

.dialWait2
    JSR readTimer

    LDA tmpaddr+1
    CMP currentStation+1
    BMI dialWait1
    LDA tmpaddr
    CMP currentStation
    BMI dialWait1                   ; Loop until timer hit

    LDY totalPages
    BRA dial1                       ; return to main loop

.readTimer
    LDA #3                          ; Read timer
    BRA readWriteTimer
.writeTimer
    LDA #4
.readWriteTimer
    LDX #<tmpaddr
    LDY #>tmpaddr
    JMP osword
ENDIF
}

.dialingText
IF c64
    EQUS "DIALING...", 13, 0
ELSE
    EQUS 12, 131, 157, 129, "Dialing...", 0
ENDIF

.dialText
    EQUS "+++", 1
    EQUS "ATH", 13, 10
    EQUS "ATZ", 13, 10
    EQUS "ATDTlocalhost:8082", 13, 10
    EQUB 0
