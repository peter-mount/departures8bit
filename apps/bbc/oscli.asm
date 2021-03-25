; ********************************************************************************
; * oscli - Implements our OSCLI commands
; ********************************************************************************

; unknown oscli command (&F2),Y holds the start of the command
.oscliHandler
    PHA                             ; Save A & Y
    PHY
    LDX #0
.oscliHandlerLoop
    LDA oscliTable,X
    BMI oscliHandlerFail            ; End of table
    BEQ oscliHandlerFound           ; 0 so we have found our command
    CMP (&F2),Y
    BNE oscliHandlerSkip            ; Skip entry
    INY                             ; next char
    INX
    BNE oscliHandlerLoop

.oscliHandlerFail
    PLY                             ; Restore A & Y as its unclaimed
    PLA
    RTS

.oscliHandlerFound
    PLA                             ; Dump original A & Y to bitbucket
    PLA
    INX                             ; Skip to address
    JSR oscliHandlerExec            ; Invoke command
    LDA #0                          ; Claim command
    RTS

.oscliHandlerSkip
    INX
    LDA oscliTable,X
    BNE oscliHandlerSkip            ; Loop until 0
    INX                             ; Skip 0 & address
    INX
    INX
    PLY                             ; Get initial Y back
    PHY
    BRA oscliHandlerLoop            ; Resume loop

; As there's no JSR (oscliTable,X)
; On entry (&F2),Y will hold offset of first char after the command (if required)
.oscliHandlerExec
    JMP (oscliTable,X)

.oscliTable
    EQUS "RAIL",0       : EQUW switchLanguage   ; Language entry point
    EQUB &FF                                    ; Table terminator
