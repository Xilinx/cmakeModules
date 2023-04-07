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

#     Author: Kristof Denolf <kristof.denolf@amd.com>
#             Stephen Neuendorffer <stephen.neuendorffer@amd.com>
#     Date:   2018/9/23

# cmake -DCMAKE_TOOLCHAIN_FILE=toolchain_clang_crosscomp_arm.cmake ..
#  -DArch="arm32 or arm64"
#  -DSysroot="absolute path to the sysroot folder"


set(Arch "arm64" CACHE STRING "ARM arch: arm64 or arm32")
set(pythonVer "3.8" CACHE STRING "python version in sysroot")
list(APPEND CMAKE_TRY_COMPILE_PLATFORM_VARIABLES Sysroot Arch pythonVer)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_LIST_DIR})

#include(toolchain_crosscomp_arm)
# give the system information
SET (CMAKE_SYSTEM_NAME Linux)

if (${Arch} STREQUAL "arm64") # 64 bit toolchain
  SET (CMAKE_SYSTEM_PROCESSOR aarch64)
  SET (gnuPrefix1 aarch64-linux)
  SET (gnuPrefix2 aarch64-linux-gnu)
  SET (gnuArch aarch64-linux-gnu)
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
# make sure clang is available 
find_program(CLANG_CC clang REQUIRED)

set(CMAKE_C_COMPILER clang)
set(CMAKE_C_COMPILER_TARGET ${gnuArch})
set(CMAKE_CXX_COMPILER clang++)
set(CMAKE_CXX_COMPILER_TARGET ${gnuArch})
set(CMAKE_ASM_COMPILER clang)
set(CMAKE_STRIP llvm-strip)
set(CLANG_LLD lld)

#set compile flags
set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS}" CACHE STRING "" FORCE)
set(CMAKE_ASM_FLAGS "${CMAKE_C_FLAGS}" CACHE STRING "" FORCE)

# set up cross compilation paths
set(CMAKE_SYSROOT ${Sysroot})
set(CMAKE_FIND_ROOT_PATH ${Sysroot})
set(CMAKE_SKIP_BUILD_RPATH FALSE)
set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)
# Ensure that we build relocatable binaries
set(CMAKE_INSTALL_RPATH $ORIGIN) #set(CMAKE_INSTALL_RPATH ${Sysroot}/usr/lib/${sysrootPrefix}/11.2.0)
set(CMAKE_LIBRARY_PATH ${Sysroot}/usr/lib)
set(CMAKE_INCLUDE_PATH ${Sysroot}/usr/)
# adjust the default behavior of the find commands:
# search headers and libraries in the target environment
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
# search programs in the host environment
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)

# clang specifics
set(CMAKE_EXE_LINKER_FLAGS "-Wl,-z,notext -fuse-ld=lld" CACHE STRING "" FORCE)
set(CMAKE_SHARED_LINKER_FLAGS "-Wl,-z,notext -fuse-ld=lld" CACHE STRING "" FORCE)

# # Python
# We have to explicitly set this extension.  Normally it would be determined by FindPython3, but
# it's inference mechanism doesn't work when cross-compiling
set(PYTHON_MODULE_EXTENSION ".cpython-38-aarch64-linux-gnu.so")
set(Python3_ROOT_DIR ${Sysroot}/bin)

set(Python_ROOT ${Sysroot}/usr/local/lib/python${pythonVer}/dist-packages)
set(Python3_NumPy_INCLUDE_DIR ${Python_ROOT}/numpy/ CACHE STRING "" FORCE)
