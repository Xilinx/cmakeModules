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

# cmake -DCMAKE_TOOLCHAIN_FILE=toolchain_crosscomp_arm.cmake ..
#  -DVitisArch="arm32 or arm64"
#  -DVitisSysroot="absolute path to the sysroot folder"

set(VitisArch "arm64" CACHE STRING "ARM arch: arm64 or arm32")

list(APPEND CMAKE_TRY_COMPILE_PLATFORM_VARIABLES VitisSysroot VitisArch)

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

if (${VitisArch} STREQUAL "arm64") # 64 bit toolchain
  SET (CMAKE_SYSTEM_PROCESSOR aarch64)
  SET (gnuPrefix1 aarch64-linux)
  SET (gnuPrefix2 aarch64-linux-gnu)
  SET (gnuArch aarch64)
  SET (sysrootPrefix aarch64-xilinx-linux)
  #extra compilation flags
  #NONE
else (${VitisArch} STREQUAL "arm64") #32 bit toolchain
  SET (CMAKE_SYSTEM_PROCESSOR arm)
  SET (gnuPrefix1 gcc-arm-linux-gnueabi)
  SET (gnuPrefix2 arm-linux-gnueabihf)
  SET (gnuArch aarch32)
  SET (sysrootPrefix cortexa9t2hf-neon-xilinx-linux-gnueabi)
  #extra compilation flags
  SET (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D__ARM_PCS_VFP")

endif (${VitisArch} STREQUAL "arm64")


# specify the cross compiler
set(CMAKE_C_COMPILER ${VitisRoot}/gnu/${gnuArch}/${VitisHostSystemName}/${gnuPrefix1}/bin/${gnuPrefix2}-gcc)
set(CMAKE_CXX_COMPILER ${VitisRoot}/gnu/${gnuArch}/${VitisHostSystemName}/${gnuPrefix1}/bin/${gnuPrefix2}-g++)
set(CMAKE_LINKER ${VitisRoot}/gnu/${gnuArch}/${VitisHostSystemName}/${gnuPrefix1}/bin/aarch64-linux-gnu-ld)
set(CMAKE_AR ${VitisRoot}/gnu/${gnuArch}/${VitisHostSystemName}/${gnuPrefix1}/bin/${gnuPrefix2}-ar)

#find sysroot first try the command line argument VitisSysroot, then try to find it as part Vitis
find_path(VitisSysrootAsFound "usr/include/stdlib.h" PATHS ${VitisSysroot} PATH_SUFFIXES "" NO_DEFAULT_PATH)
find_path(VitisSysrootAsFound "usr/include/stdlib.h" PATHS "${VitisRoot}/gnu/${gnuArch}/${VitisHostSystemName}/${gnuPrefix1}/${sysrootPrefix}/" PATH_SUFFIXES "" NO_DEFAULT_PATH)
find_path(VitisSysrootAsFound "usr/include/stdlib.h" PATHS "${CMAKE_FIND_ROOT_PATH}/libc" PATH_SUFFIXES "" NO_DEFAULT_PATH)
MESSAGE ("Vitis sysroot: " ${VitisSysrootAsFound})

# set up cross compilation paths
set(TEST_ORIGIN $ORIGIN/../lib/)
message("ORIGIN: " ${TEST_ORIGIN})
set(CMAKE_SYSROOT ${VitisSysrootAsFound})
set(CMAKE_FIND_ROOT_PATH ${VitisSysrootAsFound})
#set(CMAKE_FIND_ROOT_PATH ${VitisRoot}/gnu/${gnuArch}/${VitisHostSystemName}/${gnuPrefix1}/${gnuPrefix2})
SET (CMAKE_SKIP_BUILD_RPATH FALSE)
SET (CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)
#SET (CMAKE_INSTALL_RPATH ${VitisSysrootAsFound}/usr/lib;${VitisSysrootAsFound}/lib${VitisSysrootAsFound}/lib/${gnuPrefix2};${VitisSysrootAsFound}/usr/lib/${gnuPrefix2})
#SET (CMAKE_LIBRARY_PATH ${VitisSysrootAsFound}/lib;${VitisSysrootAsFound}/usr/lib;${VitisSysrootAsFound}/lib/${gnuPrefix2};${VitisSysrootAsFound}/usr/lib/${gnuPrefix2})
SET (CMAKE_INSTALL_RPATH ${VitisSysrootAsFound}/lib/${gnuPrefix2};${VitisSysrootAsFound}/usr/lib/${gnuPrefix2})
SET (CMAKE_LIBRARY_PATH ${VitisSysrootAsFound}/lib/${gnuPrefix2};${VitisSysrootAsFound}/usr/lib/${gnuPrefix2})
set (CMAKE_INCLUDE_PATH ${VitisSysrootAsFound}/usr/)
# adjust the default behavior of the find commands:
# search headers and libraries in the target environment
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
# search programs in the host environment
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)

# -rpath-link needed in 2018.2 reVISION sysroots
#SET (CMAKE_SHARED_LINKER_FLAGS "--sysroot=${VitisSysrootAsFound} -Wl,-rpath-link,${VitisSysrootAsFound}/lib:${VitisSysrootAsFound}/usr/lib:${VitisSysrootAsFound}/lib/${gnuPrefix2}:${VitisSysrootAsFound}/usr/lib/${gnuPrefix2}" CACHE STRING "" FORCE)
#SET (CMAKE_EXE_LINKER_FLAGS "--sysroot=${VitisSysrootAsFound} -Wl,-rpath-link,${VitisSysrootAsFound}/lib:${VitisSysrootAsFound}/usr/lib:${VitisSysrootAsFound}/lib/${gnuPrefix2}:${VitisSysrootAsFound}/usr/lib/${gnuPrefix2}" CACHE STRING "" FORCE)