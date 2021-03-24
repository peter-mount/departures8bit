; ********************************************************************************
; Dialer - handles hanging up and dialing the server using the WiFi modem
; ********************************************************************************

; hangUp            Disconnect from remote server
.hangUp
    JSR serialStart                 ; Start serial comms

    SHOWSTATUS resetModemText
    LDY #0                          ; Reset modem
    JSR dialImpl
    JMP serialEnd                   ; End serial comms

; dialServer        Dial remote server
.dialServer
    JSR hangUp
    JSR serialStart                 ; Start serial comms

    SHOWSTATUS dialingServerText    ; Dial server
    LDY #dialSequence-resetSequence
    JSR dialImpl

    SHOWSTATUS connectedText        ; Show we are connected
    JMP serialEnd                   ; End serial comms

.resetModemText
    EQUS "Resetting modem...", 0

.dialingServerText
    EQUS "Dialing server...", 0

.connectedText
    EQUS "Connected", 0

; TODO add proper parsing of response from modem, e.g. OK or CONNECTED strings
; 0 = end a sequence
; 1 = 1s delay
; 2 = 0.1s delay
.resetSequence
    EQUS "+++", 1                           ; send break then wait 1s, delay is part of Hayes protocol
    EQUS "ATH", 13, 10, 2                   ; hang up any connection wait sub second for OK
    EQUS "ATZ", 13, 10, 2, 0                ; reset modem, wait sub second
    EQUB 0                                  ; end resetModem sequence
.dialSequence
    EQUS "ATDTlocalhost:10232", 13, 10      ; dial server
    EQUB 1                                  ; wait 1s for CONNECTED response
    EQUB 0

.dialImpl
{
    LDA resetSequence,Y
    BNE dial2                       ; Finish when we hit 0
    RTS

.dial2
    INY
    CMP #1                          ; A=1 then wait 1 second
    BEQ dialWaitSecond
    CMP #2                          ; A=2 then wait fraction second
    BEQ dailWait
IF c64
    JSR CHROUT                      ; write to serial port
ELSE
;    ERROR "TODO implement"
ENDIF
    CMP #10                         ; A=10 then wait for a short while
    BNE dialImpl

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
    JMP dialImpl                    ; return to main loop

ELIF bbc                            ; BBC delay code using MOS
    LDA #0
    LDX #1
.dialWait0
    STA currentStation              ; Store timer val
    STX currentStation+1
    STY tempChar                    ; Store Y
    STZ oswordWork                     ; Reset timer
    STZ oswordWork+1
    STZ oswordWork+2
    STZ oswordWork+3
    STZ oswordWork+4
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

    LDA oswordWork+1
    CMP currentStation+1
    BMI dialWait1
    LDA oswordWork
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
