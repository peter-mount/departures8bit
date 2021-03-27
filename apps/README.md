# apps

This directory contains the sources to the individual apps, sharing where possible sources to remove duplication.

# BBC Master 128

This app is comprised of a ROM image

# BBC Model B

This app is comprised of a ROM image & a Disk/Tape loadable application.

## ROM
## Disk
## Tape

## Running in jsbeeb
Get JSbeeb running locally. Copy the rom over to jsbeeb then run

* http://localhost:8000/?&model=Master&rom=m128rom&embedBasic=%2ARAIL%0A
* http://localhost:8000/?&model=Master&rom=beebrail&embedBasic=%2ARAIL%0A
# Commodore 64

This app is comprised of a Disk image.

## Building

Run bin/c64.sh which will build builds/depart.prg

## Running in Vice

To run in vice you need to open 3 terminal windows, then run the following in each:
* ./bin/tcpser.sh
* ./builds/nrefeeds8bit
* ./bin/c64.sh


