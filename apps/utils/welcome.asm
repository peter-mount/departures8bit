; **********************************************************************
; C64 welcome page
; **********************************************************************

.welcome
    JSR clearScreen
    WRITESTRING welcomeText
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
    EQUS 13, 13, "Version 0.01a", 13, 13
    EQUB 0
