# Development notes

## Commodore 64
### VICE emulator
#### Installation
I'm running Vice 3.4 on Ubuntu 20.04. I did find it was missing all rom images under `/usr/lib/vice/DRIVES/` so disk
drives were not working. I ended up downloading the current vice (3.5) sources from Sourceforge and manually copying the files
from that directory into the 3.4 installation (no compilation just the rom images).

#### Virtual disk configuration
In settings -> Peripheral devices -> Drive pick a drive (8 used here) and set:
* True drive emulation
* Drive sound emulation (optional but set in my working setup)
* Drive Type:
  * Select CBM 1541
* IEC (OpenCBM)
* Device type: File system
* File system device settings:
  * directory - browse to the `builds` directory of this project
  * clear `Convert P00`, `Save P00` & `Hide non-P00` settings

This is my `~/.config/vice/vicerc` on linux:

    [C64]
    Window0Height=631
    Window0Width=719
    Window0Xpos=2092
    Window0Ypos=1114
    SoundDeviceName="pulse"
    SoundBufferSize=100
    VICIIVideoCache=1
    SidEngine=1
    SidModel=1
    RsUserEnable=1
    RsUserDev=2
    IECDevice8=1
    FileSystemDevice9=1
    FSDevice8Dir="/mnt/area51/dev/departures8bit/builds"
    FSDevice9Dir="/mnt/area51/dev/departures8bit/builds/"
    FSDevice8ConvertP00=0
    DriveSoundEmulation=1
    Drive8Type=1541
    Acia1Base=56832
