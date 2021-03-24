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
SUB     =   &26     ; SUB - CP/M end-of-file marker

; Protocol block structure
proto_blockNum      = 0                         ; Offset to block number, 1 byte
proto_blockCount    = proto_blockNum + 1        ; Number of blocks
proto_dataSize      = proto_blockCount + 1      ; Data size, 0-128
proto_blockData     = proto_dataSize + 1        ; Offset to start of block data
proto_blockSize     = proto_blockData + 128     ; Max 128 bytes for payload

; sendCommand Sends the command in outputBuffer to the server, waits
; for a response and sets it up
.sendCommand
    ;SHOWSTATUS sendingText
    SHOWSTATUS outputBuffer
    JSR serialStart         ; Start serial comms
    JSR serialSendOutput    ; Send command
    JSR serialWaitUntilSent
    JSR receiveData         ; Get response object
    JSR serialEnd           ; End serial comms
    JSR clearStatus         ; Clear status line
    JSR relocateLang        ; relocate received code
    JSR langExec            ; Run the response
    LDXY sendCommandComplete
    JMP showStatus
.sendCommandComplete EQUS "Complete",0
; receiveData       Receives data from the remote server and writes it
;                   into dataBase
.receiveData
{
    LDA #0                              ; Clear block counters
    STA curBlock                        ; curBlock = 0
    STA numBlock                        ; numBlock = 0
    STA dataBase                        ; Wipe the dataBase by resetting the next record
    STA dataBase+1                      ; address to 0 as end of program
    STA dataBase+2                      ; Set command to TokenNoResponse

    LDA #<dataBase                      ; Reset dataPos
    STA dataPos
    LDA #>dataBase
    STA dataPos+1

    JSR serialStart                     ; Start serial comms

    LDA #NAK                            ; Send initial NAK, based on XModem protocol
    JSR serialSendChar
    JSR serialWaitUntilSent
    JMP loopLastBlock                   ; treat first block as if it failed,

.loopNextBlock
    INC curBlock                        ; Increment curBlock by 1
    LDA curBlock                        ; Exit if we have all blocks
    CMP numBlock
    BPL loopEnd
.loopLastBlock                          ; entry point when expecting the existing block after NAK
    JSR receiveBlock
                                        ; TODO check block is valid here & NAK if not

    LDA outputBuffer+proto_blockCount   ; Store num blocks. This should be static but doing this for every block
    STA numBlock                        ; is shorter code & allows for dynamic feeds if we need it

    LDX outputBuffer+proto_dataSize     ; Copy proto_dataSize bytes to dataBase
    LDY #0
.copyLoop
    LDA outputBuffer+proto_blockData,Y  ; Copy from payload in outputBuffer
    STA (dataPos),Y
    INY
    DEX
    BNE copyLoop

    CLC                                 ; Increment dataPos by proto_dataSize
    LDA dataPos
    ADC outputBuffer+proto_dataSize
    STA dataPos
    LDA dataPos+1
    ADC #0
    STA dataPos+1

.sendAck                                ; Send ACK to confirm this block is valid
    LDA #ACK
    JSR serialSendChar
    JSR serialWaitUntilSent
    JMP loopNextBlock                   ; Get the next block

.loopEnd
    JMP serialEnd                       ; End serial comms
}

; receiveBlock      Receive a block from the remote
.receiveBlock
{
    JSR receiveShowStatus

.waitForSOH                             ; Wait for initial SOH
IF c64
    JSR serialGetChar                   ; Read byte
ELSE
;    ERROR "TODO implement"
ENDIF
    CMP #SOH                            ; Loop until we get SOH
    BNE waitForSOH

    JSR outputReset                     ; reset to receive block
    LDY #proto_blockData                ; read block header
    JSR receiveBlockImpl

    LDY outputBuffer+proto_dataSize     ; Read in the remainder of the block
    JSR receiveBlockImpl
                                        ; TODO add CRC check here

.receiveEnd
    CLC                                 ; mark as ok
    RTS

.receiveBlockImpl                       ; receive X chars
    TYA                                 ; Save Y
    PHA
IF c64
    JSR serialGetChar
ELSE
;    ERROR "TODO implement"
ENDIF
    JSR outputAppend                    ; append to buffer
    PLA                                 ; Restore Y
    TAY
    DEY                                 ; Decrement & loop until we have the required number
    BNE receiveBlockImpl                ; of characters
    RTS
}


; receiveShowStatus Shows progress in status bar
.receiveShowStatus
{
    JSR outputReset                     ; Form status text
    LDXY receiveText
    JSR outputAppendString
    LDA curBlock                        ; curBlock in hex
    BEQ noBlock                         ; Don't show initial block 0
    JSR outputAppendHexChar
    LDA #'/'
    JSR outputAppend
    LDA numBlock                        ; numBlock in hex
    JSR outputAppendHexChar
.noBlock
    JSR outputTerminate                 ; terminate & show new status line
    LDXY outputBuffer
    JMP showStatus

.receiveText
    EQUS "Receiving ", 0
}
