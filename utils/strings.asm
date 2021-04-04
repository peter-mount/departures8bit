; **********************************************************************
; Miscelaneous string utilities
; **********************************************************************

; writeOuputBuffer      writes the output buffer to the screen
IF c64
    JMP writeString                 ; Call routine in teletext module
ELSE
.writeOutputBuffer
    LDXY outputBuffer
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
ENDIF

; strlen - length of a null terminated string
;
; on entry:
;   X,Y Address of string
;
; on exit:
;   A   length of string
;   X   preserved
;   Y   undefined
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
	RTS
}

; Write a space
.writeSpace
	LDA #' '
	JMP oswrch

; Subroutine to print a byte in A in hex form (destructive)
; Based on PRBYTE from the Apple 1 monitor written by Woz
.writeHex
{
    PHA				        ; Save A for LSD
    LSR A
    LSR A
    LSR A
    LSR A		            ; MSD to LSD position
    JSR writeHexChar		; Output hex digit
    PLA				        ; Restore A
                            ; Fall through to print hex routine
.writeHexChar
    AND #%00001111			; Mask LSD for hex print
    ORA #'0'			    ; Add "0"
    CMP #'9'+1			    ; Is it a decimal digit?
    BCC writeHexCharEcho	; Yes! output it
    ADC #6				    ; Add offset for letter A-F
.writeHexCharEcho
    JMP oswrch
}