; **********************************************************************
; C64 welcome page
; **********************************************************************

.welcome
    JSR clearScreen
    LDX #<welcomeText
    LDY #>welcomeText
    JSR writeString
    RTS

.welcomeText
    EQUS "DEPARTUREBOARDS.MOBI"
IF c64
    EQUS " C64"
ELIF bbcmaster
    EQUS " BBC Master"
ELIF bbc
    EQUS " BBC B"
ENDIF
    EQUS 13, 13, "VERSION 0.01A", 13, 13
    EQUB 0
