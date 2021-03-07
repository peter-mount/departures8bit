; **********************************************************************
; Commodore C64 departure boards
; **********************************************************************

    INCLUDE "utils/macros.asm"          ; Our macros
    INCLUDE "utils/zeropage.asm"        ; 3rd Zero page allocations
    INCLUDE "c64/loader.asm"            ; Start of the C64
    INCLUDE "c64/kernal.asm"            ; OS constants - TODO remove?
    INCLUDE "utils/outputbuffer.asm"    ; Output buffer handling
    INCLUDE "utils/screen.asm"          ; Screen handling
    INCLUDE "utils/strings.asm"         ; String handling
    INCLUDE "utils/welcome.asm"         ; Welcome page
    INCLUDE "network/serial.asm"        ; RS232 handler
    INCLUDE "network/connect.asm"       ; Connect API
    INCLUDE "network/dialer.asm"        ; WiFi Modem dialer
    ;INCLUDE "network/xmodem-6502.asm"   ; XModem protocol
    INCLUDE "network/api.asm"           ; Our API
    INCLUDE "utils/debug.asm"           ; Debugging
.end                                    ; End of the program

    ALIGN &100
;.workBase                               ; First free block of memory

    SAVE "../builds/depart.prg", start-2, end
