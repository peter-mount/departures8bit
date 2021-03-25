; ********************************************************************************
; The language entry point
;
; In the original beebrail project this was a simple command line interface
; Here we will have a menu system
; ********************************************************************************

; switchLanguage Switches to our language
; The language ROM is entered via its entry point with A=1.
; Locations &FD and &FE in zero page are set to point to the copyright message in the ROM.
.switchLanguage
    LDA #&8E                        ; Enter language ROM
    LDX pagedRomID                  ; Use our ROM number
    JMP osbyte

; The main language entry point
.language
    CMP #&01                        ; Accept A=1 only
    BEQ language1
    RTS
.language1
    LDX #&FF                        ; Reset the stack
    TXS

    LDA #22                         ; Switch to shadow mode 7
    JSR oswrch
    LDA #128+7
    JSR oswrch

    LDA #&84                        ; set HIGHMEM
    JSR osbyte
    STX highmem
    STY highmem+1

    DEC A                           ; set PAGE
    JSR osbyte
    STX page
    STY page+1

    JSR serialInit                ; Enable RS423

    LDA #<errorHandler              ; Setup error handler
    STA BRKV
    LDA #>errorHandler
    STA BRKV+1

    CLI                             ; Enable IRQ's

    JMP entryPoint                  ; Enter the common code
