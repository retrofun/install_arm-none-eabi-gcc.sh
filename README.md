install_arm-none-eabi-gcc.sh
============================

This is an updated version of the `install_arm-none-eabi-gcc.sh` bash script from the
[MiST devel repository](https://github.com/mist-devel/mist-board/blob/master/tools/install_arm-none-eabi-gcc.sh)
to create a cross-compilation environment for the arm-none-eabi target based on the blog post 
[Trials, Tribulations and Toolchains](http://retroramblings.net/?p=315).

The resulting gcc compiler is used to compile the [MiST firmware](https://github.com/mist-devel/mist-firmware).

**Attention!** With binutils >= 2.36 the MiST firmware must be at least [commit ad2b407](https://github.com/mist-devel/mist-firmware/commit/ad2b407). Otherwise if you flash the binaries on your MiST it will not work and you have to [recover](https://github.com/mist-devel/mist-board/wiki/HowToInstallTheFirmware) it.

The [Canon Hack Development Kit](https://chdk.fandom.com/wiki/CHDK) (CHDK) can be compiled with it, too.

Currently used components:
* [binutils 2.37](https://ftp.gnu.org/gnu/binutils/)
* [gcc 11.1.0](https://ftp.gnu.org/gnu/gcc/)
* [newlib 4.1.0](https://sourceware.org/pub/newlib/)
