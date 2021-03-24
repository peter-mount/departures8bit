; ********************************************************************************
; * mos.asm - The BBC MOS
; ********************************************************************************

; OS calls
oscli  = &FFF7
osbyte = &FFF4
osword = &FFF1
oswrch = &FFEE
oswrcr = &FFEC
osnewl = &FFE7
osasci = &FFE3
osrdch = &FFE0
osfile = &FFDD
osargs = &FFDA
osbget = &FFD7
osbput = &FFD4
osgbpb = &FFD1
osfind = &FFCE

; MOS Zero page
oswordReason    = &EF           ; EF contains OSWORD reason code
oswordData      = &F0           ; F0/F1 contains parameter block address
pagedRomID      = &F4           ; F4 contains the currently active paged rom
brkAddress      = &FD           ; FD/FE holds address after a BRK instruction

; OS vectors
BRKV            = &0202         ; Break vector
WRCHV           = &020E         ; WriteChar vector
