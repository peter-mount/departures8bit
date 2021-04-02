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
teletextInit = &C000

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
osascii = teletextInit + 3

; osnewl            Move cursor to the start of the next line
;
; on exit:
;   A   set to &0D
;   X   preserved
;   Y   preserved
;
osnewl = osascii + 4

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
oswrch = osnewl + 7

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

writeString = oswrch + 3

; refreshScreen     Refreshes the screen. Used when builk updating textRam
;                   e.g. loading the screen from disk.
;
; on exit:
;   A   undefined
;   X   undefined
;   Y   undefined
;
refreshScreen   = writeString + 3

showPrompt      = refreshScreen + 3
clearStatus     = showPrompt + 3
showStatus      = clearStatus + 3
