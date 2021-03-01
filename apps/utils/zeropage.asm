; **********************************************************************
; ZeroPage allocations
; **********************************************************************
; This is common to both BBC & C64

; Bytes 0 & 1 are unavailable on the C64 as they are the 6510 processor port
stringPointer       = &02   ; String utility pointer
