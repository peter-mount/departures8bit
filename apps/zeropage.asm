; **********************************************************************
; ZeroPage allocations
; **********************************************************************
;
; This defines our zero-page usage and is common to both the BBC & C64
;
; Available:
; 02-8F C64 if Basic is swapped out.
; 00-8F BBC if running as or ignoring the current language rom
; 70-8F BBC if Basic is active
; FB-FE C64 free for user code
; FF    C64 free if basic swapped out
;
; Unusable:
; 00-01 C64 used by the 6510 CPU
; 90-FF BBC reserved by Acorn MOS
; 90-FA C64 reserved by Kernal.
;
; As we replace the relevant language then we can safely use 02-8F on
; both architectures.
;
                ORG     &02 ; Bytes 0 & 1 are unavailable on the C64 as they are the 6510 processor port
                GUARD   &90 ; Upper bound limit for zero page

                            ; Database
.page           EQUW 0      ; start of database memory
.highmem        EQUW 0      ; end of database memory
.dataPos        EQUW 0      ; Current position in dataBase
.curLine        EQUW 0      ; Address of the current line being executed

                            ; String manipulation
.outputLength   EQUB 0      ; Size of output buffer
.stringPointer  EQUW 0      ; String utility pointer

                            ; Data retrieval
.curBlock       EQUB 0      ; Current block number being received
.numBlock       EQUB 0      ; Number of blocks expected

                            ; Scratch workspace
.tempChar       EQUB 0      ; 1 byte to store temp char
.tempA          EQUB 0      ; 1 byte to store accumulator
.tempX          EQUB 0      ; 1 byte to store X
.tempAddr       EQUW 0      ; 2 byte scratch address, value for outputAppend16

.currentStation EQUS "MDEx" ; 4 bytes current crs code + CR

.pad            EQUB 0      ; 0=no padding, '0' or ' ' for padding

IF c64
.textX          EQUB 0      ; X pos on screen, 0..39
.textY          EQUB 0      ; Y pos on screen, 0..24
.textPos        EQUW 0      ; Pos as an address on highres screen
.tA             EQUB 0      ; oscli save A,X,Y
.tY             EQUB 0
.tX             EQUB 0
.textCol        EQUB 0      ; Text colour
ENDIF

IF bbc
.serialChar     EQUB 0          ; Char being sent/received
.oswordWork     EQUB 0,0,0,0,0  ; 5 bytes for OSWORD call on BBC
ENDIF
