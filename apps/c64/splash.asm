; **********************************************************************
; Splash loading page
; 1K for holding screen chars for refresh
; **********************************************************************
    CPU     0       ; 6502
    GUARD   &800    ; Guard against hitting Basic free area

start = &0400               ; Base of Teletext screen
    ORG start-2             ; Start 2 bytes earlier so we can inject the load address for the prg file format
    EQUW start              ; Load address in prg file format

; Each line must be 40 bytes long
    EQUS 134, "Project Area51                   ",130,"v0.01"
    EQUS 132, 157, 135, 141, "          Teletext C64              "
    EQUS 132, 157, 135, 141, "          Teletext C64              "
    EQUS "                                        "
    EQUS "                                        "
    EQUS "                                        "
    EQUS "                                        "
    EQUS "                                        "
    EQUS "                                        "
    EQUS "                                        "
    EQUS 141, "              Loading...               "
    EQUS 141, "              Loading...               "
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
    EQUS "(C) Peter Mount, Area51.dev             "
.end

    SAVE "splash", start-2, end
