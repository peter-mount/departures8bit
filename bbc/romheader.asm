; ********************************************************************************
; * rom header for BBC Master 128 & BBC Model B
; ********************************************************************************

; ********************************************************************************
; ROM header
.romStart
    JMP language                    ; Language entry point - unused unless bit6 in rom type is set
    JMP serviceEntry                ; Service entry point
    EQUB %11000010                  ; ROM type: Service Entry, Language & 6502 cpu
    EQUB copyright-romStart
    EQUB 1                          ; Version
.title
    EQUS "DepartureBoards.mobi", 0
.version
    INCLUDE "version.asm"           ; Version date is the build date
.copyright
    EQUS 0, "(C)"                   ; Must start with 0 to be valid
    INCLUDE "copyright.asm"         ; Pulls in the build year
    EQUS " Area51.dev", 0
