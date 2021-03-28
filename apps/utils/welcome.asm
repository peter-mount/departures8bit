; **********************************************************************
; C64 welcome page
; **********************************************************************

.welcome
{
    JSR clearScreen
    JSR showPrompt

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
    EQUS 30, 10
    EQUS 132, 157, 135, 141, 31, 10, 1, "UK Departure Boards", 13, 10
    EQUS 132, 157, 135, 141, 31, 10, 2, "UK Departure Boards", 13, 10
    EQUS 10, "DepartureBoards.mobi", 13, 10, 10
    EQUS "Version 0.01a"
IF c64
    EQUS " C64"
ELIF bbcmaster
    EQUS " BBC Master"
ELIF bbc
    EQUS " BBC B"
ENDIF
    EQUS 13, 10, 0

.bytesFree
    EQUS " bytes free.", 13, 10, 10, 0
}