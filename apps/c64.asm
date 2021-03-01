; **********************************************************************
; Commodore C64 departure boards
; **********************************************************************

    INCLUDE "c64/loader.asm"        ; Start of the C64
    INCLUDE "utils/zeropage.asm"    ; 3rd Zero page allocations
    INCLUDE "c64/kernal.asm"        ; OS constants - TODO remove?
    INCLUDE "utils/screen.asm"      ; Screen handling
    INCLUDE "utils/strings.asm"     ; String handling
    INCLUDE "utils/welcome.asm"     ; Welcome page
    INCLUDE "network/serial.asm"    ; RS232 handler

.end
    SAVE "../builds/depart.prg", start-2, end
