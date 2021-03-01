; **********************************************************************
; Commodore C64 departure boards
; **********************************************************************

    INCLUDE "c64/loader.asm"    ; Must be first
    INCLUDE "c64/welcome.asm"   ; Must be second as this holds our entry point
    INCLUDE "utils/zeropage.asm"
    INCLUDE "c64/kernal.asm"
    INCLUDE "utils/screen.asm"
    INCLUDE "utils/strings.asm"

.end
    SAVE "../builds/depart.prg", start-2, end
