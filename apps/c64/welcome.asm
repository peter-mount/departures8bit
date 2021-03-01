; **********************************************************************
; C64 welcome page
; **********************************************************************

.welcome
    LDX #<welcomeText
    LDY #>welcomeText
    JSR writeString
    RTS

.welcomeText
    EQUS "WELCOME TO DEPARTUREBOARDS.MOBI C64 EDITION", 13, 13
    EQUS "VERSION 0.01A", 13, 13
    EQUB 0
