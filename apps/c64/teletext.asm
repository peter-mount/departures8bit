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
                INCLUDE "kernal.asm"            ; Kernal constants

; Zero page 80-8F
                ORG &80
                GUARD &90
.textX          EQUB 0      ; X pos on screen, 0..39
.textY          EQUB 0      ; Y pos on screen, 0..24
.screenPos      EQUW 0      ; Position in screenRam
.textPos        EQUW 0      ; Position in textRam
.tA             EQUB 0      ; oscli save A,X,Y
.tX             EQUB 0
.tY             EQUB 0
.textCol        EQUB 0      ; Text colour during refreshLineColour
.textWorkLen    EQUB 0      ; Number of bytes remaining for sequence
.tempAddr       EQUW 0      ; Scratch address for teletextWrchr & refreshLineColour
.tempAddr2      EQUW 0      ; Scratch address for refreshLineColour

textRam         = &0400     ; Original screen memory used for text ram

                            ; Page 7 workspace (After the textScreen work area)
                            ; 07E8 - 07EF   8 free bytes
workBuffer      = &07F0     ; Storage of pending oswrch storage
                            ; 07FA - 07FF   6 free bytes
colourRam       = &CC00     ; 1K Screen ram for high res VIC-II colour
screenRam       = &E000     ; Location of VIC-II bitmap behind Kernal rom

defaultColour   = &10       ; White on Black at start of each line

; **********************************************************************
                ORG     &C000-2     ; Start of spare 4K ram, -2 for prg load address
                GUARD   colourRam   ; Start of colourRam
                EQUW    start       ; PRG file format header
.start                              ; of actual load address

; **********************************************************************
; Public entry points - Addresses of these can't change once defined!
;
; They should also be defined in teletext.inc so they can be referenced
; by user code.
; **********************************************************************
.initScreen     JMP initScreenInt               ; Initialise the screen, shows black
.refreshScreen  JMP refreshScreenInt            ; Refresh the screen to the buffer state
.osascii        CMP #&0D                        ; write byte expanding CR (0x0D)
                BNE oswrch                      ; to LF/CR sequence
.osnewl         LDA #&0A                        ; Output LF/CR sequence
                JSR oswrch
                LDA #&0D
.oswrch         JMP oswrchInt                   ; Write char to screen              VDU A
.clearScreen    JMP clearScreenInt              ; Clear the screen                  VDU 12
.setPos         JMP setPosInt                   ; Set text cursor location          VDU 31,X,Y

; **********************************************************************

.initScreenInt
    LDA &DD02                                   ; CIA2 bits 0,1 as output
    ORA #3
    STA &DD02

    LDA &DD00                                   ; Set VIC-II to point to upper 16K bank
    AND #&FC                                    ; Bits 0,1 = 0 for Bank 3
    STA &DD00

    LDA #&38                                    ; Screen at 0c00, bitmap at 2000 - from C000 bank
    STA &D018

    LDA #&08                                    ; Multicolour off, 40 col, xscroll=0
    STA &D016

    LDA &D011                                   ; Switch to high resolution mode
    ORA #&38                                    ; Enable bit 5 for high res
    STA &D011
                                                ; TODO disable RESTORE key? 0318 & 0328

    LDA #COL_BLACK
    STA &d020                                   ; Black border
    STA &d021                                   ; Black background
    STA textWorkLen                             ; reset oswrch work queue
                                                ; Run into clearScreen
.clearScreenInt
{
    LDY #0                                      ; Reset screen ram to same default colour
.L3 LDA #defaultColour                          ; Set default colour
    STA colourRam,Y
    STA colourRam + &100,Y
    STA colourRam + &200,Y
    STA colourRam + &300,Y
    LDA #' '                                    ; Set space in textRam
    STA textRam,Y
    STA textRam + &100,Y
    STA textRam + &200,Y
    STA textRam + &300,Y
    DEY
    BNE L3

    JSR teletextHome                            ; Reset pointers

    LDA #&00                                    ; Clear screen
    LDX #&20                                    ; &2000 bytes to clear
    LDY #0
.L1 STA (screenPos),Y                           ; Set screen memory
    INY
    BNE L1                                      ; Loop until page cleared
    INC screenPos+1                             ; Move to next page
    DEX
    BNE L1                                      ; Loop until all done
}                                               ; Run through to home cursor

.teletextHome                                   ; Move char cursor to the home
    LDA #0                                      ; Reset screen position
    STA textX                                   ; as A is always 0 reset X & Y
    STA textY
    STA screenPos
    STA textPos
    LDA #>screenRam                             ; screenPos = screenRam
    STA screenPos+1
    LDA #>textRam                               ; textPos = textRam
    STA textPos+1
    RTS

.setPosInt                                      ; Set cursor to X,Y
    STX textX                                   ; Store X & Y
    STY textY                                   ; then teletextRefreshPos to set screenPos

.teletextRefreshPos                             ; Set screenPos to textX,textY
{
    PHA                                         ; Save A & Y
    TYA
    PHA

    LDA textY                                   ; Index in m40 of textY
    ASL A
    TAY

    CLC                                         ; Calc textPos in textRam
    LDA m40,Y
    ADC #<textRam
    STA textPos
    LDA m40+1,Y
    ADC #>textRam
    STA textPos+1

    CLC                                         ; Add textX to textPos
    LDA textPos
    ADC textX
    STA textPos
    LDA textPos+1
    ADC #0
    STA textPos+1

    CLC                                         ; Calc screenPos in bitmap
    LDA m360,Y
    ADC #<screenRam
    STA screenPos
    LDA m360+1,Y
    ADC #>screenRam
    STA screenPos+1

    LDA textX                                   ; Index in m8 of textX
    ASL A
    TAY

    CLC                                         ; Add to screenPos
    LDA m8,Y
    ADC screenPos
    STA screenPos
    LDA m8+1,Y
    ADC screenPos+1
    STA screenPos+1

    PLA                                         ; Restore A & Y
    TAY
    PLA
    RTS
}

.oswrchInt                                      ; Write char A at the current position
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
    LDY textWorkLen                             ; Need to store in workBuffer
    BEQ S0                                      ; no so process it now
    STA workBuffer,Y                            ; Store in buffer, in reverse order, so +0 holds action & +1 last value, +2 first value
    DEC textWorkLen                             ; decrement
    BEQ Q0                                      ; we have enough data so process it
.Q1 RTS                                         ; Do nothing

.Q0 LDA workBuffer                              ; Check pending task
    CMP #31                                     ; TAB
    BNE Q1                                      ; For now all others are ignored
    LDX workBuffer+2                            ; workBuffer is 31, Y, X as data is in reverse order
    LDY workBuffer+1
    JMP setPos                                  ; Set new text position

.S0 CMP #32                                     ; >= 32 then render the character
    BPL L0

    PHA                                         ; Save control char
    ASL A                                       ; Convert to offset in table
    TAY
    LDA table,Y                                 ; Get pending byte count or address low byte
    STA workBuffer
    LDA table+1,Y                               ; Get high byte
    BEQ S1                                      ; 0 so low byte holds pending byte count
    STA workBuffer+1                            ; Save high byte
    PLA                                         ; Restore A
    JMP (workBuffer)                            ; Call vdu handler

.S1 LDA workBuffer                              ; Set textWorkLen to new value with the number
    STA textWorkLen                             ; of bytes to expect
    PLA                                         ; Restore A and set workBuffer so we know
    STA workBuffer                              ; the pending command
.*nop                                           ; NOP handler
    RTS                                         ; Stop here

.D0 JSR teletextBackward                        ; Backspace & delete
    LDA #' '                                    ; Move back 1 char
    LDY #0
    STA (textPos),Y                             ; Save char in textRam
    JMP teletextWrchr                           ; erase what's there & exit

.L0 CMP #127
    BEQ D0                                      ; Delete previous char

    LDY #0
    STA (textPos),Y                             ; Save char in textRam

    CMP #127                                    ; Render text char
    BMI L1
                                                ; TODO add double/single height check
                                                ; TODO add Graphics check before colour
.C0 AND #&08                                    ; Check if colour change
    BNE CE
    JSR refreshLineColour                       ; Refresh colours on this line

.CE LDA #' '                                    ; Render as space

.L1 JSR teletextWrchr                           ; Render requested character
}                                               ; Run into teletextForward to move forward 1 char

.teletextForward                                ; Move forward 1 char
                                                ; Unlike the other directions, this one is
                                                ; called the most so we do more work here
{                                               ; rather than recalculate the position every time
    INC textX                                   ; Increment X

    LDA textX                                   ; check still on current line
    CMP #40
    BPL L2                                      ; Move to next line

    CLC                                         ; As on same line just increment the pointers
    LDA screenPos                                 ; Add 8 to screenPos to move right 1 char
    ADC #8
    STA screenPos
    LDA screenPos+1
    ADC #0
    STA screenPos+1

    CLC                                         ; Increment textPos to next character
    LDA textPos
    ADC #1
    STA textPos
    LDA textPos+1
    ADC #0
    STA textPos+1

.L1 RTS

.L2 LDA #0                                      ; Move to start of next line
    STA textX                                   ; run into teletextDown

.*teletextDown                                  ; Move down 1 row
    INC textY                                   ; Increment Y
    LDA textY
    CMP #25                                     ; Check if below bottom of screen
    BMI L3                                      ; Not so just recalc pointers
    LDA #0                                      ; Point to row 0
    STA textY
.L3 JMP teletextRefreshPos                      ; refresh screenPos to correct address
}

.teletextBackward                               ; Move forward 1 char
{
    DEC textX                                   ; Decrement X
    BPL L1                                      ; Same line so just recalc pointers
    LDA #39                                     ; Move to end of prev line
    STA textX
.*teletextUp                                    ; Move up 1 row
    DEC textY
    BPL L1
    LDA #24                                     ; Move to bottom row & refresh pos
    STA textY
.L1 JMP teletextRefreshPos
}

.teletextStartLine                              ; Start new line, aka CR
    LDA #0                                      ; Set start of line
    STA textX
    JMP teletextRefreshPos                      ; refresh screenPos

; teletextWrchr     Write char in A to current text pos
.teletextWrchr
{
    CMP #0
    BMI L0                                      ; Skip teletext control char
    SEC                                         ; Subtract 32 for base of charset
    SBC #32
    BPL L1                                      ; We have a valid char
.L0 LDA #0                                      ; Use space for invalid chars
.L1 AND #&7F                                    ; Limit to 32..127
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
.L2 LDA (tempAddr),Y
    STA (screenPos),Y
    DEY
    BPL L2
    RTS
}

.refreshLineColour                              ; Refresh the current line's colours based on control chars
{
    PHA                                         ; Preserve A
    TYA                                         ; Preserve Y
    PHA
    LDA tA                                      ; Preserve tA
    PHA

    LDA textY                                   ; Get current line
    ASL A
    TAY

    CLC
    LDA m40,Y                                   ; Get textRam address for start of line
    ADC #<textRam
    STA tempAddr
    LDA m40+1,Y
    ADC #>textRam
    STA tempAddr+1

    CLC
    LDA m40,Y                                   ; Get colourRam address
    ADC #<colourRam
    STA tempAddr2
    LDA m40+1,Y
    ADC #>colourRam
    STA tempAddr2+1

    LDA #defaultColour                          ; Reset colour
    STA textCol

    LDX #40                                     ; 40 chars to process
    LDY #0                                      ; start of line
.L1 LDA (tempAddr),Y                            ; Get Char
    BPL L2                                      ; Ignore text

    CMP #156                                    ; Black background
    BNE S1
    LDA textCol                                 ; Clear background in lower nibble
    AND #&F0
    STA textCol
    JMP L2

.S1 CMP #157                                    ; New background from foreground
    BNE S2
    LDA textCol                                 ; Set background to that of foreground
    AND #&F0                                    ; Rotate upper nibble to lower
    SEC                                         ; Set carry as we want top bit set
    ROR A                                       ; ROR 4 times
    ROR A
    ROR A
    ROR A
    AND #&1F                                    ; Mask out top 3 bits so that we now
    STA textCol                                 ; have new background & white text
    JMP L2

                                                ; Translate to new text/graphics colour
.S2 AND #&0F                                    ; Lower nibble of command
    CMP #&08                                    ; Ignore >=8 as not a valid colour
    BPL L2
    STA textPos                                 ; Save colour offset

    LDA textCol                                 ; Clear upper nibble of textCol
    AND #&0F
    STA textCol

    TYA                                         ; Save Y
    PHA
    LDY textPos                                 ; Get offset to translation table
    LDA teletextColours,Y                       ; Colour conversion to VIC-II
    AND #&F0                                    ; we want upper nibble
    ORA textCol                                 ; Merge with TextCol
    STA textCol
    PLA                                         ; Restore Y
    TAY

.L2 LDA textCol                                 ; Get current colour
    STA (tempAddr2),Y                           ; Update colourRam
    INY                                         ; next character
    DEX
    BNE L1                                      ; Loop back for next colour

.E0 PLA                                         ; restore tA
    STA tA
    PLA                                         ; Restore Y
    TAY
    PLA                                         ; Restore A
    RTS
}

.refreshScreenInt                       ; Refresh screen
{
    LDA textX                           ; Save textX & Y
    PHA
    LDA textY
    PHA
    JSR L0
    PLA                                 ; Restore textX & Y
    STA textY
    PLA
    STA textX
    JMP teletextRefreshPos              ; Recalc addresses

.L0 LDA #<textRam                       ; Start at text ram start
    STA tA
    LDA #>textRam
    STA tA+1

    JSR teletextHome                    ; Home cursor
.L1 LDY #0                              ; Get char
    LDA (tA),Y
    JSR teletextWrchr                   ; Render it
    JSR teletextForward                 ; move forward
    LDA textX                           ; X | Y = 0 then we are back at home so complete
    BNE L2                              ; Skip if we are in this line
    JSR refreshLineColour               ; New line so refresh it's colour
.L2 ORA textY                           ; textX or textY = 0 when we are back at home
    BEQ L3                              ; for which we can exit
    INC tA                              ; Increment tA to next char
    BNE L1
    INC tA+1
    BNE L1                              ; Always the case so implicit BRA
.L3 RTS
}

.teletextColours                                ; Translation table for colours
                                                ; Upper & lower nibbles set to same value
    EQUB COL_BLACK + (COL_BLACK<<4)             ; 80 128 Alpha Black, not BBC but in some later BBCBasic for windows
    EQUB COL_RED + (COL_RED<<4)                 ; 81 129 Alphanumeric Red
    EQUB COL_GREEN + (COL_GREEN<<4)             ; 82 130 Alphanumeric Green
    EQUB COL_YELLOW + (COL_YELLOW<<4)           ; 83 131 Alphanumeric Yellow
    EQUB COL_BLUE + (COL_BLUE<<4)               ; 84 132 Alphanumeric Blue
    EQUB COL_PURPLE + (COL_PURPLE<<4)           ; 85 133 Alphanumeric Magenta
    EQUB COL_CYAN + (COL_CYAN<<4)               ; 86 134 Alphanumeric Cyan
    EQUB COL_WHITE + (COL_WHITE<<4)             ; 87 135 Alphanumeric White
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

; 8 * table for 0..39
.m8
    EQUW &0000, &0008, &0010, &0018, &0020, &0028, &0030, &0038, &0040, &0048
    EQUW &0050, &0058, &0060, &0068, &0070, &0078, &0080, &0088, &0090, &0098
    EQUW &00a0, &00a8, &00b0, &00b8, &00c0, &00c8, &00d0, &00d8, &00e0, &00e8
    EQUW &00f0, &00f8, &0100, &0108, &0110, &0118, &0120, &0128, &0130, &0138

; 40 * table for 0..24
.m40
    EQUW &0000, &0028, &0050, &0078, &00a0, &00c8, &00f0, &0118, &0140, &0168
    EQUW &0190, &01b8, &01e0, &0208, &0230, &0258, &0280, &02a8, &02d0, &02f8
    EQUW &0320, &0348, &0370, &0398, &03c0

; 360 * table for 0..24
.m360
    EQUW &0000, &0140, &0280, &03c0, &0500, &0640, &0780, &08c0, &0a00, &0b40
    EQUW &0c80, &0dc0, &0f00, &1040, &1180, &12c0, &1400, &1540, &1680, &17c0
    EQUW &1900, &1a40, &1b80, &1cc0, &1e00

; VDU command lookup table, either an address or number of additional bytes for the command
.table
    EQUW nop                ; 00 NUL does nothing
    EQUW 1                  ; 01 SOH Send next char to printer only
    EQUW nop                ; 02 STX Start print job
    EQUW nop                ; 03 ETX End print job
    EQUW nop                ; 04 EOT Write text at text cursor
    EQUW nop                ; 05 ENQ Write text at graphics cursor
    EQUW nop                ; 06 ACK Enable VDU drivers
    EQUW nop                ; 07 BEL Make a short beep
    EQUW teletextBackward   ; 08 BS  Backspace cursor one character
    EQUW teletextForward    ; 09 HT  Advance cursor one character
    EQUW teletextDown       ; 0A LF  Move cursor down one line
    EQUW teletextUp         ; 0B VT  Move cursor up one line
    EQUW clearScreen        ; 0C FF  Clear text area
    EQUW teletextStartLine  ; 0D CR  Move cursor to start of current line
    EQUW nop                ; 0E SO  Page mode on
    EQUW nop                ; 0F SI  Page mode off
    EQUW nop                ; 10 DLE Clear graphics area
    EQUW 1                  ; 11 DC1 Define text colour
    EQUW 2                  ; 12 DC2 Define graphics colour
    EQUW 5                  ; 13 DC3 Define logical colour
    EQUW nop                ; 14 DC4 Restore default logical colours
    EQUW nop                ; 15 NAK Disable VDU drivers or delete current line
    EQUW 1                  ; 16 SYN Select screen mode
    EQUW 9                  ; 17 ETB Define display character & other commands
    EQUW 8                  ; 18 CAN Define graphics window
    EQUW 5                  ; 19 EM  Plot K,x,y
    EQUW nop                ; 1A SUB Restore default windows
    EQUW nop                ; 1B ESC Does nothing
    EQUW 4                  ; 1C FS  Define text window
    EQUW 4                  ; 1D GS  Define graphics origin
    EQUW teletextHome       ; 1E RS  Home text cursor to top left
    EQUW 2                  ; 1F US  Move text cursor to x,y

    INCLUDE "charset.asm"   ; Include our char definitions
.end

    SAVE "teletext", start-2, end
