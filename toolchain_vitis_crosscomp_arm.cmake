###############################################################################
#  Copyright (c) 2019, Xilinx, Inc.
#  All rights reserved.
# 
#  Redistribution and use in source and binary forms, with or without 
#  modification, are permitted provided that the following conditions are met:
#
#  1.  Redistributions of source code must retain the above copyright notice, 
#     this list of conditions and the following disclaimer.
#
#  2.  Redistributions in binary form must reproduce the above copyright 
#      notice, this list of conditions and the following disclaimer in the 
#      documentation and/or other materials provided with the distribution.
#
#  3.  Neither the name of the copyright holder nor the names of its 
#      contributors may be used to endorse or promote products derived from 
#      this software without specific prior written permission.
#
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
#  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
#  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR 
#  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR 
#  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
#  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
#  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
#  OR BUSINESS INTERRUPTION). HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
#  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
#  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
#  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
###############################################################################

#     Authors: Kristof Denolf <kristof@xilinx.com> 
#              Alireza Khodamoradi <alirezak@xilinx.com>
#     Date:   2022/09/28
#     NOTE: Currenlty only Vitis default sysroot tested and supported

# cmake -DCMAKE_TOOLCHAIN_FILE=toolchain_vitis_crosscomp_arm.cmake ..
#  -DArch="arm32 or arm64"
#  -DSysroot="absolute path to the sysroot folder"

set(Arch "arm64" CACHE STRING "ARM arch: arm64 or arm32")

list(APPEND CMAKE_TRY_COMPILE_PLATFORM_VARIABLES Sysroot Arch)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_LIST_DIR})
set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY" CACHE STRING "" FORCE)

#find Vitis 
set(CMAKE_FIND_LIBRARY_PREFIXES "lib")
set(CMAKE_FIND_LIBRARY_SUFFIXES ".a;.so")
find_package(Vitis REQUIRED)
set(VitisRoot ${VITIS_ROOT})

# give the system information
SET (CMAKE_SYSTEM_NAME Linux)

if (WIN32)
  SET(VitisHostSystemName "nt")
else (WIN32)
  SET(VitisHostSystemName "lin")
endif (WIN32)

if (${Arch} STREQUAL "arm64") # 64 bit toolchain
  SET (CMAKE_SYSTEM_PROCESSOR aarch64)
  SET (gnuPrefix1 aarch64-linux)
  SET (gnuPrefix2 aarch64-linux-gnu)
  SET (gnuArch aarch64)
  SET (sysrootPrefix aarch64-xilinx-linux)
  #extra compilation flags
  #NONE
else (${Arch} STREQUAL "arm64") #32 bit toolchain
  SET (CMAKE_SYSTEM_PROCESSOR arm)
  SET (gnuPrefix1 gcc-arm-linux-gnueabi)
  SET (gnuPrefix2 arm-linux-gnueabihf)
  SET (gnuArch aarch32)
  SET (sysrootPrefix cortexa9t2hf-neon-xilinx-linux-gnueabi)
  #extra compilation flags
  SET (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D__ARM_PCS_VFP")

endif (${Arch} STREQUAL "arm64")


# specify the cross compiler
set(CMAKE_C_COMPILER ${VitisRoot}/gnu/${gnuArch}/${VitisHostSystemName}/${gnuPrefix1}/bin/${gnuPrefix2}-gcc)
set(CMAKE_CXX_COMPILER ${VitisRoot}/gnu/${gnuArch}/${VitisHostSystemName}/${gnuPrefix1}/bin/${gnuPrefix2}-g++)
set(CMAKE_LINKER ${VitisRoot}/gnu/${gnuArch}/${VitisHostSystemName}/${gnuPrefix1}/bin/aarch64-linux-gnu-ld)
set(CMAKE_AR ${VitisRoot}/gnu/${gnuArch}/${VitisHostSystemName}/${gnuPrefix1}/bin/${gnuPrefix2}-ar)

#find sysroot first try the command line argument Sysroot, then try to find it as part Vitis
find_path(VitisSysrootAsFound "usr/include/stdlib.h" PATHS ${Sysroot} PATH_SUFFIXES "" NO_DEFAULT_PATH)
find_path(VitisSysrootAsFound "usr/include/stdlib.h" PATHS "${VitisRoot}/gnu/${gnuArch}/${VitisHostSystemName}/${gnuPrefix1}/${sysrootPrefix}/" PATH_SUFFIXES "" NO_DEFAULT_PATH)
find_path(VitisSysrootAsFound "usr/include/stdlib.h" PATHS "${CMAKE_FIND_ROOT_PATH}/libc" PATH_SUFFIXES "" NO_DEFAULT_PATH)
MESSAGE ("Vitis sysroot: " ${VitisSysrootAsFound})

# set up cross compilation paths
set(CMAKE_SYSROOT ${VitisSysrootAsFound})
set(CMAKE_FIND_ROOT_PATH ${VitisSysrootAsFound})
set(CMAKE_SKIP_BUILD_RPATH FALSE)
set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)
# Ensure that we build relocatable binaries
set(CMAKE_INSTALL_RPATH $ORIGIN)
set(CMAKE_LIBRARY_PATH ${VitisSysrootAsFound}/usr/lib)
set(CMAKE_INCLUDE_PATH ${VitisSysrootAsFound}/usr/)
# adjust the default behavior of the find commands:
# search headers and libraries in the target environment
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
# search programs in the host environment
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
