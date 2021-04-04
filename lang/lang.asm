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
    EQUW    nop                 ; 0 no response
    EQUW    langError           ; 1 error response

; langStart Reset PC to start of program
.langStart
    LDA page                    ; Point to the program start at PAGE
    STA curLine
    LDA page+1
    STA curLine+1
    RTS

; langExec              Execute's the program
.langExec
{
    JSR langStart               ; Point to the program start
    JSR memViewer
    rts
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
    BEQ nop                     ; exit if we already are at the end
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
    JSR langStart           ; Start from the beginning
.loop
    JSR langLineValid       ; Check line is valid
    BEQ checkToken          ; last one so leave last 0x0000 alone as that's correct

    LDY #0
    CLC                     ; Add PAGE to the existing address
    LDA (curLine),Y
    ADC page
    STA (curLine),Y        ; Update address in memory
    INY
    LDA (curLine),Y
    ADC page+1
    STA (curLine),Y        ; Update address in memory

.checkToken
    JSR langGetToken        ; Now check the token
    ;BMI relocateTable       ; It's a lookup table that needs relocating

.nextLine
    JSR langNextLine
    BNE loop                ; Loop to check the next address
    RTS
}

; Relocate the lookup table pointed to by curLine.
;
; Here we add curLine to each offset so it points to a real address
;
; Lookup table consists of:
; 00 Address of next line
; 02 Token with bit 8 set
; 03 Number of entries
; 04 Offset of first entry
;
; This supports tables up to 126 entries long
.relocateTable
{
    LDY #3                  ; Get number of entries into tempChar
    LDA (curLine),Y
    BEQ end                 ; Table is actually empty
    STA tempChar            ; save length
    LDX #0                  ; X is the current index
.loop
    TXA                     ; Get current index
    ASL A                   ; *2 to get offset of entry in line
    CLC
    ADC #4                  ; index starts at 4
    TAY                     ; into Y

    CLC                     ; add curLine to the entry value
    LDA (curLine),Y
    ADC curLine
    STA (curLine),Y
    INY
    LDA (curLine),Y
    ADC curLine+1
    STA (curLine),Y

    INX                     ; next entry
    DEC tempChar
    BNE loop
.end
    RTS
}

.langError
IF c64
    LDA #COL_LIGHT_RED  ; Set red text colour
    JSR setColour
ENDIF

    CLC
    LDA curLine
    ADC #3
    TAX
    LDA curLine+1
    ADC #0
    TAY
IF c64
    JSR writeString     ; write string

    LDA #COL_GREY1      ; Restore text colour
    JMP setColour
ELSE
    JMP writeString     ; Just write the error string
ENDIF
