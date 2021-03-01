; **********************************************************************
; Miscelaneous string utilities
; **********************************************************************

; write Char to screen
;
; on entry:
;   A   Character to write
;
; on exit:
;   X   preserved
;   Y   preserved
IF bbc
    oswrch = &FFEE  ; point to MOS routine
ELIF c64
    oswrch = &FFD2  ; point to KERNAL routine
ENDIF

; writeString - writes a null terminated string
;
; on entry:
;   X,Y Address of string
;
; on exit:
;   A   preserved
;   X   preserved
;   Y   invalid
.writeString
	PHA
	STX stringPointer
	STY stringPointer+1
	LDY #0
.writeStringLoop
	LDA (stringPointer),Y
	BEQ writeStringEnd
	JSR oswrch
	INY
	BNE writeStringLoop
.writeStringEnd
	PLA
	RTS

; Write a space
.writeSpace
	LDA #' '
	JMP oswrch
