; **********************************************************************
; api       The API used to talk with the remote server
; **********************************************************************

; XMODEM Control Character Constants
SOH		=	&01		; start block
EOT		=	&04		; end of text marker
ACK		=	&06		; good block acknowledged
NAK		=	&15		; bad block acknowledged
CAN		=	&18		; cancel (not standard, not supported)
CR		=	&0d		; carriage return
LF		=	&0a		; line feed
ESC		=	&1b		; ESC to exit

; receiveData       Receives data from the remote server and writes it
;                   into dataBase
.receiveData
{
    LDA #0                      ; Clear block counters
    STA curBlock                ; curBlock = 0
    STA curBlock+1
    STA curBlock+2              ; numBlock = 0
    STA curBlock+3
    STA dataBase                ; Wipe the dataBase
    STA dataBase+1

    LDA #<dataBase              ; Reset dataPos
    STA dataPos
    LDA #>dataBase
    STA dataPos+1

    JSR serialStart
    LDA #NAK                    ; Send initial NAK
    JSR serialSendChar
    JSR serialWaitUntilSent

    JSR receiveBlock            ; Get block 0
    LDA outputBuffer+3          ; Store num blocks
    STA numBlock
    LDA outputBuffer+4
    STA numBlock+1

.loop
    CLC                         ; Increment curBlock by 1
    LDA curBlock
    ADC #1
    STA curBlock
    LDA curBlock+1
    ADC #0
    STA curBlock+1

    JSR receiveBlock

    LDA #ACK                    ; Send ACK to confirm this block is valid
    JSR serialSendChar
    JSR serialWaitUntilSent

    LDA curBlock+1              ; Compare block received
    CMP numBlock+1              ; loop until we hit numBlock
    BMI loop                    ; Loop for next block
    LDA curBlock
    CMP numBlock
    BNE loop                    ; Loop for next block

.loopEnd
    JMP serialEnd

}

; receiveBlock      Receive a block from the remote
.receiveBlock
{
    ;JSR receiveShowStatus

    JSR outputReset             ; reset to receive block
    LDX #5                      ; Receive block header
    JSR receiveBlockImpl
    LDX outputBuffer+2          ; Get block length
    JSR receiveBlockImpl        ; & receive the data
    ; TODO add CRC check here

.receiveEnd
    CLC                         ; mark as ok
    RTS

.receiveBlockImpl               ; receive X chars
IF c64
    JSR GETIN
    BCS receiveBlockImpl        ; Loop until we get a char TODO add timeout
    JSR outputAppend
    DEX
    BNE receiveBlockImpl
ENDIF
    RTS
}


; receiveShowStatus Shows progress in status bar
.receiveShowStatus
{
    JSR outputReset             ; Form status text
    LDXY receiveText
    JSR outputAppendString
    LDA curBlock
    JSR outputAppendHexChar
    LDA #'/'
    JSR outputAppend
    LDA numBlock
    JSR outputAppendHexChar
    JSR outputTerminate
    SHOWSTATUS outputBuffer

.appendHex

.receiveText
    EQUS "Receiving ", 0
.lookup
    EQUS "0123456789ABCDEF"
}
