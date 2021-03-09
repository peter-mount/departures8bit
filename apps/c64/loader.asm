; **********************************************************************
; Commodore 64 program loader
; **********************************************************************
;
; This prefixes the program with a simple 1 line basic program to invoke
; the machine code.
;
    CPU     0       ; 6502
    GUARD   &A000   ; Guard to upper memory limit, valid only for generated code

start = &0801       ; Base of basic program
    ORG start-2     ; Start 2 bytes earlier so we can inject the load address
    EQUW start      ; Load address in prg file
{
    EQUW basicEnd   ; pointer to next line
    EQUW 10         ; line 10
    EQUB &9E, &20   ; SYS BASIC token followed by space
    EQUS "2304"     ; ASCII of entry point address 2304 = &0900
;    EQUS "4096"     ; ASCII of entry point address 4096 = &1000
    EQUB 0          ; End of line
.basicEnd
    EQUW 0          ; pointer to next line, 0 = end of program
}
    SKIPTO &0900    ; Skip to the next page
;    SKIPTO &1000
;   The program's entry point from the Basic loader
    LDA #%00110110          ; Replace basic with ram at a000-bfff for an extra 8K
    STA &01
    JSR entryPoint          ; call our true entry point
    LDA #%00110111          ; restore Basic rom
    STA &01
    RTS                     ; exit the program
