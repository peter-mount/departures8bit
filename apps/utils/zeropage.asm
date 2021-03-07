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
; Bytes 0 & 1 are unavailable on the C64 as they are the 6510 processor port
stringPointer       = &02   ; String utility pointer
tempChar            = &04   ; 1 byte to store temp char
tempA               = &05   ; 1 byte to store accumulator
currentStation      = &06   ; 4 bytes current crs code + CR
tempAddr            = &0A   ; 2 byte scratch address, 5 bytes for OSWORD on BBC
readLength          = &0F   ; Number of bytes read from serial
outputLength        = &10   ; Size of output buffer
next                = &11   ; next free location
                            ; XModem
crc		            = &38   ; CRC lo byte  (two byte variable)
crch		        = &39	; CRC hi byte
ptr		            = &3a	; data pointer (two byte variable)
ptrh		        = &3b	;   "    "
blkno		        = &3c	; block number
retry		        = &3d	; retry counter
retry2		        = &3e	; 2nd counter
bflag		        = &3f	; block flag


; Here until I find somewhere better
IF c64
;stationBuffer       = &C000 ; 4K workspace for stations as they are read
outputBuffer        = &C000 ; 256 bytes to create strings
inputBuffer         = &C100 ; 256 bytes before the Basic rom
workBase = &c200

ELSE
    ERROR "Not implemented"
ENDIF
