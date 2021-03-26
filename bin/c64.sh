#!/bin/bash
#
# Run vice to test the C64 app
reset
exec x64sc -verbose ./builds/depart.prg
