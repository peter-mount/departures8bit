#!/bin/bash

beebasm -w -D bbc=0 -D bbcmaster=0 -D c64=1 -i c64.asm &&\
exec /usr/local/bin/x64 ../builds/depart.prg
