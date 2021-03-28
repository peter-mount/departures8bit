; ********************************************************************************
; * mos.asm - The BBC MOS
; ********************************************************************************

; OS calls
oscli   = &FFF7
osbyte  = &FFF4
osword  = &FFF1
oswrch  = &FFEE
oswrcr  = &FFEC
osnewl  = &FFE7
osascii = &FFE3
osrdch  = &FFE0
osfile  = &FFDD
osargs  = &FFDA
osbget  = &FFD7
osbput  = &FFD4
osgbpb  = &FFD1
osfind  = &FFCE

; MOS Zero page
oswordReason    = &EF           ; EF contains OSWORD reason code
oswordData      = &F0           ; F0/F1 contains parameter block address
pagedRomID      = &F4           ; F4 contains the currently active paged rom
brkAddress      = &FD           ; FD/FE holds address after a BRK instruction

; 0200 MOS vectors
BRKV            = &0202         ; Break vector
WRCHV           = &020E         ; WriteChar vector
; 0300 MOS workspace
; 0400-07FF 1K reserved for the current language
outputBuffer    = &0400         ; our outputBuffer, was BASIC workspace
spare1          = &0500         ; was BASIC workspace
spare2          = &0600         ; was BASIC workspace
spare3          = &0700         ; was BASIC workspace
; 0800 Sound & Printer buffer
; 0900 RS423, Speech & Tape buffer
; 0A00 RS423 & Tape buffer
; 0B00 BBC: Function Keys, Master: Econet
; 0C00 BBC: User defined characters, Master: Econet
; 0D00 MOS workspace
