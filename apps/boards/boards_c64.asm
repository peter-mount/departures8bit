; **********************************************************************
; Commodore C64 departure boards
; **********************************************************************

    INCLUDE "../macros.asm"                 ; Our macros
    INCLUDE "../zeropage.asm"               ; 3rd Zero page allocations
    INCLUDE "../c64/kernal.asm"             ; Kernal constants
    INCLUDE "../teletext/teletext.inc"      ; Teletext emulation
    INCLUDE "../network/network.inc"        ; Network driver

    CPU     0               ; 6502
    GUARD   &A000           ; Guard to upper memory limit, valid only for generated code as we need to load
                            ; before swapping out the Basic rom

start = &0900               ; Base of application
    ORG start-2             ; Start 2 bytes earlier so we can inject the load address for the prg file format
    EQUW start              ; Load address in prg file format

    LDX #&FF                ; Reset the stack as we won't be returning from here
    TXS

    LDA #<memBase           ; Setup PAGE
    STA page
    LDA #>memBase
    STA page+1

    LDA #<memTop            ; Setup HIGHMEM
    STA highmem
    LDA #>memTop
    STA highmem+1

    JSR entryPoint          ; call our true entry point
    JSR cleanup             ; call our cleanup code

    JMP (&FFFC)             ; exit the program by resetting the C64

    INCLUDE "main.asm"      ; The core application

; end - the end of the saved program
.end

; Available memory for the received database.
; On the C64 this runs up to the end of the spare 4k block as we have
; paged the Basic rom out with ram
    ALIGN &100
.memBase                                    ; First free block of memory
    EQUB 0

; memTop is start of unusable memory.
memTop              = &BA00                 ; Upper bound of all free memory

; Use old screen memory for buffers
;rs232OutputBuffer   = &BE00                 ; RS232 output buffer, must be page aligned
;rs232InputBuffer    = &BF00                 ; RS232 input buffer, must be page aligned
;outputBuffer        = &0800                 ; Output buffer

    ; Save the program, start-2 to include the start address &0801
    SAVE "boards_c64.prg", start-2, end
