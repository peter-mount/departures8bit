; **********************************************************************
; Teletext screen handler
; **********************************************************************
;
; The highres screen will be located at &E000 which is the start of the
; Kernal rom. This works as the VIC chip can access the ram that's there
; but does not see the ROM.
; When the CPU reads from those addresses it sees the ROM, but writes go to the ram.
; So we can keep Kernal in place, get a HighRes screen and gain 1K of ram
; that was the original text screen at &0400
;
screenWidth     = 40                            ; Chars wide    40 * 8 = 320
screenHeight    = 25                            ; Rows high     25 * 8 = 200

.initScreen
    LDA &DD02                                   ; CIA2 bits 0,1 as output
    ORA #3
    STA &DD02

    LDA &DD00                                   ; Set VIC-II to point to upper 16K bank
    AND #&FC                                    ; Bits 0,1 = 0 for Bank 3
   ;ORA #0                                      ; Bank 3 = 0 here so no need for OR
    STA &DD00

    LDA #&38                    ; Screen at 0c00, bitmap at 2000 - from C000 bank
    STA &D018

    LDA #&08            ; Multicolour off, 40 col, xscroll=0
    STA &D016

    LDA &D011                                   ; Switch to high resolution mode
    ORA #&38                                    ; Enable bit 5 for high res
    STA &D011
                                                ; TODO disable RESTORE key? 0318 & 0328

    LDA #&00                                    ; Set border to black
    STA &d020                                   ; Border colour
    STA &d021                                   ; Background colour

                                                ; Run into clearScreen
.clearScreen
{
    LDA #&10                                    ; Reset colour ram
    LDY #0
.L3 STA screenRam,Y
    STA screenRam + &100,Y
    STA screenRam + &200,Y
    STA screenRam + &300,Y
    DEY
    BNE L3

    JSR teletextHome                            ; Reset pointers

    LDA #&00                                    ; Clear screen
    LDX #&20                                    ; &2000 bytes to clear
    LDY #0
.L1 STA (textPos),Y                             ; Set screen memory
    INY
    BNE L1                                      ; Loop until page cleared
    INC textPos+1                               ; Move to next page
    DEX
    BNE L1                                      ; Loop until all done
}                                               ; Run through to home cursor

.teletextHome                                   ; Move char cursor to the home
    LDA #0                                      ; Reset screen position
    STA textX                                   ; as A is always 0 reset X & Y
    STA textY
    STA textPos
    LDA #>screenBase
    STA textPos+1
    RTS

.setPos                                        ; Set cursor to X,Y
    STX textX                                   ; Store X & Y
    STY textY                                   ; then teletextRefreshPos to set textPos

.teletextRefreshPos                             ; Set textPos to textX,textY
{
    PHA                                         ; Save A & Y
    TYA
    PHA

    LDA #0                                      ; Reset textPos to screenBase
    STA textPos
    LDA #>screenBase
    STA textPos+1

    LDY textY                                   ; Start with lines
    BEQ L2                                      ; Skip if line 0
.L1 CLC                                         ; Add 320 bytes to textPos
    LDA textPos                                 ; as that's the line length
    ADC #<320
    STA textPos
    LDA textPos+1
    ADC #>320
    STA textPos+1
    DEY                                         ; Dec Y
    BNE L1                                      ; Loop if more lines required

.L2 LDY textX                                   ; Now for characters
    BEQ L4                                      ; Skip if column 0
.L3 CLC                                         ; Add 8 bytes to textPos
    LDA textPos
    ADC #8
    STA textPos
    LDA textPos+1
    ADC #0
    STA textPos+1
    DEY                                         ; Dec col counter
    BNE L3                                      ; Loop if more columns required
.L4
    PLA                                         ; Restore A & Y
    TAY
    PLA
    RTS
}

.teletextForward                                ; Move forward 1 char
    INC textX                                   ; Increment X
    LDA textX
    CMP #screenWidth                            ; If > width then next line
    BPL teletextNewline
    CLC                                         ; Add 8 to textPos to move right 1 char
    LDA textPos
    ADC #8
    STA textPos
    LDA textPos+1
    ADC #0
    STA textPos+1
    RTS

.teletextNewline                                ; Move to next line
    LDA #0                                      ; Start of line
    STA textX
    INC textY                                   ; Increment Y
    LDA textY
    CMP #screenHeight
    BPL teletextHome                            ; Home screen when at bottom
    JMP teletextRefreshPos                      ; refresh textPos to correct address

.teletextWriteChar                              ; Write char A at the current position
{
    STA tA                                      ; Save A, X, Y to scratch ram
    STX tX
    STY tY
    SEC                                         ; Subtract 32 for base of charset
    SBC #32
    STA tempAddr                                ; Store as 16bit offset
    LDA #0
    STA tempAddr+1

    ASL tempAddr                                ; Shift left 3 to multiply by 8
    ROL tempAddr+1
    ASL tempAddr
    ROL tempAddr+1
    ASL tempAddr
    ROL tempAddr+1

    LDA #32
    STA tempAddr
    LDA #0
    STA tempAddr+1

    CLC                                         ; Add charset
    LDA tempAddr
    ADC #<charset
    STA tempAddr
    ADC #>charset
    STA tempAddr+1

    LDY #7                                      ; Copy to screen
.L1 LDA (tempAddr),Y
    STA (textPos),Y
    DEY
    BNE L1

    JSR teletextForward                         ; Move forward 1 char

    LDX tX                                      ; Restore A, X, Y
    LDY tY
    LDA tA
    RTS
}
