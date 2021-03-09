; **********************************************************************
; lang      Our pseudo language
;
; This must be kept in sync with lang.go
;
; For tokens DO NOT REMOVE an entry as this means that all deployed
; instances in the wild will break as there's no versioning in the
; protocol!
; **********************************************************************

; Language tokens
TokenNoResponse     = 0     ; No response
TokenError          = 1     ; Error, shows an error message

; Lookup tokens
TokenStation        = 128   ; Station header used for departure boards
TokenTiploc         = 129   ; Tiploc lookup entry
TokenMessage        = 130   ; Station Messages

; Token lookup table that links the token's to code to run when they are
; "executed". Not all tokens are to be executed as some are data markers
; e.g. TokenTiploc holds the definition for a tiploc in the result so it
; has separate code to search those.
; As such, and as we can lookup a max of 128 tokens in a single page
; this table maps tokens 0..127. Tokens with bit 8 set (128+) are not
; executable and are used for these lookup items.
.langLookupTable
    EQUW    nop             ; 0 no response
    EQUW    langError       ; 1 error response

    INCLUDE "lang/memviewer.asm"

; langStart Reset PC to start of program
.langStart
    LDA #<dataBase              ; Point to the program start
    STA curLine
    LDA #>dataBase
    STA curLine+1
    RTS

; langExec              Execute's the program
.langExec
{
    JSR langStart               ; Point to the program start
    JSR memViewer
    JSR langStart               ; Point to the program start
.loop
    JSR langInvokeToken         ; Execute the current token
    JSR langNextLine            ; Move to the next line
    BNE loop                    ; Loop until we hit the end
    RTS
}

; langNextLine          Moves curLine to the next line in the program
;
; Returns:
;   A   undefined
;   Y   undefined
;   Z   set if curLine is at the end of the program
.langNextLine
    JSR langLineValid           ; Check we are not already at the end of the program
    BEQ nop                     ; exit if we already are
    LDY #0
    LDA (curLine),Y             ; Get low byte
    PHA                         ; Save to stack
    INY
    LDA (curLine),Y             ; Get high byte
    STA curLine+1               ; Set curLine high
    PLA                         ; Get low byte from stack & set curLine low
    STA curLine                 ; Roll through to langLineValid

; langLineValid         Checks to see if curLine is valid or we are at the end of the program
;
; Returns:
;   A   undefined
;   Z   set if curLine is at the end of the program
.langLineValid
    LDA curLine                 ; Z is set if curLine is zero
    BNE nop                     ; not zero so we have a current line
    LDA curLine+1               ; Check curLine+1 is zero
.nop                            ; Also used in lookup table for NOP commands
    RTS

; langGetToken          Gets the token for the current command
;
; Returns:
;   A   Token value if we have a current line
;   Y   undefined
;   N   set if token is a lookup, clear if executable
.langGetToken
    LDY #2                      ; byte 2 in line is the token
    LDA (curLine),Y
    RTS

; langInvoke            Executes the current line
;
.langInvokeToken
    JSR langGetToken
    BMI nop                     ; token is a lookup token so don't execute it
    ASL A                       ; *2
    TAX
IF bbcmaster
    JMP (langLookupTable,X)     ; 65C02 has this in 1 instruction
ELSE
    LDA langLookupTable,X       ; Pre 65C02 store address into tempAddr
    STA tempAddr
    LDA langLookupTable+1,X
    STA tempAddr+1
    JMP (tempAddr)              ; Jump to the code pointed to by tempAddr
ENDIF

; The language lines are stored in memory from dataBase.
; Each line consists of:
; 2 bytes for the address of the next line, 0x0000 marking the end of the "program"
; This is followed by the content of the line, normally terminating with 0 if a string
; but the 0 terminator isn't necessary for fixed format lines.

; relocateLang          Relocates the code at dataBase so that the next line addresses
;                       are correct. When first received these are based from 0x0000
;                       as the true address is dependent on the client.
;                       e.g. The BBC Micro, BBC Master 128 & C64 all use different values.
.relocateLang
{
    LDA #<dataBase
    STA tempAddr
    LDA #>dataBase
    STA tempAddr+1
.loop
    LDY #0
    LDA (tempAddr),Y        ; Check for 0x0000 for next line pointer
    BNE relocate            ; relocate line
    INY
    LDA (tempAddr),Y
    BNE relocate            ; relocate line
    RTS                     ; All done, leave last 0x0000 alone as that's correct
.relocate
    LDY #0
    CLC                     ; Add dataBase to the existing address
    LDA (tempAddr),Y
    ADC #<dataBase
    STA (tempAddr),Y        ; Update address in memory
    PHA                     ; Save lower half as we'll need it
    INY
    LDA (tempAddr),Y
    ADC #>dataBase
    STA (tempAddr),Y        ; Update address in memory
    STA tempAddr+1          ; Now update upper half of tempAddr to that address
    PLA                     ; Pull new lower half of new address
    STA tempAddr            ; & update lower half of tempAddr so it now points to new location
    JMP loop                ; Loop to check the next address
}

.langError
    LDA #COL_LIGHT_RED  ; Set text colour
    JSR setColour

    CLC
    LDA curLine
    ADC #3
    TAX
    LDA curLine+1
    ADC #0
    TAY
    JSR writeString

    LDA #COL_GREY1  ; Set text colour
    JMP setColour
