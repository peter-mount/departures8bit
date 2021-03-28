; ********************************************************************************
; Handle errors from BRK instructions.
;
; Errors raised with:
;   BRK
;   EQUB error code (unused)
;   EQUS error string
;   BRK or EQUB 0 to terminate string
; ********************************************************************************

.errorHandler
    LDX #&FF                        ; Reset the stack
    TXS

    LDA #&7C                        ; Clear escape condition
    JSR osbyte

    LDY #0
    LDA (brkAddress),Y              ; error code
    BEQ errorHandler4
    JSR writeHex
    JSR writeSpace
.errorHandler3
    INY                             ; Skip the error code
.errorHandler0
    LDA (brkAddress),Y
    BEQ errorHandler1               ; Found end
    JSR osascii
    INY
    BNE errorHandler0
.errorHandler1
    JSR osnewl                      ; Force newline
.errorHandler4
    JMP mainMenu                     ; Back to the main menu

.errEscape
    JSR osnewl                      ; Force newline
    BRK
    EQUS &11, "Escape", 0

.errSyntax
    BRK
    EQUS &12, "Syntax", 0
