; ********************************************************************************
; Network module
; ********************************************************************************

initNetwork         = &BA00
dialServer          = initNetwork + 3
hangUp              = dialServer + 3
sendCommand         = hangUp + 3
outputReset         = sendCommand + 3
outputTerminate     = outputReset + 3
outputAppendHexChar = outputTerminate + 3
outputAppend        = outputAppendHexChar + 3
outputAppendString  = outputAppend + 3
writeOutputBuffer   = outputAppendString + 3
