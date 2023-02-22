###############################################################################
#  Copyright (c) 2020-2023, Xilinx, Inc.
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
#  VITIS_AIE2_LIBME - 'libme.a' with full path
#  VITIS_AIE2_LIBC - 'libc.a' with full path
#  VITIS_AIE2_LIBM - 'libm.a' with full path
#  VITIS_AIE2_LIBSOFTFLOAT - 'softfloat.a' with full path
#
## 3: Components
# The following components are supported:
#
#----------------------------------------------------------

include(FindPackageHandleStandardArgs)

set(aieVersionSpecficPath "aie_ml")

#if Xilinx tools correctly installed they are added to $ENV{PATH} one of CMake's default search paths
# Find AIE tools
find_program(VITIS_XCHESSCC xchesscc PATHS ${VITIS_ROOT}/aietools/bin)
if(NOT VITIS_XCHESSCC)
	message(STATUS "Unable to find xchesscc, needed to find AIE libs")
else(NOT VITIS_XCHESSCC)
	get_filename_component(_bindir ${VITIS_XCHESSCC} DIRECTORY)
	get_filename_component(VITIS_AIETOOLS_DIR ${_bindir} DIRECTORY)
endif(NOT VITIS_XCHESSCC)

# Find libme.a
find_library(VITIS_AIE2_LIBME me NO_DEFAULT_PATH CMAKE_FIND_ROOT_PATH_BOTH PATHS
		${VITIS_AIETOOLS_DIR}/data/${aieVersionSpecficPath}/lib/Release)
if(NOT VITIS_AIE2_LIBME)
	message(STATUS "Unable to find AIE2 libme.a")
else(NOT VITIS_AIE2_LIBME)
	message(STATUS "Found AIE2 libme.a: ${VITIS_AIE2_LIBME}")
endif(NOT VITIS_AIE2_LIBME)

# Find AIE LIBC
find_library(VITIS_AIE2_LIBC c NO_DEFAULT_PATH CMAKE_FIND_ROOT_PATH_BOTH PATHS
			${VITIS_AIETOOLS_DIR}/data/${aieVersionSpecficPath}/lib/runtime/lib/Release)
if(NOT VITIS_AIE2_LIBC)
	message(STATUS "Unable to find AIE2 libc.a")
else(NOT VITIS_AIE2_LIBC)
	message(STATUS "Found AIE2 libc.a:${VITIS_AIE2_LIBC}")
endif(NOT VITIS_AIE2_LIBC)

# Find AIE LIBM
find_library(VITIS_AIE2_LIBM m NO_DEFAULT_PATH CMAKE_FIND_ROOT_PATH_BOTH PATHS
			${VITIS_AIETOOLS_DIR}/data/${aieVersionSpecficPath}/lib/runtime/lib/Release)
if(NOT VITIS_AIE2_LIBM)
	message(STATUS "Unable to find AIE2 libm.a")
else(NOT VITIS_AIE2_LIBM)
	message(STATUS "Found AIE2 libm.a:${VITIS_AIE2_LIBM}")
endif(NOT VITIS_AIE2_LIBM)

# Find AIE LIBSOFTFLOAT
find_library(VITIS_AIE2_LIBSOFTFLOAT softfloat NO_DEFAULT_PATH CMAKE_FIND_ROOT_PATH_BOTH PATHS
			${VITIS_AIETOOLS_DIR}/data/${aieVersionSpecficPath}/lib/softfloat/lib/Release)
if(NOT VITIS_AIE2_LIBSOFTFLOAT)
	message(STATUS "Unable to find AIE2 libsoftfloat.a")
else(NOT VITIS_AIE2_LIBSOFTFLOAT)
	message(STATUS "Found AIE2 libsoftfloat.a:${VITIS_AIE2_LIBSOFTFLOAT}")
endif(NOT VITIS_AIE2_LIBSOFTFLOAT)

FIND_PACKAGE_HANDLE_STANDARD_ARGS(VitisAIE2 REQUIRED_VARS
		VITIS_AIETOOLS_DIR
		VITIS_AIE2_LIBME
		VITIS_AIE2_LIBC
		VITIS_AIE2_LIBM
		VITIS_AIE2_LIBSOFTFLOAT
	)
