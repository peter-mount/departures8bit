#!/bin/bash

beebasm -w -D bbc=0 -D c64=1 -i c64.asm &&\
x64 ../builds/depart.prg
