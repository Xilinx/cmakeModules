###############################################################################
#  Copyright (c) 2020-2021, Xilinx, Inc.
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

###########################################################
#
## 1: Setup:
# The following environmental variables are optionally searched for defaults:
#  none.
#
## 2: Variables
# The following are set after configuration is done: 
#  
#  VITIS_VPP - 'v++' with full path
#  VITIS_ROOT - The path to the Vitis/$VERSION directory
#  VITIS_XCHESSCC - 'xchesscc' with full path
#  VITIS_XCHESS_MAKE - 'xchessmk' with full path
#  VITIS_LIBME - 'libme.a' with full path
#  VITIS_AIE_LIBC - 'libc.a' with full path
#  VITIS_AIE_LIBM - 'libm.a' with full path
#
## 3: Components
# The following components are supported:
#
#  DSPLIB - the DSPLIB header library
#     VITIS_DSPLIB_INCLUDE_DIR: the include directory for DSPLIB
#----------------------------------------------------------

include(FindPackageHandleStandardArgs)

#if Xilinx tools correctly installed they are added to $ENV{PATH} one of CMake's default search paths

# Find v++
find_program(VITIS_VPP v++)
if(NOT VITIS_VPP)
	message(STATUS "Unable to find v++")
else(NOT VITIS_VPP)
	message(STATUS "Found v++: ${VITIS_VPP}")
	get_filename_component(VITIS_PARENT ${VITIS_VPP} PATH)
	get_filename_component(VITIS_ROOT ${VITIS_PARENT} PATH)
endif(NOT VITIS_VPP)

# Find AIE tools
find_program(VITIS_XCHESSCC xchesscc PATHS ${VITIS_ROOT}/cardano/bin ${VITIS_ROOT}/aietools/bin)
if(NOT VITIS_XCHESSCC)
	message(STATUS "Unable to find xchesscc")
else(NOT VITIS_XCHESSCC)
	message(STATUS "Found xchesscc: ${VITIS_XCHESSCC}")
	get_filename_component(_bindir ${VITIS_XCHESSCC} DIRECTORY)
	get_filename_component(VITIS_AIETOOLS_DIR ${_bindir} DIRECTORY)
endif(NOT VITIS_XCHESSCC)

find_program(VITIS_XCHESS_MAKE xchessmk PATHS ${VITIS_ROOT}/cardano/bin ${VITIS_ROOT}/aietools/bin)
if(NOT VITIS_XCHESS_MAKE)
	message(STATUS "Unable to find xchessmk")
else(NOT VITIS_XCHESS_MAKE)
	message(STATUS "Found xchessmk: ${VITIS_XCHESS_MAKE}")
	get_filename_component(_bindir ${VITIS_XCHESS_MAKE} DIRECTORY)
	get_filename_component(VITIS_AIETOOLS_DIR ${_bindir} DIRECTORY)
endif(NOT VITIS_XCHESS_MAKE)

# Find libme.a
find_library(VITIS_LIBME me NO_DEFAULT_PATH CMAKE_FIND_ROOT_PATH_BOTH PATHS
			${VITIS_AIETOOLS_DIR}/data/cervino/lib/Release)
if(NOT VITIS_LIBME)
	message(STATUS "Unable to find libme.a")
else(NOT VITIS_LIBME)
	message(STATUS "Found libme.a: ${VITIS_LIBME}")
endif(NOT VITIS_LIBME)

# Find AIE LIBC
find_library(VITIS_AIE_LIBC c NO_DEFAULT_PATH CMAKE_FIND_ROOT_PATH_BOTH PATHS
			${VITIS_AIETOOLS_DIR}/data/cervino/lib/runtime/lib/Release)
if(NOT VITIS_AIE_LIBC)
	message(STATUS "Unable to find AIE libc.a")
else(NOT VITIS_AIE_LIBC)
	message(STATUS "Found AIE libc.a:${VITIS_AIE_LIBC}")
endif(NOT VITIS_AIE_LIBC)

# Find AIE LIBM
find_library(VITIS_AIE_LIBM m NO_DEFAULT_PATH CMAKE_FIND_ROOT_PATH_BOTH PATHS
			${VITIS_AIETOOLS_DIR}/data/cervino/lib/runtime/lib/Release)
if(NOT VITIS_AIE_LIBM)
	message(STATUS "Unable to find AIE libm.a")
else(NOT VITIS_AIE_LIBM)
	message(STATUS "Found AIE libm.a:${VITIS_AIE_LIBM}")
endif(NOT VITIS_AIE_LIBM)

# Find AIE LIBSOFTFLOAT
find_library(VITIS_AIE_LIBSOFTFLOAT softfloat NO_DEFAULT_PATH CMAKE_FIND_ROOT_PATH_BOTH PATHS
			${VITIS_AIETOOLS_DIR}/data/cervino/lib/softfloat/lib/Release)
if(NOT VITIS_AIE_LIBSOFTFLOAT)
	message(STATUS "Unable to find AIE libsoftfloat.a")
else(NOT VITIS_AIE_LIBSOFTFLOAT)
	message(STATUS "Found AIE libsoftfloat.a:${VITIS_AIE_LIBSOFTFLOAT}")
endif(NOT VITIS_AIE_LIBSOFTFLOAT)

# Find DSPLIB include
find_path(VITIS_DSPLIB_INCLUDE_DIR "fir.h" PATHS ${VITIS_ROOT}/include/dsplib)

if(NOT VITIS_DSPLIB_INCLUDE_DIR)
	message(STATUS "Unable to find Vitis DSPLIB")
else(NOT VITIS_DSPLIB_INCLUDE_DIR)
	message(STATUS "Found Vitis DSPLIB include folder: ${VITIS_DSPLIB_INCLUDE_DIR}")
	set(Vitis_DSPLIB_FOUND YES)
endif(NOT VITIS_DSPLIB_INCLUDE_DIR)

FIND_PACKAGE_HANDLE_STANDARD_ARGS(Vitis HANDLE_COMPONENTS REQUIRED_VARS
		VITIS_ROOT
		VITIS_VPP
		VITIS_AIETOOLS_DIR
		VITIS_XCHESSCC
		VITIS_XCHESS_MAKE
		VITIS_LIBME
		VITIS_AIE_LIBC
		VITIS_AIE_LIBM
		VITIS_AIE_LIBSOFTFLOAT)

