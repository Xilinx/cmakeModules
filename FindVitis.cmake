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
#  VITIS_VPP - The path to 'v++'
#  VITIS_ROOT - The path to the Vitis/$VERSION directory
#  VITIS_XCHESS_MAKE - The path to 'xchessmk'
#  VITIS_LIBME - The path to 'libme.a'
#  VITIS_AIE_LIBC - The path to the AIEngine version of 'libc.a'
#  VITIS_AIE_LIBM - The path to the AIEngine version of 'libm.a'
#----------------------------------------------------------

include(FindPackageHandleStandardArgs)

#if Xilinx tools correctly installed they are added to $ENV{PATH} one of CMake's default search paths

# Find v++
find_program(VITIS_VPP v++)
if(NOT VITIS_VPP)
	message(STATUS "Unable to find v++")
else(NOT VITIS_VPP)
	message(STATUS "Found v++:${VITIS_VPP}")
	get_filename_component(VITIS_PARENT ${VITIS_VPP} PATH)
	get_filename_component(VITIS_ROOT ${VITIS_PARENT} PATH)
endif(NOT VITIS_VPP)

# Find AIE tools
find_program(VITIS_XCHESS_MAKE xchessmk)
if(NOT VITIS_XCHESS_MAKE)
	message(STATUS "Unable to find xchessmk")
else(NOT VITIS_XCHESS_MAKE)
	message(STATUS "Found xchessmk:${VITIS_XCHESS_MAKE}")
	get_filename_component(_bindir ${VITIS_XCHESS_MAKE} DIRECTORY)
	get_filename_component(VITIS_AIETOOLS_DIR ${_bindir} DIRECTORY)
endif(NOT VITIS_XCHESS_MAKE)

find_library(VITIS_LIBME me NO_DEFAULT_PATH CMAKE_FIND_ROOT_PATH_BOTH PATHS
			${VITIS_AIETOOLS_DIR}/data/cervino/lib/Release)
if(NOT VITIS_LIBME)
	message(STATUS "Unable to find libme.a")
else(NOT VITIS_LIBME)
	message(STATUS "Found libme.a:${VITIS_LIBME}")
endif(NOT VITIS_LIBME)

find_library(VITIS_AIE_LIBC c NO_DEFAULT_PATH CMAKE_FIND_ROOT_PATH_BOTH PATHS
			${VITIS_AIETOOLS_DIR}/data/cervino/lib/runtime/lib/Release)
if(NOT VITIS_AIE_LIBC)
	message(STATUS "Unable to find AIE libc.a")
else(NOT VITIS_AIE_LIBC)
	message(STATUS "Found AIE libc.a:${VITIS_AIE_LIBC}")
endif(NOT VITIS_AIE_LIBC)

find_library(VITIS_AIE_LIBM m NO_DEFAULT_PATH CMAKE_FIND_ROOT_PATH_BOTH PATHS
			${VITIS_AIETOOLS_DIR}/data/cervino/lib/runtime/lib/Release)
if(NOT VITIS_AIE_LIBM)
	message(STATUS "Unable to find AIE libm.a")
else(NOT VITIS_AIE_LIBM)
	message(STATUS "Found AIE libm.a:${VITIS_AIE_LIBM}")
endif(NOT VITIS_AIE_LIBM)

find_path(VITIS_INCLUDE_DIR "hls_stream.h" PATHS ${VITIS_ROOT}/include)

if(NOT VITIS_INCLUDE_DIR)
	message(STATUS "Unable to find Vitis include folder")
else(NOT VITIS_INCLUDE_DIR)
	message(STATUS "Found Vitis include folder: ${VITIS_INCLUDE_DIR}")
endif(NOT VITIS_INCLUDE_DIR)

FIND_PACKAGE_HANDLE_STANDARD_ARGS(Vitis REQUIRED_VARS
		VITIS_ROOT
		VITIS_VPP
		VITIS_AIETOOLS_DIR
		VITIS_XCHESS_MAKE
		VITIS_LIBME
		VITIS_AIE_LIBC
		VITIS_AIE_LIBM
		VITIS_INCLUDE_DIR)
