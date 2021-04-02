; **********************************************************************
; memviewer View memory dump
; **********************************************************************

; langDump  Shows "program" structure
.langDump
{
    JSR langStart               ; Point to the program start
    JSR memViewer
    LDA #0
    STA tempAddr
.l1
    JSR outputReset
    LDA curLine+1
    JSR outputAppendHexChar
    LDA curLine
    JSR outputAppendHexChar

    LDA #32
    JSR outputAppend

    LDY #1
    LDA (curLine),Y
    JSR outputAppendHexChar
    DEY
    LDA (curLine),Y
    JSR outputAppendHexChar

    LDA #32
    JSR outputAppend

    INY
    INY
    LDA (curLine),Y
    JSR outputAppendHexChar

    LDA #32
    JSR outputAppend

    JSR langGetToken
    JSR outputAppendHexChar

    JSR outputTerminate
    JSR writeOutputBuffer
    JSR osnewl

    JSR langNextLine
    BEQ end

    DEC tempAddr
    BNE l1
.end
    RTS
}

; memViewer Shows first &A0 bytes of dataBase for debugging
.memViewer
{
    LDA #31         ; Move cursor to line 1 on screen
    JSR oswrch
    LDA #0
    JSR oswrch
    LDA #1
    JSR oswrch

    LDA curLine
    STA tempAddr
    LDA curLine+1
    STA tempAddr+1
    LDA #20         ; no of lines to write
    STA tempChar
.l1
    JSR outputReset
    LDA tempAddr+1
    JSR outputAppendHexChar
    LDA tempAddr
    JSR outputAppendHexChar

    LDY #0
    LDX #8
.l2
    TYA
    PHA

    LDA #32
    JSR outputAppend

    PLA
    TAY
    LDA (tempAddr),Y
    JSR outputAppendHexChar

    INY
    DEX
    BNE l2

    LDA #32
    JSR outputAppend

    LDY #0
    LDX #8
.l3
    LDA (tempAddr),Y
    CMP #32
    BMI l4
    CMP #127
    BMI l5
.l4
    LDA #'.'
.l5
    STA tempA
    TYA
    PHA
    LDA tempA
    JSR outputAppend
    PLA
    TAY

    INY
    DEX
    BNE l3

    JSR outputTerminate
    WRITESTRING outputBuffer
    JSR osnewl

    CLC
    LDA tempAddr
    ADC #8
    STA tempAddr
    LDA tempAddr+1
    ADC #0
    STA tempAddr+1

    DEC tempChar
    BNE l1

    RTS
}
