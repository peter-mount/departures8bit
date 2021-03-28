# apps

This directory contains the sources to the individual apps, sharing where possible sources to remove duplication.

## BBC Master 128

This app is comprised of a ROM image

## Commodore 64

This app is comprised of a Disk image.

# Memory Map

| Name | BBC Master | C64 | Usage |
| ---- | ---------- | --- | ----- |
| | | 0000 - 0001 | 6510 IO port |
| | 0000 - 0001 | | Unused |
| | 0002 - 008F |0002 - 008F | Our Zero Page workspace |
| | 0090 - 00FF | 0090 - 00FF | MOS/Kernal zero page |
| | 0100 - 01FF | 0100 - 01FF | 6502 stack |
| | 0200 - 03FF | 0200 - 03FF | MOS/Kernal workspace |
| rs232OutputBuffer | 0900-09FF | 0400 - 04FF | RS232 Output Buffer, fixed on BBC movable on C64 |
| rs232InputBuffer | 0A00 - 0AFF | 0500 - 05FF | RS232 Input Buffer, fixed on BBC movable on C64 |
| outputBuffer | 0400 - 04FF | 0600 - 06FF | General purpose string manipulation |
| | 0500 - 07FF | 0700 - 07FF | Free |
| | 0800 - 08FF | | MOS workspace, printer buffer
| | 0B00 - 0BFF | | MOS soft keys, Econet |
| | 0C00 - 0CFF | | MOS Char defs, Econet |
| | 0D00 - 0DFF | | MOS NMI/ROM workspace |
| | | 0800 - 08FF | Basic loader, can be reused once running |
| | | 0900 | C64 Application entry point |
| page | _variable_ | _variable_ | Start of database memory, first page after application |
| highmem | 8000 | CC00 | First address after database memory |
| | 8000 - BFFF | | BBC Application ROM
| | C000 - DBFF | | Sidewars ROM workspace* |
| screenRam | | CC00 - CFFF | 1K for screen colour definitions |
| | | D000 - DFFF | C64 IO addresses
| | DC00 - DCFF | | OSCLI string buffer* |
| | DD00 - DE00 | | Transient command workspace* |
| | DF00 - DFFF | | Filing system control variables* |
| | FC00 - FCFF | | Fred IO* |
| | FD00 - FDFF | | Jim IO* |
| | FE00 - FEFF | | Sheila IO* |
| screenBase | | E000 - FFFF | 8K raster for screen |

Notes:
* \* included for reference only.
* C000-DFFF is specific to the BBC Master. Not available on the BBC Model B/Electron.
  It's only included here incase we want to try to squeeze more memory at a future date.
  Unlikely whilst we have 3 spare pages at 0500-07FF available.
* On BBC the lowest available ram is 0E00 although on BBC B/Electron it can be higher with filesystem usage - the Master has alternate memory.
* The upper ram on BBC & C64 is 7FFF but on the C64 we can page out Basic giving us an additional 8K + a 4K unused block which we do use.
* The BBC has 0400-07FF reserved for the running language, which we are, so we use that.
  Likewise on the C64 we use that space as it's the default screen location but as we relocate that, we use it as well.
* The C64 page 08 holds our basic loader which is unused once running so we can reuse that if necessary. 

