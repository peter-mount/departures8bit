; **********************************************************************
; Commodore C64 departure boards
; **********************************************************************

    INCLUDE "macros.asm"                ; Our macros
    INCLUDE "zeropage.asm"              ; 3rd Zero page allocations
    INCLUDE "c64/loader.asm"            ; Start of the C64
    INCLUDE "c64/kernal.asm"            ; OS constants - TODO remove?
    INCLUDE "main.asm"                  ; The core application

; end - the end of the saved program
.end

; outputBuffer starts on the C64 at the next page after end
    ALIGN &100
.outputBuffer                           ; 1 page for outputBuffer
    EQUB 0

; dataBase which holds the temporary data starts the next page after outputBuffer
    ALIGN &100
.dataBase                               ; First free block of memory
memTop  = &BFFF                         ; Upper bound of all free memory at end of Basic ROM on the C64

    ; Save the program, start-2 to include the start address &0801
    SAVE "../builds/depart.prg", start-2, end
