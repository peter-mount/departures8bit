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
IF c64
;oswrch = teletextWriteChar
;.oswrch
;{
;    PHA                 ; Preserve A
;    JSR fixcase         ; Fix C64 case
;    JSR CHROUT          ; Write to OS with alphabet swapped if necessary
;    PLA                 ; Restore A
;    RTS
;}

.fixcase                ; On the C64 upper & lower case are swapped so to get a
{                       ; "normal" ASCII representation we need to swap the cases
                        ; so the display looks correct.
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
    RTS
}

; ascii2petscii         C64 only, converts ASCII to PETSCII
; ascii2petsciiraw      C64 only, as ascii2petscii but does not fix case first
.ascii2petscii
    JSR fixcase         ; Ensure case is swapped before conversion
.ascii2petsciiraw
{
    CMP #64             ; 64-95 maps to 0-31
    BMI end             ; <64 no conversion
    CMP #95
    BPL skipUpperCase   ; not 65-95
.sub64
    SEC
    SBC #64
.end
    RTS
.skipUpperCase
    CMP #128            ; 96-127 maps to 95-95
    BPL skipLowerCase   ; Not lower case
    SEC
    SBC #32
    RTS
.skipLowerCase
    CMP #160            ; 160-191 maps to 96-127
    BMI end             ; 128-160 are not mappable
    CMP #192
    BMI sub64           ; convert 160-191
    CMP #255            ; 255 maps to 94
    BNE skip255
    SEC                 ; convert 192-254 to 64-126
    SBC #128
    RTS
.skip255
    LDA #94             ; 255 maps to 94
    RTS
}

ENDIF

; writeOuputBuffer      writes the output buffer to the screen
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