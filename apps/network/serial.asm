; **********************************************************************
; Serial port
; **********************************************************************
;
; This provides routines to setup and send/receive packets over the
; serial port.
;
    INCLUDE "network/connect.asm"   ; Connect API
    INCLUDE "network/dialer.asm"    ; WiFi Modem dialer

; serialInit    Initialise the serial port
.serialInit
IF c64
{
    LDA #2
    TAX
    LDY #0
    JSR SETLFS                  ; SETLFS Setup logical file
    LDA #nameEnd-name           ; Length of file name
    LDX #<name
    LDY #>name
    JSR SETNAM                  ; SETNAM Set name
    LDA #2                      ; Logical file number 2 = RS232C
    LDX #2                      ; primary address 2 = RS232C
    LDY #0                      ; secondary address
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
    EQUB %00000000  ; Full duplex, no parity, 3 line handshake
.nameEnd
}
ELIF bbc
    RTS                         ; TODO implement
ELSE
    RTS                         ; Unknown system
ENDIF

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
    STA tempChar            ; Store parameters
    STX stringPointer
    STY stringPointer+1

IF c64
    LDX #2                  ; Select serial
    JSR CHKOUT
ELIF bbc
    ERROR "TODO Not implemented"
ENDIF

    LDX tempChar            ; Counter of chars to send
    LDY #0                  ; Index of char in buffer
.loop
    LDA (stringPointer),Y

IF c64
    JSR CHROUT              ; Send to serial
ELIF bbc
    ERROR "TODO Not implemented"
ENDIF

    INY                     ; Next char if any
    DEX
    BNE loop
    JMP CLRCHN              ; Reset I/O channels
}
