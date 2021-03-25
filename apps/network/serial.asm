; **********************************************************************
; Serial port
; **********************************************************************
;
; This provides routines to setup and send/receive packets over the
; serial port.
;

; serialInit    Initialise the serial port
.serialInit
IF c64
SERIAL_LOGICAL_FILE = 2         ; Logical file number
SERIAL_TRUE_FILE    = 2         ; 2 = RS232
SERIAL_COMMAND      = 3         ; Command
{
    LDA #&00                    ; Setup RS232 buffers to upper memory
    STA RIBUF                   ; This prevents Kernal allocating memory inside our
    STA ROBUF                   ; own buffers causing crashes
    LDA #>rs232InputBuffer
    STA RIBUF+1
    LDA #>rs232OutputBuffer
    STA ROBUF+1

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
    EQUB &08  ; 1200 8N1
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
    PHAXY

    LDA #&02                        ; Use keyboard for input but listen to serial port
    LDX #2
    LDY #0
    JSR osbyte

    LDA #&B5                        ; RS423 input taken as raw data, default but enforce it
    LDX #1
    LDY #0
    JSR osbyte

    LDA #&CC                        ; lets serial data enter the input buffer
    LDX #0
    LDY #0
    JSR osbyte

    PLAXY
    RTS

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
    STX stringPointer           ; Store pointer to data block
    STY stringPointer+1
    TAX                         ; Block size to X
    LDY #0                      ; Index of char in buffer
.loop
    LDA (stringPointer),Y
    JSR serialSendChar
    INY                         ; Next char if any
    DEX
    BNE loop                    ; Loop until complete
    RTS
}

; serialSendChar        Send character to serial
IF c64
serialSendChar = CHROUT                  ; Send to serial
ELIF bbc
.serialSendChar
{
IF bbcmaster
    PHAXY                               ; Save registers, 65c02 has phx etc so A unchanged
ELSE
    STA serialChar                      ; Save A
    PHAXY                               ; Save registers
    LDA serialChar                      ; Restore A
ENDIF
    TAY                                 ; Send to serial buffer
    LDA #$8A                            ; Insert into buffer 2
    LDX #2
    JSR osbyte

    PLAXY                               ; Restore registers
    BCS serialSendChar                  ; Buffer was full so try again
}

;    ERROR "TODO Not implemented"
ENDIF

; serialGetChar         Get character from serial
.serialGetChar
IF c64
; From https://modelrail.otenko.com/electronics/commodore-64-fixing-rs-232-serial-limitations
; don't use GETIN as it screws up 0's. Instead check for data then direct read from kernal
{
    JSR &F14E
    TAX                         ; Save received char
    LDA &0297                   ; Is RS232 input buffer empty
    AND #&08
    BNE serialGetChar           ; No char available
    TXA                         ; Get returned character
    RTS
}
ELIF bbc
{
    PHXY                        ; Save X & Y
.loop
    LDA #&91                    ; Read character from buffer
    LDX #1                      ; RS423 input buffer
    JSR osbyte
    BCS loop                    ; No data read so loop
    STY serialChar              ; Result in Y
    PLXY                        ; Restore X & Y
    LDA serialChar              ; get result
    RTS
}
ENDIF

; serialEnd     End serial operation
.serialEnd
    PHAXY
IF c64
    LDX #3                      ; Select Screen for output
    JSR CHKOUT
    LDX #0                      ; Select Keyboard for input
    JSR CHKIN
ENDIF
    PLAXY
    RTS

.serialStart
    PHAXY
IF c64
    LDX #SERIAL_LOGICAL_FILE    ; Select serial
    JSR CHKOUT
    LDX #SERIAL_LOGICAL_FILE    ; Select serial
    JSR CHKIN
ELIF bbc
;    ERROR "TODO Not implemented"
ENDIF
    PLAXY
    RTS

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
