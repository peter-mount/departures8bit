; **********************************************************************
; bootstrap - handles the loading of all parts into memory
; **********************************************************************

    CPU 0

    INCLUDE "../macros.asm"         ; Standard macros
    INCLUDE "kernal.asm"            ; Kernal definitions
    INCLUDE "teletext.inc"          ; Teletext entry points

fileCount   = &00FB             ; Current file number
fileName    = &00FC             ; Current filename
writeStr    = &00FE             ; text routine to use

start = &7000                   ; Base of bootstrap
    ORG start-2                 ; Start 2 bytes earlier so we can inject the
    EQUW start                  ; load address for the prg file format
{
    LDA #%00110110              ; Replace basic with ram at A000-BFFF for an extra 8K
    STA &01

    LDA #0                      ; First file
    STA fileCount

    LDA #<files                 ; Point to first filename
    STA fileName
    LDA #>files
    STA fileName+1

    LDA #<writeKernal           ; Use kernal to write text initially
    STA writeStr
    LDA #>writeKernal
    STA writeStr+1

.L1 LDY #0                      ; Check for file list terminator
    LDA (fileName),Y
    BEQ L4                      ; All done

    JSR showFilename            ; Display "Loading... file" message

    JSR loadFile                ; Load the current file
    CPY #&08                    ; If last byte loaded was below &0800 then
    BPL L2                      ; refresh the screen as we just loaded a splash
    CPY #&00                    ; ensure Y is < 800 ignore &C00 which can still
    BMI L2                      ; trigger the refresh
    JSR refreshScreen           ; page
.L2

    LDA fileCount               ; Check if we have loaded the first file
    BNE L3                      ; if not then skip teletext initialisation

    JSR teletextInit            ; Initialise teletext emulator
    JSR writeTeletextBanner     ; Write teletext banner

    LDA #<writeTele             ; Switch to teletext code to write loading text
    STA writeStr
    LDA #>writeTele
    STA writeStr+1

.L3 INC fileCount               ; Mark not the first file
    JSR strLen                  ; Get filename length
    INY                         ; Include null terminator
    TYA
    CLC                         ; Add it to FileName
    ADC fileName
    STA fileName
    LDA fileName+1
    ADC #0
    STA fileName+1
    BNE L1                      ; BRA to L1

.L4 JMP &0900                   ; Run the application
}

; As there's no JSR (writeStr)
.showFilename JMP (writeStr)

.writeKernal                    ; Write Loading before teletext loaded
{
    LDY #0                      ; Print "LOADING" to Kernal screen
.L1 LDA banner,Y                ; Standard send text to CHROUT until we hit 0
    BEQ L2
    JSR CHROUT
    INY
    BNE L1
.L2 LDY #0                      ; Print filename
.L3 LDA (fileName),Y
    BEQ L4
    JSR CHROUT
    INY
    BNE L3
.L4 RTS
.banner
    EQUS "LOADING ", 0
}

.writeTele                      ; Write loading on teletext screen
{
    LDX #<TX                    ; Move cursor to 21,0 & set white text
    LDY #>TX
    JSR writeString
                                ; Then the filename, padding to EOL
.L0 LDX #40-22-8                ; Max chars to write 8=len("Loading ")
    LDY #0
.L1 LDA (fileName),Y            ; Next char
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
}

.loadFile
    LDA #8                      ; Logical file number
    LDX #8                      ; Device 8 disk
    LDY #1                      ; Load with address in file
    JSR SETLFS

    JSR strLen                  ; Get filename length
    TYA                         ; into A for SETNAM
    LDX fileName                ; SETNAM on filename
    LDY fileName+1
    JSR SETNAM

    LDA #0                      ; Flag LOAD
    JMP LOAD                    ; Load into memory

.strLen                         ; Length of (fileName) excluding terminator in Y
{
    LDY #0
.L1 LDA (fileName),Y
    BEQ L2
    INY
    BNE L1
.L2 RTS
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
    EQUS 30, 134, "departureboards.mobi", 13, 10, 10
    EQUS 132, 157, 135, 141, "      Live UK Departure Boards      "
    EQUS 132, 157, 135, 141, "      Live UK Departure Boards      "
    EQUS 10, 130, "Please wait whilst loading completes...", 0
}

; List of files to load, terminated with 0
.files
    EQUS "TELETEXT", 0          ; TELETEXT must be the first file to load
    EQUS "SPLASH", 0
    EQUS "BANNER", 0
    EQUS "DEPART", 0
    EQUB 0                      ; list terminator
.end
    ; Save the program, start-2 to include the start address
    SAVE "bootstrap", start-2, end
