; **********************************************************************
; Commodore 64 program loader
; TODO leaving this here but it's now nolonger required
; **********************************************************************
;
; This prefixes the program with a simple 1 line basic program to invoke
; the machine code.
;
    INCLUDE "basictokens.asm"

    CPU     0               ; 6502
    GUARD   &A000           ; Guard to upper memory limit, valid only for generated code as we need to load
                            ; before swapping out the Basic rom

start = &0801               ; Base of basic program
    ORG start-2             ; Start 2 bytes earlier so we can inject the load address for the prg file format
    EQUW start              ; Load address in prg file format
                            ;   The program's entry point from the Basic loader
{
    EQUW basicEnd           ; pointer to next line
    EQUW 10                 ; line 10
    EQUB BASTOKEN_SYS, &20  ; SYS BASIC token followed by space
    EQUS "2304"             ; ASCII of entry point address 2304 = &0900
    EQUB 0                  ; End of line
.basicEnd
    EQUW 0                  ; pointer to next line, 0 = end of program
}
    SKIPTO &0900            ; Skip to the next page
                            ;   The program's entry point from the Basic loader
    LDA #%00110110          ; Replace basic with ram at A000-BFFF for an extra 8K
    STA &01

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

    LDA #%00110111          ; restore Basic rom
    STA &01

    JMP (&FFFC)             ; exit the program by resetting the C64
