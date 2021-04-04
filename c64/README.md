# Departure Boards C64

## Memory Map

The following is the C64 memory map as seen by this application:

| Page | Name | Usage |
| ---- | ---- | ----- |
| 0000 - 0001 | | 6510 IO port
| 0002 - 008F | | Our Zero Page workspace |
| 0090 - 00FF | | Kernal zero page |
| 0100 - 01FF | | 6502 stack |
| 0200 - 03FF | | Kernal workspace |
| 0400 - 04FF | rs232OutputBuffer | RS232 Output Buffer |
| 0500 - 05FF | rs232InputBuffer | RS232 Input Buffer |
| 0600 - 06FF | outputBuffer | General purpose string manipulation |
| 0700 - 07FF | | Free |
| 0800 - 08FF | | Basic loader, can be reused once running |
| 0900 | | Application entry point |
| | (page) | Start of database memory, first page after application |
| CC00 | (highmem) | First address after database memory |
| CC00 - CFFF | screenRam | 1K for screen colour definitions |
| D000 - DFFF | | C64 IO addresses
| E000 - FFFF | screenBase | 8K raster for screen |

The screen is relocated to E000 which is 8K ram behind the Kernal ROM.
Due to how the C64 works, we can write to the RAM but without paging out the rom, reading returns the ROM.
However the VIC-II chip will always read from the RAM so we get both working at the same time without loosing 8K of RAM.
The colour definitions still needs 1K of ram in the same 16K block the VIC-II is using, so we use CC00-CFFF for that.

Note: I read that DOS uses CC00 for workspace, but as we don't use it whilst running we should be ok. Worse case senario
is if the screen colours get corrupted, in which case we can move it to any location between C000 & CC00 (in 1K blocks).

## Running in Vice

To run in vice you need to open 3 terminal windows, then run the following in each:
* ./bin/tcpser.sh
* ./builds/nrefeeds8bit
* ./bin/c64.sh
