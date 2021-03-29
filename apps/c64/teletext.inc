; **********************************************************************
; Teletext emulator - public entry points
; **********************************************************************
teletextInit    = &C000             ; Initialise emulator
refreshScreen   = teletextInit + 3  ; Refresh the screen
osascii         = refreshScreen + 3 ; write byte expanding CR (0x0D)
osnewl          = osascii + 4       ; Output LF/CR sequence
oswrch          = osnewl + 7        ; Write char to screen
clearScreen     = oswrch + 3        ; Clear the screen
setPos          = clearScreen + 3   ; Set text cursor location
