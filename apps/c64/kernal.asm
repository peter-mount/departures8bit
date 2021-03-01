; **********************************************************************
; Commodore 64 Kernal definitions
; **********************************************************************

; Kernal routines
CHRIN   = &FFCF     ; Input 1 char from keyboard, reads a line until return pressed
CHROUT  = &FFD2     ; Output 1 char to screen
GETIN   = &FFE4     ; Get 1 char from keyboard
PLOT    = &FFF0     ; Set/Get cursor position

; **********************************************************************
; Memory map
MAIN_RAM_START  = &0800 ; Basic area, where we load ourselves
MAIN_RAM_END    = &9FFF

BASIC_ROM_START = &A000 ; Basic rom, or switchable 8k ram bank
BASIC_ROM_END   = &BFFF ; &01 = %x00, %x01 or %x10 for ram, %x11 rom

UPPER_RAM_START = &C000 ; Upper ram area, 4K
UPPER_RAM_END   = &CFFF
; **********************************************************************
