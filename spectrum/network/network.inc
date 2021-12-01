; ----------------------------------------------------------------------
; network module entry points
; ----------------------------------------------------------------------

networkClose    equ 0xEC03
networkGet      equ networkClose + 3
networkPut      equ networkGet + 3
networkInit     equ networkPut +3
networkSend     equ networkInit + 3
networkGetLine  equ networkSend + 3
networkGetBlock equ networkGetLine + 3
nextBlock       equ networkGetBlock + 3
lastBlock       equ nextBlock + 3
countBlocks     equ lastBlock + 3
findBlock       equ countBlocks + 3
