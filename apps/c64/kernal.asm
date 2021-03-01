; **********************************************************************
; Commodore 64 Kernal definitions
; **********************************************************************

; Kernal routines
SETLFS  = &FFBA     ; Setup a logical file
SETNAM  = &FFBD     ; Set file name
OPEN    = &FFC0     ; Open logical file
CLOSE   = &FFC3     ; Close logical file
CHKOUT  = &FFC9     ; Open channel for output
CLRCHN  = &FFCC     ; Clear IO channels
CHRIN   = &FFCF     ; Input 1 char from keyboard, reads a line until return pressed
CHROUT  = &FFD2     ; Output 1 char to screen (or open channel)
GETIN   = &FFE4     ; Get 1 char from keyboard
PLOT    = &FFF0     ; Set/Get cursor position

; Not official calls?
CLSR    = &E544     ; Clear screen

; **********************************************************************

; Colours
COL_BLACK       = 0
COL_WHITE       = 1
COL_RED         = 2
COL_CYAN        = 3
COL_PURPLE      = 4
COL_GREEN       = 5
COL_BLUE        = 6
COL_YELLOW      = 7
COL_ORANGE      = 8
COL_BROWN       = 9
COL_LIGHT_RED   = 10
COL_GREY1       = 11
COL_GREY2       = 12
COL_LIGHT_GREEN = 13
COL_LIGHT_BLUE  = 14
COL_GREY3       = 15

; **********************************************************************
; Memory map
MAIN_RAM_START  = &0800 ; Basic area, where we load ourselves
MAIN_RAM_END    = &9FFF

BASIC_ROM_START = &A000 ; Basic rom, or switchable 8k ram bank
BASIC_ROM_END   = &BFFF ; &01 = %x00, %x01 or %x10 for ram, %x11 rom

UPPER_RAM_START = &C000 ; Upper ram area, 4K
UPPER_RAM_END   = &CFFF
; **********************************************************************
