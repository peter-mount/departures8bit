; **********************************************************************
; Commodore C64 departure boards
; **********************************************************************

    INCLUDE "../macros.asm"                 ; Our macros
    INCLUDE "../zeropage.asm"               ; 3rd Zero page allocations
    INCLUDE "kernal.asm"                    ; Kernal constants
    INCLUDE "loader.asm"                    ; Start of the C64
    INCLUDE "charset.asm"                   ; Teletext char set
    INCLUDE "teletext.asm"                  ; Teletext emulation
    INCLUDE "../main.asm"                   ; The core application

; end - the end of the saved program
.end

; Available memory for the received database.
; On the C64 this runs up to the end of the spare 4k block as we have
; paged the Basic rom out with ram
    ALIGN &100
.memBase                                    ; First free block of memory
    EQUB 0

; memTop is start of unusable memory.
memTop              = &C800                 ; Upper bound of all free memory

; Use old screen memory for buffers
rs232OutputBuffer   = &0400                 ; RS232 output buffer, must be page aligned
rs232InputBuffer    = &0500                 ; RS232 input buffer, must be page aligned
outputBuffer        = &0600                 ; Output buffer

; 0700-7FFF free
; 0800-8FFF Basic loader, can be overwritten if required as not needed once we start
; C800-CFFF Teletext
; CC00-CCFF Is this used by DOS for scratch ram? If so then teletext "might" need moving
; D000-DFFF C64 IO
; E000-FFFF Ram behind Kernal ROM used for teletext bitmap

    ; Save the program, start-2 to include the start address &0801
    SAVE "depart", start-2, end
