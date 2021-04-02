; **********************************************************************
; bootstrap - handles the loading of all parts into memory
; **********************************************************************

    CPU 0

    INCLUDE "../macros.asm"         ; Standard macros
    INCLUDE "kernal.asm"            ; Kernal definitions
    INCLUDE "teletext.inc"          ; Teletext entry points

tempAddr = &00FB                ; Temp address

start = &7000                   ; Base of bootstrap
    ORG start-2                 ; Start 2 bytes earlier so we can inject the
    EQUW start                  ; load address for the prg file format

    LDA #%00110110              ; Replace basic with ram at A000-BFFF for an extra 8K
    STA &01

    JSR writeKernalBanner       ; Write initial banner to standard screen

    LDXY teletext               ; Load teletext driver
    JSR loadFileKernal          ; Kernal file loader until we have teletext loaded
    JSR teletextInit            ; Initialise teletext emulator
    JSR writeTeletextBanner     ; Write teletext banner

;    JSR refreshScreen           ; Refresh to show the loaded splash page
;.LL JMP LL                      ; Debug lock on splash screen
.LL
    LDXY splash                 ; Load splash page direct to teletext screen
    JSR loadFile
;.LL
    JSR refreshScreen           ; Refresh to show the loaded splash page

                                ; Uncomment this to hold on splash screen when
;.LL
;   JMP LL                      ; Debug lock on splash screen

    LDXY banner                 ; Load splash page direct to teletext screen
    JSR loadFile
    JSR refreshScreen           ; Refresh to show the loaded splash page

                                ; Uncomment this to hold on splash screen when
;.LL JMP LL                      ; Debug lock on splash screen
;    JMP LL

    LDXY app                    ; Load the application
    JSR loadFile

    JMP &0900                   ; Run the application

.loadFile
{
    STXY tempAddr               ; Store filename address
    LDX #<TX                    ; Move cursor to 21,0 & set white text
    LDY #>TX
    JSR writeString
    JSR L0                      ; write filename with padding
    JMP LF                      ; Load the file

.L0 LDX #40-22-8                ; Max chars to write 8=len("Loading ")
    LDY #0
.L1 LDA (tempAddr),Y            ; Next char
    BEQ L2                      ; End of string

    JSR oswrch                  ; Write char
    INY
    DEX
    BNE L1                      ; Loop until we hit max chars
    RTS
.L2 LDA #' '                    ; Pad spaces until we run out
.L3 JSR oswrch
    DEX
    BNE L3
    RTS
.TX EQUS 31,21,0,135,"Loading ",0          ; TAB(21,0), WhiteText
.TE EQUB 31,0,1,0               ; TAB(0,1)
}

.loadFileKernal
    STXY tempAddr               ; Store filename address
.LF LDA #8                      ; Logical file number
    LDX #8                      ; Device 8 disk
    LDY #1                      ; Load with address in file
    JSR SETLFS

    JSR strlen                  ; Get filename length
    LDX tempAddr                ; SETNAM on filename
    LDY tempAddr+1
    JSR SETNAM

    LDA #0                      ; Flag LOAD
    JMP LOAD                    ; Load into memory

.strlen
{
    LDY #0
.L1 LDA (tempAddr),Y
    BEQ L2
    INY
    BNE L1
.L2 TYA
    RTS
}

; C64 standard screen message
.writeKernalBanner
{
    LDY #0                      ; Print banner on teletext screen
.L1 LDA banner,Y                ; Standard send text to CHROUT until we hit 0
    BEQ L2
    JSR CHROUT
    INY
    BNE L1
.L2 RTS
.banner
    EQUS "LOADING TELETEXT", 13, 0
}

; Teletext screen message
.writeTeletextBanner
{
    LDX #<banner
    LDY #>banner
    JMP writeString
.banner
    EQUS 132, "Area51 Teletext", 135, "C64", 129, "1.0", 13, 10, 10
    EQUS 130, "Loading application...", 13, 10
    EQUB 0
}

.teletext   EQUS "TELETEXT", 0
.splash     EQUS "SPLASH", 0
.banner     EQUS "BANNER", 0
.app        EQUS "DEPART", 0

.end
    ; Save the program, start-2 to include the start address
    SAVE "bootstrap", start-2, end
