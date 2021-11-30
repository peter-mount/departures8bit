; ----------------------------------------------------------------------
; network module entry points
; ----------------------------------------------------------------------

networkClose    equ 0xF003
networkGet      equ networkClose + 3
networkPut      equ networkGet + 3
networkInit     equ networkPut +3
networkSend     equ networkInit + 3
networkGetline  equ networkSend + 3