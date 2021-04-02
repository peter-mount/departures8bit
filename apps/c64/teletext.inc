; **********************************************************************
; Teletext emulator - public entry points
; **********************************************************************

; teletextInit      Initialise emulator
;
; on exit:
;   A   undefined
;   X   undefined
;   Y   undefined
;
teletextInit    = &C000             ; Initialise emulator

; writeString       Write null terminated string at XY.
;                   This routine will terminate at the first null in the string
;                   that is not part of an extended char sequence.
;
;                   e.g. 'hello world',0 is a simple string
;
;                   31, 0, 10, 'hello world', 0 is also valid but the first 0 is
;                   part of the 31,x,y sequence so does not terminate the string.
;
; on entry:
;   XY  Address of string to write
;
; on exit:
;   A   preserved
;   X   preserved
;   Y   preserved
;

writeString     = teletextInit + 3  ; Write null terminated string in XY

; refreshScreen     Refreshes the screen. Used when builk updating textRam
;                   e.g. loading the screen from disk.
;
; on exit:
;   A   undefined
;   X   undefined
;   Y   undefined
;
refreshScreen   = writeString + 3   ; Refresh the screen

; osascii           Write A to the screen. CR will start a new line instead of
;                   moving the cursor to the start of the current line.
;
; on entry:
;   A   Character to write
;
; on exit:
;   A   preserved
;   X   preserved
;   Y   preserved
;
osascii         = refreshScreen + 3 ; write byte expanding CR (0x0D)

; osnewl            Move cursor to the start of the next line
;
; on exit:
;   A   set to &0D
;   X   preserved
;   Y   preserved
;
osnewl          = osascii + 4       ; Output LF/CR sequence

; oswrch            Write A to the screen, handling any control sequences
;
; on entry:
;   A   Character to write
;
; on exit:
;   A   preserved
;   X   preserved
;   Y   preserved
;
oswrch          = osnewl + 7        ; Write char to screen

; clearScreen       Clears the screen.
;
;                   This is a convenience method which is quicker than calling
;                   LDA #12:JSR oswrch
;
; on exit:
;   A   undefined
;   X   undefined
;   Y   undefined
;
clearScreen     = oswrch + 3        ; Clear the screen

; setPos            Set the text cursor location.
;
;                   This is a convenience method which is quicker than calling
;                   LDA #31:JSR oswrch
;                   LDA #X:JSR oswrch
;                   LDA #Y:JSR oswrch
;
; on entry:
;   X   Text X  0..39 inclusive
;   Y   Text Y  0..24 inclusive
;
; on exit:
;   A   preserved
;   X   preserved
;   Y   preserved
;
setPos          = clearScreen + 3   ; Set text cursor location
