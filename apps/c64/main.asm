; **********************************************************************
; Commodore C64 departure boards
; **********************************************************************

    INCLUDE "../macros.asm"             ; Our macros
    INCLUDE "../zeropage.asm"           ; 3rd Zero page allocations
    INCLUDE "kernal.asm"                ; Kernal constants
    INCLUDE "loader.asm"                ; Start of the C64
    INCLUDE "../main.asm"               ; The core application

; end - the end of the saved program
.end

; Available memory for the received database.
; On the C64 this runs up to the end of the spare 4k block as we have
; paged the Basic rom out with ram
    ALIGN &100
.memBase                    ; First free block of memory
    EQUB 0
memTop              = &CDFF ; Upper bound of all free memory

rs232InputBuffer    = &CE00 ; RS232 input buffer, must be page aligned
rs232OutputBuffer   = &CF00 ; RS232 output buffer, must be page aligned

outputBuffer        = &0800 ; Output buffer overwrites the Basic loader

    ; Save the program, start-2 to include the start address &0801
    SAVE "depart.prg", start-2, end
