# cmakeModules

This repository contains helpful CMake modules for a variety of Xilinx build flows.

## Current release

The current release is meant to be used with the [Xilinx Vitis 2020.1 tools](https://www.xilinx.com/products/design-tools/vitis/vitis-platform.html).

## Older release tags

The older 2018.2 and 2018.3 tag has SDx compatible modules for cross-compiling designs for SDx (specifically, the SDSoC toolflow within SDx). Toolchain files are available for cross-compiling to target ARM code (toolchain_crosscomp_arm.cmake) or FPGA hw/sw designs via SDx/ SDSoC build flow (toolchain_sds.cmake). Additional support modules are useful to ensure the proper Xilinx build tools are present (e.g. FindVivadoHLS.cmake). 

An example is shown below for how to use the toolchain file when running CMake build to target FPGA hw/sw designs (SDx/SDSoC build flow). 
   ```bash
   $cmake .. -DCMAKE_TOOLCHAIN_FILE=<path to cmakeModules>/toolchain_sds.cmake
   ```

More examples can be found in the PYNQ-ComputerVision repo as described here: http://github.com/Xilinx/PYNQ-ComputerVision/blob/master/overlays/README.md.

Additional CMake build flows will be added to this repository, in particular support for future Xilinx flows that support OpenCL/ SDAccel and later tools.
