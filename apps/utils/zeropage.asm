; **********************************************************************
; ZeroPage allocations
; **********************************************************************
;
; This defines our zero-page usage and is common to both the BBC & C64
;
; On the C64 02-7F if Basic is swapped out.
; On the BBC 00-8F if the current language rom
;            70-8F if BBC Basic is active
;
; 90-FF is reserved by Acorn MOS & 80-FF by Kernal.
;
; As we replace the relevant language then we can safely use 02-7F on
; both architectures.
;
                ORG 2       ; Bytes 0 & 1 are unavailable on the C64 as they are the 6510 processor port
.stringPointer  EQUW 0      ; String utility pointer
.tempChar       EQUB 0      ; 1 byte to store temp char
.tempA          EQUB 0      ; 1 byte to store accumulator
.currentStation EQUS "MDEx" ; 4 bytes current crs code + CR
.tempAddr       EQUW 0      ; 2 byte scratch address
.outputLength   EQUB 0      ; Size of output buffer
.dataPos        EQUW 0      ; Current position in dataBase
.curBlock       EQUB 0      ; Current block number being received
.numBlock       EQUB 0      ; Number of blocks expected
.curLine        EQUW 0      ; Address of the current line being executed

IF bbc
.oswordWork     EQUB 0,0,0,0,0  ; 5 bytes for OSWORD call on BBC
ENDIF

; Here until I find somewhere better
IF c64
outputBuffer        = &C000 ; 256 bytes to create strings
;dataBase            = &c100 ; Base of read data from the feeds

ELSE
    ERROR "Not implemented"
ENDIF
