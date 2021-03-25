; **********************************************************************
; Macros
; **********************************************************************

; Push A,X,Y to stack
; A is undefined after this operation on the 6502, preserved on the 65C02
MACRO PHAXY
IF bbcmaster
    PHA
    PHX
    PHY
ELSE
    PHA
    TXA
    PHA
    TYA
    PHA
ENDIF
ENDMACRO

; Pull A,X,Y from the stack, used after PHAXY
MACRO PLAXY
IF bbcmaster
    PLY
    PLX
    PLA
ELSE
    PLA
    TAY
    PLA
    TAX
    PLA
ENDIF
ENDMACRO

; Push X,Y to stack
; A is undefined after this operation on the 6502, preserved on the 65C02
MACRO PHXY
IF bbcmaster
    PHX
    PHY
ELSE
    TXA
    PHA
    TYA
    PHA
ENDIF
ENDMACRO

; Pull X,Y from the stack, used after PHXY
; A is undefined after this operation on the 6502, preserved on the 65C02
MACRO PLXY
IF bbcmaster
    PLY
    PLX
ELSE
    PLA
    TAY
    PLA
    TAX
ENDIF
ENDMACRO

; Load X,Y with 16 bit value addr
MACRO LDXY addr
    LDX #<addr
    LDY #>addr
ENDMACRO

; Store X,Y at addr
MACRO STXY addr
    STX addr
    STY addr+1
ENDMACRO

; Convenience to writeString
MACRO WRITESTRING text
    LDX #<text
    LDY #>text
    JSR writeString
ENDMACRO

; Convenience to showStatus
MACRO SHOWSTATUS text
    LDX #<text
    LDY #>text
    JSR showStatus
ENDMACRO
