; **********************************************************************
; bootstrap - handles the loading of all parts into memory
; **********************************************************************

    CPU 0

    INCLUDE "../macros.asm"                 ; Standard macros
    INCLUDE "kernal.asm"                    ; Kernal definitions
    INCLUDE "../teletext/teletext.inc"      ; Teletext entry points

fileCount   = &00FB             ; Current file number
fileName    = &00FC             ; Current filename
fileExec    = &00FE             ; File execution hook

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

.L1 LDY #0                      ; Check for file list terminator
    LDA (fileName),Y
    BEQ L4                      ; All done

    JSR showFilename            ; Display "Loading... file" message

    JSR loadFile                ; Load the current file

    CPY #&08                    ; If last byte loaded was below &0800 then
    BPL L2                      ; refresh the screen as we just loaded a splash
    CPY #&00                    ; page.
    BMI L2
    JSR refreshScreen
    JMP L3                      ; Skip to next file

.L2 LDA fileCount               ; Check if we have loaded the first file
    BNE L3                      ; if not then skip teletext initialisation

    JSR teletextInit            ; Initialise teletext emulator
    JSR writeTeletextBanner     ; Write teletext banner

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

.L4
;    JMP L4
    JMP &0900                   ; Run the application
}

.showFilename
{
    LDA fileCount               ; First file needs to use the Kernal routine
    BNE writeTele               ; subsequent ones Teletext's oswrch

                                ; Write Loading before teletext loaded
    LDY #0                      ; Print "LOADING" to Kernal screen
.L1 LDA KX,Y                    ; Standard send text to CHROUT until we hit 0
    BEQ L2
    JSR CHROUT
    INY
    BNE L1                      ; BRA L1 as Y will always be >0
.L2 LDY #0                      ; Print filename
.L3 LDA (fileName),Y
    BEQ L4
    JSR CHROUT
    INY
    BNE L3                      ; BRA L3 as Y will always be >0
.L4 RTS

.writeTele                      ; Write loading on teletext screen
    LDX #<TX                    ; Move cursor to 21,0 & set white text
    LDY #>TX
    JSR writeString
                                ; Then the filename, padding to EOL
.T0 LDX #40-22-8                ; Max chars to write 8=len("Loading ")
    LDY #0
.T1 LDA (fileName),Y            ; Next char
    BEQ T2                      ; End of string
    JSR oswrch                  ; Write char
    INY
    DEX
    BNE T1                      ; Loop until we hit max chars
    RTS
.T2 LDA #' '                    ; Pad spaces until we run out
.T3 JSR oswrch
    DEX
    BNE T3
    RTS
.KX EQUS "LOADING ", 0              ; Kernal message
.TX EQUS 31,21,0,135,"Loading ",0   ; Teletext TAB(21,0), WhiteText
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

; Teletext screen message
.writeTeletextBanner
{
    LDX #<banner
    LDY #>banner
    JMP writeString
.banner
    EQUS 30, 134, "departureboards.mobi", 13, 10
    EQUS 132, 157, 135, 141, "      Live UK Departure Boards      "
    EQUS 132, 157, 135, 141, "      Live UK Departure Boards      "
    EQUS 10, 130, "Please wait whilst loading completes...", 0
}

; List of files to load, terminated with 0
.files
    EQUS "TELETEXT", 0          ; TELETEXT must be the first file to load
    EQUS "TESTCARD", 0          ; Teletext test card for debugging
    EQUS "ASCIICARD", 0         ; Teletext ASCII chart Text mode for debugging
    EQUS "GRAPHICSCARD", 0      ; Teletext ASCII chart Graphics mode for debugging
    EQUS "SPLASH", 0            ; Our splash page
    EQUS "NETWORK", 0           ; Network driver
    EQUS "BOARDS", 0            ; The main application
    EQUB 0                      ; list terminator
.end
    ; Save the program, start-2 to include the start address
    SAVE "bootstrap.prg", start-2, end
