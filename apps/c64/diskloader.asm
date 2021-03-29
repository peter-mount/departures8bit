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

start = &0801                           ; Base of basic program
            ORG start-2                 ; Start 2 bytes earlier so we can inject the
            EQUW start                  ; load address for the prg file format

.L10                                    ; A = A + 1
            EQUW L15                    ; Pointer to next line
            EQUW 10                     ; Line 10
            EQUS 'A', EQUALS, 'A', PLUS, '1'
            EQUB 0                      ; End of line

.L15                                    ; IF A=1 THEN PRINT "LOADING, PLEASE WAIT!"
            EQUW L20                    ; Pointer to next line
            EQUW 15                      ; Line 5
            EQUS IF, 'A', EQUALS, '1'   ; Load TELETEXT emulator
            EQUS THEN, PRINT, '"', "LOADING, PLEASE WAIT!", '"'
            EQUB 0                      ; End of line


.L20                                    ; IF A=1 THEN LOAD "TELETEXT",8,1
            EQUW L30                    ; Pointer to next line
            EQUW 20
            EQUS IF, 'A', EQUALS, '1'   ; Load TELETEXT emulator
            EQUS THEN, LOAD, '"', "TELETEXT", '"', ",8,1"
            EQUB 0                      ; End of line

.L30                                    ; IF A=1 THEN SYS 49152
            EQUW L40                    ; Pointer to next line
            EQUW 30
            EQUS IF, 'A', EQUALS, '2'
            EQUS THEN, SYS, "49152"     ; Initialise screen, show splash 1
            EQUB 0                      ; End of line

.L40                                    ; IF A=1 THEN LOAD "DEPART",8,1
            ;EQUW L50                    ; Pointer to next line
            ;EQUW 40
            ;EQUS IF, 'A', EQUALS, '2'   ; Load application
            ;EQUS THEN, LOAD, '"', "DEPART", '"', ",8,1"
            ;EQUB 0                      ; End of line

.L50

.basicEnd
    EQUW 0                              ; pointer to next line, 0 = end of program

.end
    ; Save the program, start-2 to include the start address &0801
    SAVE "loader", start-2, end
