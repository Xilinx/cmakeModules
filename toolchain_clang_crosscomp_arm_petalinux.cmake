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

#     Author: Jack Lo <jack.lo@amd.com>
#             Kristof Denolf <kristof.denolf@amd.com>
#     Date:   2022/10/04

# cmake -DCMAKE_TOOLCHAIN_FILE=toolchain_clang_crosscomp_arm_petalinux.cmake ..
#  -DArch="arm32 or arm64"
#  -DSysroot="absolute path to the sysroot folder"

# NOTE: If the directory 
# ${Sysroot}/usr/lib/${sysrootPrefix}/${gccVer} changes signficiantly,
# you may need to modify it entirely.

# NOTE: earlier version of Vitis sysroot refrence earlier gcc, e.g. 10.2.0 for 2021.2
set(gccVer "11.2.0" CACHE STRING "gcc version used in sysroot") # 2022.1
set(pythonVer "3.8" CACHE STRING "python version in sysroot")
list(APPEND CMAKE_TRY_COMPILE_PLATFORM_VARIABLES gccVer)

include(toolchain_clang_crosscomp_arm)

# Vitis/PetaLinux sysroot specific 
set(CMAKE_C_FLAGS "-Wl,-z,notext -I${Sysroot}/usr/include/c++/${gccVer} -I${Sysroot}/usr/include/c++/${gccVer}/${sysrootPrefix} -B ${Sysroot}/usr/lib/${sysrootPrefix}/${gccVer} -Wl,-rpath-link=${Sysroot}/usr/lib/${sysrootPrefix}/${gccVer} --target=${gnuArch} -Wno-unused-command-line-argument -L${Sysroot}/usr/lib/${sysrootPrefix}/${gccVer}" CACHE STRING "" FORCE)

# TODO: Does this need -L?
set(CMAKE_SHARED_LINKER_FLAGS "-Wl,-z,notext -fuse-ld=lld -B ${Sysroot}/usr/lib/${sysrootPrefix}/${gccVer} -L${Sysroot}/usr/lib/${sysrootPrefix}/${gccVer}" CACHE STRING "" FORCE)

# TODO: Does this need -L?
set(CMAKE_EXE_LINKER_FLAGS "-Wl,-z,notext -fuse-ld=lld -B ${Sysroot}/usr/lib/${sysrootPrefix}/${gccVer} -L${Sysroot}/usr/lib/${sysrootPrefix}/${gccVer}" CACHE STRING "" FORCE)

#set(CMAKE_C_IMPLICIT_LINK_LIBRARIES gcc_s CACHE STRING "" FORCE) 
#set(CMAKE_CXX_IMPLICIT_LINK_LIBRARIES gcc_s CACHE STRING "" FORCE)

# TODO: these need to be redeclared here since CMAKE_C_FLAGS is defeind later?
#set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS}" CACHE STRING "" FORCE) 
#set(CMAKE_ASM_FLAGS "${CMAKE_C_FLAGS}" CACHE STRING "" FORCE)

# # Python
# We have to explicitly set this extension.  Normally it would be determined by FindPython3, but
# it's inference mechanism doesn't work when cross-compiling
set(PYTHON_MODULE_EXTENSION ".cpython-38-aarch64-linux-gnu.so")
set(Python3_ROOT_DIR ${Sysroot}/bin)

set(Python_ROOT ${Sysroot}/usr/local/lib/python${pythonVer}/dist-packages)
set(Python3_NumPy_INCLUDE_DIR ${Python_ROOT}/numpy/ CACHE STRING "" FORCE)