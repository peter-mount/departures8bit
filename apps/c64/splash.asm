; **********************************************************************
; Splash loading page
; 1K for holding screen chars for refresh
; **********************************************************************
    CPU     0       ; 6502

start = &0400               ; Base of Teletext screen
    ORG     start-2         ; Start 2 bytes earlier so we can inject the load address for the prg file format
    GUARD   start+(25*40)   ; Guard against going over teletext screen size
    EQUW    start           ; Load address 0400 in prg file format

; Each line must be 40 bytes long
    ; A usual thing in teletext, a status line & double height text as a banner
    EQUS 134, "Project Area51                   ",130,"v0.01"
    EQUS 132, 157, 135, 141, "          Teletext C64              "
    EQUS 132, 157, 135, 141, "          Teletext C64              "
    EQUS "                                        "
    ; Text colour control codes for reference
    EQUS "  128  129  130  131  132  133  134  135"
    EQUS "   80   81   82   83   84   85   86   87"
    EQUS "                                        "
    ; Test setting text colours
    EQUS 135,157,128,"Bk ",156, 129,"Rd",130,"  Gn",131,"  Yl",132,"  Bl",133,"  Mg",134,"  Cn",135,"  Wh"
    EQUS "                                        "
    ; Test setting background colours
    EQUS 129,157," Rd",130,157," Gn",131,157," Yl",132,157," Bl",133,157," Mg",134,157," Cn",135,157,128,"Wh     "
    EQUS "                                        "
    ; Test 156 Black background after showing a different background colour
    EQUS 132,157," Blue Background  ",156," Black Background  "
    EQUS "                                        "
    EQUS "                                        "
    EQUS "                                        "
    EQUS "                                        "
    EQUS "                                        "
    EQUS "                                        "
    EQUS "                                        "
    EQUS "                                        "
    EQUS "                                        "
    EQUS "                                        "
    EQUS "                                        "
    EQUS "                                        "
    ; Bottom "status" line, used for fast text nav etc.
    ; Here a (C) on bottom left & url on right to test we
    ; show the bottom of the screen correctly
    EQUS "(C) Peter Mount               Area51.dev"
.end

    SAVE "splash", start-2, end
