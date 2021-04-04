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
    EQUS 128,157,135,"Bk", 129,157,134,"Rd",130,157,133,"Gn",131,157,132,"Yl",132,157,131,"Bl",133,157,130,"Mg",134,157,129,"Cn",135,157,128,"Wh"
    EQUS "                                        "
    ; Test 156 Black background after showing a different background colour
    EQUS 132,157," Blue Background  ",156," Black Background  "
    EQUS "                                        "
    EQUS "    ",129,"2 lines of solid graphics          "
    EQUS "   ", 32, 151
    EQUS 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175
    EQUS 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, "   "
    EQUS "  ", 32, 151, 234 ; 1 line strike through text
    EQUS 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207
    EQUS 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 181, "  "
    EQUS "   ", 32, 151
    EQUS 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239
    EQUS 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255, "   "
    EQUS "                                        "
    EQUS "    ",129,"2 lines of separated graphics      "
    EQUS "  ", 32, 151, 154
    EQUS 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175
    EQUS 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, "   "
    EQUS " ", 32, 151, 154, 234 ; 1 line strike through text
    EQUS 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207
    EQUS 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 181, "  "
    EQUS "  ", 32, 151, 154
    EQUS 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239
    EQUS 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255, "   "
    EQUS "                                        "
    EQUS "                                        "
    ; Bottom "status" line, used for fast text nav etc.
    ; Here a (C) on bottom left & url on right to test we
    ; show the bottom of the screen correctly
    EQUS "(C) 2021 Peter Mount          Area51.dev"
.end

    SAVE "testcard.prg", start-2, end
