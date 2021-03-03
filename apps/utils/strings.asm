; **********************************************************************
; Miscelaneous string utilities
; **********************************************************************

; oswrch - write Char to screen
;
; on entry:
;   A   Character to write
;
; on exit:
;   X   preserved
;   Y   preserved
;
; This is simply an alias to the appropriate OS call so that we have a common
; name in code but platform independent. Name is based on the BBC OSWRCH
IF bbc
    oswrch = &FFEE  ; point to MOS routine
ELIF c64
;    oswrch = CHROUT  ; point to KERNAL routine
.oswrch
{
                        ; On the C64 upper & lower case are swapped so to get a
                        ; "normal" ASCII representation we need to swap the cases
                        ; so the display looks correct.
    PHA                 ; Preserve A
    CMP #'A'            ; <A then unchanged
    BMI end
    CMP #'Z'+1          ; A-Z then swap
    BMI swap
    CMP #'a'            ; < a then unchanged
    BMI end
    CMP #'z'+1          ; > z then unchanged
    BPL end
.swap
    EOR #&20            ; Swap case
.end
    JSR CHROUT          ; Write to OS with alphabet swapped if necessary
    PLA                 ; Restore A
    RTS
}
ENDIF

; writeString           writes a null terminated string pointed to by XY
;
; on entry:
;   X,Y Address of string           ; For writeString only
;
; on exit:
;   A   preserved
;   X   preserved
;   Y   invalid
.writeString
	STX stringPointer               ; store XY in stringPointer
	STY stringPointer+1             ; run through to writeStringAddress

; writeStringAddress    writes a null terminated string pointed to by stringPointer
;
; on exit:
;   A   preserved
;   X   preserved
;   Y   invalid
.writeStringAddress                 ; entry point when stringPointer already set
{
	PHA
	LDY #0
.loop
	LDA (stringPointer),Y
	BEQ end
	JSR oswrch
	INY
	BNE loop
.end
	PLA
	RTS
}

; strlen - length of a null terminated string
;
; on entry:
;   X,Y Address of string
;
; on exit:
;   A   length of string
;   X   preserved
;   Y   preserved
.strlen
{
	STX stringPointer
	STY stringPointer+1
	LDY #0
.loop
	LDA (stringPointer),Y
	BEQ end
	INY
	BNE loop
.end
    TYA
    LDY stringPointer+1
	RTS
}

; Write a space
.writeSpace
	LDA #' '
	JMP oswrch

;osnewl write a newline to the screen
IF c64
.osnewl
    LDA #13
    JMP CHROUT
ELSE
    ERROR "TODO not implemented"
ENDIF
