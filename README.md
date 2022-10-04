# cmakeModules

This repository contains helpful CMake modules for a variety of Xilinx build flows.

## Current release

The current release is meant to be used with the [Xilinx Vitis 2022.1 tools](https://www.xilinx.com/products/design-tools/vitis/vitis-platform.html).

There are two main toolchains:

(1) Vitis cross compiler toolchain (toolchain_vitis_crosscomp_arm.cmake)

(2) Clang cross compiler toolchain (toolchain_clang_crosscomp_arm.cmake)

The toolchains are invoked as most standard toolchains but with two additionally defined parameters (Arch, Sysroot).

```bash
$cmake .. -DCMAKE_TOOLCHAIN_FILE=<path to cmakeModules>/<target toolchain file> -DArch=<arm32|arm64> -DSysroot=<absoluate path to sysroot folder>
```
In both cases, the sysroot folder can be the default Vitis sysroot, a Petalinux generated sysroot or a standard Ubuntu-based sysroot like those built by PYNQ. In the case when you're working with more custom sysroots like Vitis or Petalinux, you should use the toolchain `toolchain_clang_crosscomp_arm_petalinux.cmake` which provides additional guidance to find the necessary libraries. Note that this file may need to be edited depending if you're using 2022.1 or an older tool version. See the `toolchain_clang_crosscomp_arm_petalinux.cmake` header for more information.


