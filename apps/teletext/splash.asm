; **********************************************************************
; Splash loading page
; 1K for holding screen chars for refresh
; **********************************************************************
    CPU     0       ; 6502

start = &0400               ; Base of Teletext screen
    ORG     start-2         ; Start 2 bytes earlier so we can inject the load address for the prg file format
    GUARD   start+(25*40)   ; Guard against going over teletext screen size
    EQUW    start           ; Load address 0400 in prg file format

    EQUS 134, "departureboards.mobi         ",135,"C64",129,"v0.01"
    EQUB &96, &ff, &ff, &ff, &ff, &ff, &ff, &ff
    EQUB &ff, &ff, &ff, &ff, &ff, &ff, &bf, &af, &af, &a3, &a3, &a3, &a3, &a3, &a3, &a3
    EQUB &a3, &a3, &a3, &af, &af, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff
    EQUB &96, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &bf, &af, &a7, &a3, &97, &e0, &f0, &bc
    EQUB &ec, &fb, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &fc, &f4, &f0, &96, &a3
    EQUB &af, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &96, &ff, &af, &af, &a7, &a3, &a1, &97
    EQUB &f0, &f0, &fc, &fc, &ff, &e7, &f9, &fe, &ff, &af, &af, &af, &a7, &a3, &a3, &a3
    EQUB &a3, &a3, &a3, &a3, &a3, &a3, &ab, &ac, &e4, &96, &ef, &ff, &ff, &ff, &ff, &ff
    EQUB &97, &f0, &f0, &f8, &fc, &fc, &ff, &ff, &af, &af, &af, &a7, &a1, &a3, &a1, &93
    EQUB &e0, &f8, &fc, &fc, &fc, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &fc, &fc
    EQUB &fc, &f4, &96, &eb, &ff, &ff, &ff, &ff, &97, &af, &a7, &a3, &a3, &94, &f0, &f0
    EQUB &f0, &f8, &fc, &fc, &9e, &ff, &ff, &93, &ff, &bf, &a3, &a3, &a3, &a3, &96, &f0
    EQUB &f0, &f0, &20, &f0, &f0, &93, &a3, &a3, &9f, &a3, &a9, &96, &ff, &ff, &ff, &ff
    EQUB &95, &e8, &9d, &94, &ff, &9e, &9c, &ff, &ff, &ff, &ff, &ff, &b7, &a3, &ff, &93
    EQUB &9f, &96, &fe, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &b0, &ef, &ff, &ff, &ff, &ff
    EQUB &ff, &ff, &f4, &96, &ef, &ff, &ff, &ff, &95, &ea, &9e, &94, &bf, &af, &ef, &ff
    EQUB &bf, &af, &af, &ff, &b5, &20, &ff, &93, &9f, &96, &ff, &ff, &ff, &ff, &ff, &ff
    EQUB &ff, &ff, &b5, &ea, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &b0, &ea, &ff, &ff, &ff
    EQUB &95, &ea, &ea, &ea, &94, &20, &ea, &ff, &20, &20, &9e, &ff, &b5, &20, &ff, &93
    EQUB &9f, &96, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &a5, &20, &ef, &ff, &ff, &ff
    EQUB &ff, &ff, &ff, &b4, &ea, &ff, &ff, &ff, &95, &ea, &ea, &ea, &94, &a1, &eb, &ff
    EQUB &a2, &9e, &a3, &ff, &a1, &20, &ff, &93, &9f, &96, &ff, &ff, &ff, &ff, &ff, &ff
    EQUB &ff, &e5, &b4, &20, &f4, &ef, &ff, &ff, &ff, &ff, &ff, &b5, &ea, &ff, &ff, &ff
    EQUB &95, &ea, &ea, &ea, &94, &20, &ea, &ff, &20, &20, &20, &ff, &20, &9e, &ff, &93
    EQUB &9f, &96, &ff, &ff, &ff, &ff, &ff, &bf, &e1, &fe, &b5, &20, &ff, &fd, &ab, &ff
    EQUB &ff, &ff, &ff, &b5, &a8, &ff, &ff, &ff, &95, &ea, &fa, &fa, &94, &20, &fa, &ff
    EQUB &20, &20, &20, &ff, &20, &9e, &ff, &93, &9f, &96, &ef, &ff, &ff, &ff, &bf, &e1
    EQUB &ae, &af, &af, &20, &af, &af, &ad, &a2, &af, &af, &af, &a5, &20, &ff, &ff, &ff
    EQUB &95, &ea, &9d, &94, &ff, &9e, &9c, &ff, &fc, &fc, &fe, &ff, &b0, &e0, &ff, &93
    EQUB &fc, &b4, &20, &20, &20, &94, &20, &20, &20, &f0, &f0, &f0, &f0, &f0, &f0, &f0
    EQUB &f0, &f0, &9f, &f0, &96, &ff, &ff, &ff, &95, &ea, &9d, &94, &ff, &ff, &9d, &96
    EQUB &e0, &ac, &e4, &20, &20, &94, &9d, &93, &ff, &b5, &20, &20, &20, &20, &20, &9e
    EQUB &97, &aa, &a8, &95, &a9, &20, &97, &a6, &9f, &a2, &a6, &96, &9c, &ff, &ff, &ff
    EQUB &95, &a2, &9d, &94, &e9, &f8, &f2, &a3, &e6, &9d, &96, &a9, &b8, &a9, &9e, &93
    EQUB &ff, &9c, &bc, &ac, &ac, &ac, &ac, &fc, &fc, &fc, &fc, &fc, &fc, &fc, &fc, &bc
    EQUB &ac, &9f, &ac, &fc, &92, &f0, &f0, &f0, &94, &a3, &ab, &af, &ff, &ff, &9d, &95
    EQUB &a2, &a3, &9e, &ab, &94, &ff, &9c, &93, &ff, &ff, &ea, &eb, &a3, &b7, &eb, &ff
    EQUB &ff, &ff, &ff, &ff, &ff, &ff, &9f, &ff, &a3, &b7, &eb, &ea, &92, &ff, &ff, &ff
    EQUB &97, &9a, &a2, &a1, &99, &94, &a3, &af, &ef, &ff, &ff, &ff, &ea, &ff, &9e, &93
    EQUB &ff, &ff, &9f, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff
    EQUB &ff, &ff, &ff, &b5, &92, &ff, &ff, &ff, &97, &9a, &a9, &a4, &20, &e9, &aa, &b0
    EQUB &99, &94, &a3, &ab, &ed, &f3, &9d, &93, &eb, &ff, &9e, &9c, &ff, &9f, &ff, &bf
    EQUB &a3, &a3, &a3, &a3, &a3, &a3, &a3, &af, &af, &af, &af, &92, &aa, &ff, &ff, &ff
    EQUB &97, &9a, &e0, &20, &20, &20, &e5, &20, &b5, &20, &e0, &b8, &94, &99, &e6, &e4
    EQUB &93, &ad, &ac, &ac, &ac, &ac, &ac, &a4, &97, &20, &b6, &a3, &a3, &93, &e8, &e7
    EQUB &e7, &e7, &a7, &92, &e8, &ff, &ff, &ff, &20, &20, &97, &9a, &a8, &20, &9a, &ac
    EQUB &f0, &20, &b9, &b5, &99, &94, &a8, &b9, &93, &a9, &b9, &b9, &b9, &b9, &b9, &97
    EQUB &a1, &ac, &20, &20, &a4, &93, &ea, &b9, &b9, &b1, &92, &fe, &ff, &ff, &ff, &ff
    EQUB &92, &20, &20, &20, &97, &9a, &a2, &20, &9a, &b3, &20, &9a, &b6, &99, &94, &e6
    EQUB &a4, &93, &a2, &a2, &a6, &a6, &a6, &97, &a1, &ac, &93, &e8, &fc, &20, &aa, &af
    EQUB &ae, &a4, &92, &ff, &ff, &ff, &ff, &ff, &92, &fd, &f4, &20, &20, &20, &20, &20
    EQUB &20, &97, &9a, &a4, &a2, &9a, &a2, &ac, &ac, &a4, &20, &20, &20, &20, &20, &20
    EQUB &20, &20, &20, &20, &20, &94, &9a, &e8, &99, &92, &af, &ff, &ff, &ff, &ff, &ff
    EQUB &92, &ff, &ff, &ff, &f4, &b0, &20, &20, &20, &20, &20, &9a, &97, &a1, &20, &b8
    EQUB &94, &a8, &e4, &f0, &20, &20, &20, &20, &20, &20, &20, &20, &20, &94, &f0, &a6
    EQUB &20, &20, &20, &99, &92, &a3, &a3, &af, &92, &ff, &ff, &ff, &ff, &ff, &fd, &f0
    EQUB &20, &20, &20, &20, &20, &20, &9a, &97, &a8, &20, &b0, &94, &a3, &a3, &a3, &a3
    EQUB &a3, &a3, &a3, &a3, &a3, &97, &f0, &b0, &20, &20, &20, &20, &20, &20, &20, &20
    EQUB &92, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &fd, &f4, &b0, &20, &20, &20, &20, &9a
    EQUB &20, &97, &a2, &a9, &e4, &b0, &20, &20, &20, &20, &20, &20, &20, &20, &20, &a2
    EQUB &a9, &ac, &f0, &20, &20, &20, &20, &20
.end

    SAVE "splash.prg", start-2, end
