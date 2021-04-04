; **********************************************************************

; Append 16-bit decimal number out outputBuffer
;
; On entry, tempAddr=number to print
;           pad=0 or pad character (eg '0' or ' ')
; On entry at PrDec16Lp1,
;           Y=(tempAddrber of digits)*2-2, eg 8 for 5 digits
; On exit,  A,X,Y,tempAddr,pad corrupted

.outputAppend16
{
    LDY #8                      ; Offset to powers of ten
.PrDec16Lp1
    LDX #&FF                    ; Start with digit=-1
    SEC
.PrDec16Lp2
    LDA tempAddr+0                   ; Subtract current tens
    SBC PrDec16Tens+0,Y
    STA tempAddr+0
    LDA tempAddr+1
    SBC PrDec16Tens+1,Y
    STA tempAddr+1

    INX
    BCS PrDec16Lp2              ; Loop until <0

    LDA tempAddr+0                   ;Add current tens back in
    ADC PrDec16Tens+0,Y
    STA tempAddr+0
    LDA tempAddr+1
    ADC PrDec16Tens+1,Y
    STA tempAddr+1

    TXA
    BNE PrDec16Digit            ; Not zero, print it
    LDA pad
    BNE PrDec16Print
    BEQ PrDec16Next             ; pad<>0, use it
.PrDec16Digit
    LDX #'0'                    ; No more zero padding
    STX pad
    ORA #'0'                    ; Print this digit
.PrDec16Print
    STY tempX                   ; Preserve Y
    JSR outputAppend            ; Append to outputBuffer
    LDY tempX                   ; Restore Y
.PrDec16Next
    DEY                         ; Loop for next digit
    DEY
    BPL PrDec16Lp1
    RTS

.PrDec16Tens    EQUW 1, 10, 100, 1000, 10000
}
