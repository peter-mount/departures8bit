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
; Basic code:
; 10 A=A+1
; 20 IF A=1 THEN LOAD "TELETEXT.PRG",8,1
; 30 IF A=2 THEN LOAD "SPLASH.PRG",8,1
; 40 IF A=3 THEN LOAD "DEPART.PRG",8,1
; **********************************************************************
; Actual code

; C64 basic tokens
EQUALS  = &B2                           ; = equality or assign value
IF      = &8B                           ; IF statement
LOAD    = &93                           ; LOAD statement
PLUS    = &AA                           ; + addition
SYS     = &9E                           ; SYS statement
THEN    = &A7                           ; THEN statement

start = &0801                           ; Base of basic program
            ORG start-2                 ; Start 2 bytes earlier so we can inject the
            EQUW start                  ; load address for the prg file format

.L10        EQUW L20                    ; Pointer to next line
            EQUW 10                     ; Line 10
            EQUS 'A', EQUALS, 'A', PLUS, '1'
            EQUB 0                      ; End of line

.L20        EQUW L30                    ; Pointer to next line
            EQUW 20
            EQUS IF, 'A', EQUALS, '1'
            EQUS THEN, LOAD, '"', "DEPART", '"', ",8,1"
            EQUB 0                      ; End of line

.L30
.basicEnd
    EQUW 0                              ; pointer to next line, 0 = end of program

.end
    ; Save the program, start-2 to include the start address &0801
    SAVE "loader", start-2, end

;01 08
;0b 08 0a 00 41 b2  41 aa 31 00            |......A.A.1.,...|
;2c 08 14 00 8b 20 41 b2 31 20 a7 20  93 20 22 54 45 4c 45 54  |. A.1 . . "TELET|
;00000020  45 58 54 2e 50 52 47 22  2c 38 2c 31 00 40 08 1e  |EXT.PRG",8,1.@..|
;00000030  00 8b 20 41 b2 32 20 a7  20 9e 20 34 39 31 35 32  |.. A.2 . . 49152|
;00000040  00 00 00 70                                       |...p|
