; **********************************************************************
; Serial port
; **********************************************************************
;
; This provides routines to setup and send/receive packets over the
; serial port.
;
    INCLUDE "network/connect.asm"   ; Connect API
    INCLUDE "network/dialer.asm"    ; WiFi Modem dialer
    INCLUDE "network/api.asm"       ; API calls

; serialInit    Initialise the serial port
.serialInit
IF c64
SERIAL_LOGICAL_FILE = 2         ; Logical file number
SERIAL_TRUE_FILE    = 2         ; 2 = RS232
SERIAL_COMMAND      = 3         ; Command
{
    LDA #SERIAL_LOGICAL_FILE    ; Logical file number 2 = RS232C
    LDX #SERIAL_TRUE_FILE       ; primary address 2 = RS232C
    LDY #SERIAL_COMMAND
    JSR SETLFS                  ; SETLFS Setup logical file

    LDA #nameEnd-name           ; Length of file name
    LDX #<name
    LDY #>name
    JSR SETNAM                  ; SETNAM Set name

    LDA #SERIAL_LOGICAL_FILE    ; Logical file number 2 = RS232C
    LDX #SERIAL_TRUE_FILE       ; primary address 2 = RS232C
    LDY #SERIAL_COMMAND         ; secondary address
    JMP OPEN                    ; OPEN
                    ; Filename formed of the serial parameters
.name
                    ; Control register - SWWxBBBB
                    ;
                    ; S 0=1 stop bit, 1=2 stop bits
                    ;
                    ; W word length
                    ; 00 8 bits
                    ; 01 7 bits
                    ; 10 6 bits
                    ; 11 5 bits
                    ;
                    ; B Baud rate
                    ; 0000 User Rate [NI]
                    ; 0001 59
                    ; 0010 75
                    ; 0011 110
                    ; 0100 134.5
                    ; 0101 150
                    ; 0110 300
                    ; 0111 600
                    ; 1000 1200
                    ; 1001 (1800) 2400
                    ; 1010 2400
                    ; 1011 3600     [NI]
                    ; 1100 4800     [NI]
                    ; 1101 7200     [NI]
                    ; 1110 9600     [NI]
                    ; 1111 19200    [NI]
    EQUB &0A  ; 2400 8N1
                    ; Command register - PPPDxxxH
                    ;
                    ; PPP Parity
                    ; xx0 Parity disabled
                    ; 001 Odd parity
                    ; 011 Even parity
                    ; 101 Mark transmitted check disabled
                    ; 111 Space transmitted parity check disabled
                    ;
                    ; D 0=full duplex, 1=half duplex
                    ; H Handshake, 0=3-line, 1=x-line
    EQUB &00  ; Full duplex, no parity, 3 line handshake
.nameEnd
}
ELIF bbc
    RTS                         ; TODO implement
ELSE
    RTS                         ; Unknown system
ENDIF

; serialSendOutput      Send outputBuffer
;
; on exit:
;   A   undefined
;   X   undefined
;   Y   undefined
.serialSendOutput
    LDA outputLength                ; Length of output buffer
    LDXY outputBuffer               ; Address of output buffer
                                    ; fall through into serialSendBlock

; serialSendBlock       Send block to serial
; on entry:
;   A   length of block
;   X,Y Address of block
;
; on exit:
;   A   undefined
;   X   undefined
;   Y   undefined
.serialSendBlock
{
    STA tempChar                ; Store parameters
    STX stringPointer
    STY stringPointer+1

    ;JSR serialOutStart          ; Begin serial operation

    LDX tempChar                ; Counter of chars to send
    LDY #0                      ; Index of char in buffer
.loop
    LDA (stringPointer),Y

IF c64
    JSR CHROUT                  ; Send to serial
ELIF bbc
    ERROR "TODO Not implemented"
ENDIF

    INY                         ; Next char if any
    DEX
    BNE loop                    ; Loop until complete then run into serialEnd

    LDA #10                     ; Line feed to end command
IF c64
    JSR CHROUT                  ; Send to serial
ELIF bbc
    ERROR "TODO Not implemented"
ENDIF
}                               ; Run into serialEnd
    RTS

; serialEnd     End serial operation
.serialEnd
    PHAXY
IF c64
    LDX #3                      ; Select Screen for output
    JSR CHKOUT
    LDX #0                      ; Select Keyboard for input
    JSR CHKIN
    ;JMP CLRCHN                 ; Reset I/O channels
ENDIF
    PLAXY
    RTS

.serialStart    JSR serialInStart
; serialOutStart   Begin serial output operations
.serialOutStart
IF c64
    LDX #SERIAL_LOGICAL_FILE    ; Select serial
    JSR CHKOUT
ELIF bbc
    ERROR "TODO Not implemented"
ENDIF
    RTS

; serialInStart   Begin serial input operations
.serialInStart
IF c64
    LDX #SERIAL_LOGICAL_FILE    ; Select serial
    JSR CHKIN
    RTS
ELIF bbc
    ERROR "TODO Not implemented"
ELSE
    RTS                         ; NO-OP
ENDIF

; serialWaitUntilSent           Waits until all characters have been transmitted
.serialWaitUntilSent
{
IF c64
    LDA &02A1                   ; If bit 1 is sent then wait until all chars transmitted
    AND #&01
    BNE serialWaitUntilSent
ENDIF
    RTS
}

; receiveBlock  Receive up to 256 bytes, terminated with \n into inputBuffer
.serialReceiveLine
{
    ;JSR serialInStart           ; Begin serial operation

    LDY #0
    STY tempA                   ; Counter to detect read timeout
.loop1
IF c64
    JSR GETIN                   ; Read from channel
    BCC loop2                   ; Carry clear means we have a char
    ;BEQ loopEnd
    ;;BNE loop2                   ; we have a char
    LDX tempA                   ; decrement counter
    DEX
    BEQ loopEnd                 ; timeout
    STX tempA
    JMP loop1
ELSE
    ERROR "TODO Not implemented"
ENDIF
.loop2
    CMP #13
    BEQ loopEnd
    CMP #' '                    ; Any control char terminates the line
    BMI loopEnd
    JSR oswrch
    STA inputBuffer,Y           ; Append to line
    INY
    BNE loop1                   ; next character
.loopEnd
    LDA #0                      ; append null
    STA inputBuffer,Y
    RTS ;JMP serialEnd               ; End serial operations
}
