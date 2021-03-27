; **********************************************************************
; C64 welcome page
; **********************************************************************

.welcome
{
    JSR clearScreen

    JSR outputReset                 ; Clear outputBuffer
    LDXY welcomeText                ; Append welcomeText
    JSR outputAppendString

    SEC
    LDA highmem
    SBC page
    STA tempAddr
    LDA highmem+1
    SBC page+1
    STA tempAddr+1
    LDA #0
    STA pad
    JSR outputAppend16

    LDXY bytesFree                  ; Append bytes free text
    JSR outputAppendString

    JSR writeOutputBuffer           ; Write outputbuffer to screen


    RTS

.welcomeText
    EQUS "DepartureBoards.mobi"
IF c64
    EQUS " C64"
ELIF bbcmaster
    EQUS " BBC Master"
ELIF bbc
    EQUS " BBC B"
ENDIF
    EQUS 13, 13, "Version 0.01a", 13, 0

.bytesFree
    EQUS " bytes free.", 13, 13, 0
}