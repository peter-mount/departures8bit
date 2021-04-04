; **********************************************************************
; Commodore 64 disk loader
; **********************************************************************
;
; This is the first file on disk and does the following
;
; Load & initialise the teletext driver
; Load splash page & display it
; Load the appliction & run it
;
; **********************************************************************
            INCLUDE "basictokens.asm"

start = &0801                                   ; Base of basic program
            ORG start-2                         ; Start 2 bytes earlier so we can inject the
            EQUW start                          ; load address for the prg file format

.L10        ; A=A+1
            EQUW L20                            ; Pointer to next line
            EQUW 10                             ; Line 10
            EQUS 'A', BASTOKEN_EQUALS, 'A', BASTOKEN_PLUS, '1'
            EQUB 0                              ; End of line

.L20        ; IF A=1 THEN PRINT "LOADING BOOTSTRAP"
            EQUW L20
            EQUW 20
            EQUS BASTOKEN_IF, 'A', BASTOKEN_EQUALS, '1'
            EQUS BASTOKEN_THEN, BASTOKEN_PRINT
            EQUS BASTOKEN_QUOTE, "LOADING BOOTSTRAP", BASTOKEN_QUOTE
            EQUB 0


.L30        ; IF A=1 THEN LOAD "BOOTSTRAP",8,1
            EQUW L40
            EQUW 30
            EQUS BASTOKEN_IF, 'A', BASTOKEN_EQUALS, '1'
            EQUS BASTOKEN_THEN, BASTOKEN_LOAD
            EQUS BASTOKEN_QUOTE, "BOOTSTRAP", BASTOKEN_QUOTE, ",8,1"
            EQUB 0

.L40        ; IF A=2 THEN SYS 28672 (&7000)
            EQUW basicEnd
            EQUW 40
            EQUS BASTOKEN_IF, 'A', BASTOKEN_EQUALS, '2'
            EQUS BASTOKEN_THEN
            EQUS BASTOKEN_SYS, "28672"
            EQUB 0

.basicEnd   EQUW 0  ; pointer to next line, 0 = end of program

.end
    ; Save the program, start-2 to include the start address &0801
    SAVE "loader.prg", start-2, end
