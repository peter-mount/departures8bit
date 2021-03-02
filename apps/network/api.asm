; **********************************************************************
; API
; **********************************************************************

; sendCommand Send command
;
; on entry:
;   A   Command to run
;   X,Y Address of arguments, 0=none
;
; on exit:
;   X   preserved
;   Y   preserved
;
.sendCommand
{
    STX tempAddr
    STY tempAddr+1
    CLC
    ROL A
    TAY
    LDA commands,Y
    STA stringPointer
    LDA commands+1,Y
    STA stringPointer+1
    LDX #0
.loop1
    LDA (stringPointer),Y
    BEQ loop2
    STA stationBuffer,X
    INY
    INX
    JMP loop1
.loop2
    LDA tempAddr+1              ; No args then skip to end
    BEQ loopEnd
    LDA #' '                    ; Append space
    STA stationBuffer,X
    INX
    LDY #0                      ; Copy args
.loop3
    LDA (tempAddr),Y
    BEQ loopEnd                 ; 0 so end command
    STA stationBuffer,X
    INX
    INY
    JMP loop3
.loopEnd
    LDA #10                     ; LF terminator
    STA stationBuffer,X
    INX
    LDA #0                      ; NULL terminator
    STA stationBuffer,X

    LDX #<stationBuffer
    LDY #>stationBuffer
    JSR writeString

    LDX #<stationBuffer
    LDY #>stationBuffer
    JMP serialSendBlock         ; Send command
}
    RTS

; Command lookup table
.commands
{
            EQUW cmdDepart
.cmdDepart  EQUS "DEPART", 0
}
