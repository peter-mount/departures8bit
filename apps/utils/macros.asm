; **********************************************************************
; Macros
; **********************************************************************

MACRO PHAXY
    PHA
    TXA
    PHA
    TYA
    PHA
ENDMACRO

MACRO PLAXY
    PLA
    TAY
    PLA
    TAX
    PLA
ENDMACRO

MACRO WRITESTRING text
    LDX #<text
    LDY #>text
    JSR writeString
ENDMACRO
