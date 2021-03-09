#!/bin/sh
#
# Run's tcpser when testing C64 with Vice
reset
exec tcpser -tsSiImM -v 25232 -s 1200 -l 7 -p 8023 -i "k0"
