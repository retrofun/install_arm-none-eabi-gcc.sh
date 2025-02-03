install_arm-none-eabi-gcc.sh
============================

This is a bash script to create a cross-compilation environment for the arm-none-eabi target based on information of several sources. For details see the comments at the top of the script.

The resulting gcc compiler can be used to compile the [firmware](https://github.com/mist-devel/mist-firmware) for [MiST](https://github.com/mist-devel/mist-board/wiki) and [SiDi128](https://github.com/ManuFerHi/SiDi-FPGA/wiki).

The [Canon Hack Development Kit](https://chdk.fandom.com/wiki/CHDK) (CHDK) can be compiled with it, too.

Components currently used:
* [binutils 2.44](https://ftp.gnu.org/gnu/binutils/)
* [gcc 13.3.0](https://ftp.gnu.org/gnu/gcc/)
* [newlib 4.5.0.20241231](https://sourceware.org/pub/newlib/)

This script uses the `-j` option of `make` command with the number of available CPU threads. Compile time on a 6 cores/12 threads AMD Ryzen 5 3600XT is about 20 minutes.
