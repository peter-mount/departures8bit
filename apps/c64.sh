#!/bin/bash

exec beebasm -w -D bbc=0 -D bbcmaster=0 -D c64=1 -i c64.asm

exit 0

# &&\
/usr/local/bin/x64 \
      -verbose \
      ../builds/depart.prg
exit

exec /usr/local/bin/x64sc -default -warp \
      -rsuser \
      -rsuserdev 3 \
      -rsuserbaud 2400 \
      -rsdev3ip232 \
      ../builds/depart.prg

exec /usr/local/bin/x64 \
      -verbose \
      ../builds/depart.prg

exec /usr/local/bin/x64 ../builds/depart.prg
