; **********************************************************************
; Debugging utilities
; **********************************************************************

.debug
{
    ;JSR waitSecond ;; to prevent RS232NET: Error - Error writing: 32.
    PHAXY
    JSR receiveBlock

    LDX #<inputBuffer
    LDY #>inputBuffer
    JSR strlen
    CMP #0
    BEQ end

    PHAXY
    WRITESTRING debugText
    PLAXY

    JSR writeString
;    WRITESTRING inputBuffer
    LDA #33
    JSR oswrch
    JSR osnewl
.end
    PLAXY
    RTS
.debugText EQUS "Debug:",0
}

.debugChar
{
    STA tempA
    PHAXY
    LDA tempA
    JSR debugHex
    LDA tempA
    LSR A
    LSR A
    LSR A
    LSR A
    JSR debugHex
    PLAXY
    RTS
.debugHex
    AND #&0F
    TAY
    LDA lookup,Y
    JMP oswrch
.lookup EQUS "0123456789ABCDEF"
}

.debugReg
{
    STA tempAddr+2
    STX tempAddr+1
    STY tempAddr
    PHAXY
    LDA &B6
    STA tempAddr+4
    LDA &AA
    STA tempAddr+3

    LDY #2+2
.l1
    LDA tempAddr,Y
    JSR debugChar
    JSR writeSpace
    DEY
    BPL l1
    JSR osnewl
    PLAXY
    RTS
}