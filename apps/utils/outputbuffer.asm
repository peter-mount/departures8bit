; **********************************************************************
; Output buffer
; **********************************************************************

; outputReset - reset output buffer
;
; on exit:
;   A   undefined
;   X   preserved
;   Y   current buffer size
.outputReset
    LDA #0                              ; Set length to 0
    STA outputLength
    STA outputBuffer                    ; Terminate buffer
    RTS

; outputTerminate   Terminate output with 0
;
; on exit:
;   A   undefined
;   X   preserved
;   Y   current buffer size
.outputTerminate
    LDA #0
    LDY outputLength
    STA outputBuffer,Y
    RTS

; outputAppendHexChar Append A to buffer in hex
;
; on entry:
;   A   value to append
;
; on exit:
;   A       preserved
;   X       preserved
;   Y       preserved
;   tempA   value of A
.outputAppendHexChar
{
    STA tempA
    PHAXY
    LDA tempA
    LSR A
    LSR A
    LSR A
    LSR A
    JSR appendHex
    LDA tempA
    JSR appendHex
    PLAXY
    RTS
.lookup EQUS "0123456789ABCDEF"
.appendHex
    AND #&0F                        ; mask lower nibble
    TAY
    LDA lookup,Y                    ; A from lookup table, run through to outputAppend
}

; outputAppend Append a to outputBuffer
;
; on entry:
;   A   byte to append
;
; on exit:
;   A   preserved
;   X   preserved
;   Y   current buffer size
.outputAppend
    LDY outputLength
    STA outputBuffer,Y
    INY
    STY outputLength
    RTS

; outputAppendString - Append string to output
;
; on entry:
;   X,Y Address of string to append
;
; on exit:
;   A   undefined
;   X   undefined
;   Y   undefined
.outputAppendString
{
	STX stringPointer               ; Store string address
	STY stringPointer+1
	LDY #0                          ; start at string start
	LDX outputLength                ; append index
.loop
	LDA (stringPointer),Y           ; Read until 0
	BEQ end
    STA outputBuffer,X              ; Store in buffer
	INY                             ; next src index
	BEQ end
	INX                             ; next dest index
	BNE loop                        ; looop until buffer end
.end
    STX outputLength                ; store new length
	RTS
}
