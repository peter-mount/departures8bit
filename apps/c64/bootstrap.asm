; **********************************************************************
; bootstrap - handles the loading of all parts into memory
; **********************************************************************

    CPU 0

    INCLUDE "../macros.asm"
    INCLUDE "kernal.asm"
    INCLUDE "teletext.inc"


tempAddr = &00FB                ; Temp address

start = &7000                   ; Base of bootstrap
    ORG start-2                 ; Start 2 bytes earlier so we can inject the
    EQUW start                  ; load address for the prg file format

    JSR writeKernalBanner       ; Write initial banner to standard screen

    LDXY teletext               ; Load teletext driver
    JSR loadFile
    JSR teletextInit            ; Initialise teletext emulator
    JSR writeTeletextBanner     ; Write teletext banner

;    JSR refreshScreen           ; Refresh to show the loaded splash page
;.LL JMP LL                      ; Debug lock on splash screen

    LDXY splash                 ; Load splash page direct to teletext screen
    JSR loadFile
    JSR refreshScreen           ; Refresh to show the loaded splash page

                                ; Uncomment this to hold on splash screen when
.LL JMP LL                      ; Debug lock on splash screen

    LDXY app                    ; Load the application
    JSR loadFile

    JMP &0900                   ; Run the application

.loadFile
    STXY tempAddr               ; Store filename address
    LDA #8                      ; Logical file number
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
    EQUS 132, "Area51 Teletext", 135, "C64", 129, "1.0", 13, 10;, 10
    EQUS 130, "Loading application...", 13, 10
    EQUB 31,0,14
    EQUS 132, "Area51 Teletext", 135, "C64", 129, "1.0", 13, 10;, 10
    EQUS 130, "Loading application...", 13, 10
    EQUS 31, 10, 10, "TAB(10,10)"
    EQUS 31,  0, 12, "TAB(0,12)"
    EQUS 31, 20, 20, "TAB(20,20)"
    EQUS 13, 10, "Test line 3", 13, "Test LINE 4"
    EQUB 0
}

.teletext   EQUS "TELETEXT", 0
.splash     EQUS "SPLASH", 0
.app        EQUS "DEPART", 0

.end
    ; Save the program, start-2 to include the start address
    SAVE "bootstrap", start-2, end
