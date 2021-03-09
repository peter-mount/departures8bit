#!/bin/bash
#
# Compile the C64 application

exec beebasm -w -D bbc=0 -D bbcmaster=0 -D c64=1 -i c64/main.asm
