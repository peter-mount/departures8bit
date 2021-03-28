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

defaultColour   = &10                           ; White on Black at start of each line

.teletextColours                                ; Translation table for colours
    EQUB COL_BLACK                              ; 80 128 Alpha Black, not BBC but in some later BBCBasic for windows
    EQUB COL_RED                                ; 81 129 Alphanumeric Red
    EQUB COL_GREEN                              ; 82 130 Alphanumeric Green
    EQUB COL_YELLOW                             ; 83 131 Alphanumeric Yellow
    EQUB COL_BLUE                               ; 84 132 Alphanumeric Blue
    EQUB COL_PURPLE                             ; 85 133 Alphanumeric Magenta
    EQUB COL_CYAN                               ; 86 134 Alphanumeric Cyan
    EQUB COL_WHITE                              ; 87 135 Alphanumeric White
    ; 88 136    flash
    ; 89 137    steady
    ; 8C 140    normal height
    ; 8D 141    double height
    ; 91-97     Graphics colours like teletextColours
    ; 98        conceal
    ; 99 153    contiguous graphics
    ; 9A 154    separated graphics
    ; 9C 156    black background
    ; 9D 157    new blackground (takes current foreground)
    ; 9E 158    hold graphics
    ; 9F 159    release graphics

; *40 table
.m40
    EQUW &0000, &0028, &0050, &0078, &00a0, &00c8, &00f0, &0118, &0140, &0168
    EQUW &0190, &01b8, &01e0, &0208, &0230, &0258, &0280, &02a8, &02d0, &02f8
    EQUW &0320, &0348, &0370, &0398, &03c0

.initScreen
    LDA &DD02                                   ; CIA2 bits 0,1 as output
    ORA #3
    STA &DD02

    LDA &DD00                                   ; Set VIC-II to point to upper 16K bank
    AND #&FC                                    ; Bits 0,1 = 0 for Bank 3
    STA &DD00

    LDA #&38                                    ; Screen at 0c00, bitmap at 2000 - from C000 bank
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

.setDefaultColour                               ; Set default colour in textCol & A
    LDA #defaultColour
    STA textCol                                 ; Save for rendering
    RTS

                                                ; Run into clearScreen
.clearScreen
{
    JSR setDefaultColour                        ; Set default colour
    LDY #0                                      ; Reset screen ram to same default colour
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
{
    CLC                                         ; Add 8 to textPos to move right 1 char
    LDA textPos
    ADC #8
    STA textPos
    LDA textPos+1
    ADC #0
    STA textPos+1

    INC textX                                   ; Increment X
    LDA textX
    CMP #screenWidth
    BMI end                                     ; still on current line
    BPL teletextStartNextLine

    LDA #0                                      ; Move to start next line
    STA textX
    INC textY
    LDA textY
    CMP #25
    BPL wrapAround                              ; Still on screen
.end
    RTS
.wrapAround
    LDA #0                                      ; Move to top row
    STA textY
    JMP teletextRefreshPos
}

.teletextBackward                               ; Move forward 1 char
{
    SEC                                         ; Sub 8 to textPos to move left 1 char
    LDA textPos
    SBC #8
    STA textPos
    LDA textPos+1
    SBC #0
    STA textPos+1

    DEC textX                                   ; Decrement X
    BPL end

    LDA #39                                     ; Move to end of prev line
    STA textX
    DEC textY
    BMI wrapAround
.end
    RTS
.wrapAround
    LDA #24                                     ; Move to bottom row & refresh pos
    STA textY
    JMP teletextRefreshPos
}

.teletextStartNextLine                          ; Move to next line
    LDA #0                                      ; Start of line
    STA textX
.teletextDown                                   ; Move down 1 row
{
    INC textY                                   ; Increment Y
    LDA textY
    CMP #screenHeight                           ; Check if below bottom of screen
    BMI L1                                      ; Not so skip
    LDA #0                                      ; Point to row 0
    STA textY
.L1 JMP teletextRefreshPos                      ; refresh textPos to correct address
}

.osascii                                        ; write byte expanding CR (0x0D)
    CMP #&0D                                    ; to LF/CR sequence
    BNE oswrch
.osnewl                                         ; Output LF/CR sequence
    LDA #&0A
    JSR oswrch
    LDA #&0D
.oswrch                                         ; Write char A at the current position
{
    STA tA                                      ; Save A, X, Y to scratch ram
    STX tX
    STY tY
    JSR oswrchImpl
    LDX tX                                      ; Restore A, X, Y
    LDY tY
    LDA tA
    RTS

.oswrchImpl
    CMP #127                                    ; Backspace & delete
    BNE S0

    JSR teletextBackward                        ; Move back 1 char
    LDA #' '                                    ; erase what's there
    JMP teletextWrchr

.S0 CMP #32                                     ; >= 32 then render the character
    BPL L0

    CMP #10                                     ; LF down one line
    BNE S1
    JMP teletextDown                            ; Move down 1 row

.S1 CMP #12                                     ; FF Clear screen
    BNE S2
    JMP clearScreen

.S2 CMP #13                                     ; CR Start of current line
    BNE S3
    LDA #0                                      ; Set start of line
    STA textX
    JMP teletextRefreshPos                      ; refresh textPos

.S3 CMP #8                                      ; BS back 1 char
    BNE S4                                      ; exit until we add more
    JMP teletextBackward                        ; Move back 1 char

.S4 CMP #30                                     ; Home
    BNE S5
    JMP teletextHome                            ; Move cursor to home

.S5 LDA #'#'                                    ; Unknown so just space

.L0 CMP #128
    BMI L1                                      ; A between 32 & 127 so render char
    CMP #136                                    ; 128-135 text colour
    BPL C1

.C0                                             ; Set foreground colour from A
    AND #&07                                    ; extract colour code
    TAY
    LDA teletextColours,Y                       ; get C64 colour
    ASL A                                       ; Shift to high nibble
    ASL A
    ASL A
    ASL A
    TAY                                         ; Save in Y
    LDA textCol                                 ; Mask out foreground
    AND #&0F
    STA textCol
    TAY                                         ; Swap back Y
    ORA textCol                                 ; OR into textCol as theres no OR with Y
    STA textCol
    JMP CE

.C1

.CE LDA #' '                                    ; Render as space

.L1 JSR teletextWrchr                           ; Render requested character
    JSR teletextForward                         ; Move forward 1 char
.end
    RTS
}

; teletextWrchr     Write char in A to current text pos
.teletextWrchr
    SEC                                         ; Subtract 32 for base of charset
    SBC #32
    STA tempAddr                                ; Store as 16bit offset
    LDA #0
    STA tempAddr+1

    ASL tempAddr                                ; Shift left 3 to multiply by 8 to
    ROL tempAddr+1                              ; align with char data
    ASL tempAddr
    ROL tempAddr+1
    ASL tempAddr
    ROL tempAddr+1

    CLC                                         ; Add charset to get final pointer
    LDA tempAddr
    ADC #<charset
    STA tempAddr
    LDA tempAddr+1
    ADC #>charset
    STA tempAddr+1

    LDY #7                                      ; Copy character to screen
.L1 LDA (tempAddr),Y
    STA (textPos),Y
    DEY
    BPL L1
    RTS

.teletextSetColour                              ; Update line from textX with colour in A
{
    STA textCol                                 ; Save colour

    LDA #<screenRam                             ; Work out position
    STA tempAddr
    LDA #>screenRam
    STA tempAddr+1

    LDA textY                                   ; Add textY * 40
    ASL A
    TAY
    CLC
    LDA tempAddr
    ADC m40,Y
    STA tempAddr
    LDA tempAddr+1
    ADC m40+1,Y
    STA tempAddr+1

    LDX textX                                   ; Now loop setting the colour until we hit the
    LDA textCol                                 ; end of the current line
.L1 STA (tempAddr),Y
    INY
    CPY #40
    BMI L1
    RTS
}
