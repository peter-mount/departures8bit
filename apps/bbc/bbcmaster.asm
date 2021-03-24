; ********************************************************************************
; BBC Master 128 ROM image
; ********************************************************************************

    ; Select 65c02
    CPU        1

    INCLUDE "../macros.asm"                 ; Our macros
    INCLUDE "../zeropage.asm"               ; Zero page allocations
    INCLUDE "mos.asm"                       ; BBC MOS definitions

    ORG     &8000                           ; Paged Rom start
    GUARD   &C000                           ; Guard at end of Paged Rom
    INCLUDE "romheader.asm"                 ; Rom header must be the first code section
    INCLUDE "language.asm"                  ; Language entry point
    INCLUDE "../main.asm"                   ; The core application

    ; Save the rom
    SAVE "m128rom", &8000, &C000
