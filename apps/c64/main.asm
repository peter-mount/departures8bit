; **********************************************************************
; Commodore C64 departure boards
; **********************************************************************

    INCLUDE "../macros.asm"             ; Our macros
    INCLUDE "../zeropage.asm"           ; 3rd Zero page allocations
    INCLUDE "kernal.asm"                ; Kernal constants
    INCLUDE "loader.asm"                ; Start of the C64
    INCLUDE "charset.asm"               ; Teletext char set
    INCLUDE "teletext.asm"              ; Teletext
    INCLUDE "../main.asm"               ; The core application

; end - the end of the saved program
.end

; Available memory for the received database.
; On the C64 this runs up to the end of the spare 4k block as we have
; paged the Basic rom out with ram
    ALIGN &100
.memBase                    ; First free block of memory
    EQUB 0

; memTop is start of unusable memory.
memTop              = &CC00 ; Upper bound of all free memory

; Use old screen memory for buffers
rs232OutputBuffer   = &0400 ; RS232 output buffer, must be page aligned
rs232InputBuffer    = &0500 ; RS232 input buffer, must be page aligned
outputBuffer        = &0600 ; Output buffer
; 0700 free
; 0800 Basic loader, can be overwritten if required

screenRam           = &CC00 ; 1K Screen ram (for high res) ends &CFFF

; DOS uses CC00 for scratch ram?
; IO occupies &D000 - &DFFF

screenBase          = &E000 ; Location of highres screen behind Kernal rom


    ; Save the program, start-2 to include the start address &0801
    SAVE "depart.prg", start-2, end
