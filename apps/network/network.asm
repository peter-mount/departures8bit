; ********************************************************************************
; On the C64 we load this as a separate reusable module
; ********************************************************************************

        INCLUDE "../zeropage.asm"
        INCLUDE "../macros.asm"
        INCLUDE "../c64/kernal.asm"         ; Kernal constants
        INCLUDE "../teletext/teletext.inc"  ; Teletext module

rs232OutputBuffer   = &BD00                 ; RS232 output buffer, must be page aligned
rs232InputBuffer    = &BE00                 ; RS232 input buffer, must be page aligned
outputBuffer        = &BF00                 ; Output buffer

; **********************************************************************
        ORG     &BA00-2     ; Start of module -2 for prg load address
        GUARD   &BD00       ; Start of Teletext module
        EQUW    start       ; PRG file format header
.start                      ; of actual load address

; **********************************************************************
; Public entry points - Addresses of these can't change once defined!
;
; They should also be defined in teletext.inc so they can be referenced
; by user code.
; **********************************************************************
.initNetworkV       JMP serialInit          ; Initialise networking
.dialV              JMP dialServer          ; Dial server
.hangUpV            JMP hangUp              ; Hangup
.sendCommandV       JMP sendCommand         ; Send command in outputbuffer
.outputResetV       JMP outputReset
.outputTerminateV   JMP outputTerminate
.outputAppendHexV   JMP outputAppendHexChar
.outputAppendV      JMP outputAppend
.outputAppendStrV   JMP outputAppendString
.writeOutputBuffer
    LDXY outputBuffer
    JMP writeString

    INCLUDE "../network/dialer.asm"
    INCLUDE "../network/serial.asm"
    INCLUDE "../network/api.asm"
    INCLUDE "../utils/outputbuffer.asm"

.end

    SAVE "network.prg", start-2, end
