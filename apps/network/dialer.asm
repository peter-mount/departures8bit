; ********************************************************************************
; Dialer - handles hanging up and dialing the server using the WiFi modem
; ********************************************************************************

; dialServer        Dial remote server
.dialServer
{
    JSR serialStart

    LDY #0                          ; Start dialing
.dial1
    LDA dialText,Y
    BNE dial2                       ; Finish when we hit 0

    JMP serialEnd

.dial2
    INY
    CMP #1                          ; A=1 then wait 1 second
    BEQ dialWaitSecond
IF c64
    JSR CHROUT                      ; write to serial port
ELSE
    ERROR "TODO implement"
ENDIF
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

.dialText
    EQUS "+++", 1, "ATH", 13, 10
    EQUS 1, "ATZ", 13, 10
    EQUS "ATDTlocalhost:10232", 13, 10
    EQUB 0
