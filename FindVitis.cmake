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
#  VITIS_DSPLIB_INCLUDE_DIR - 'dsplib' with full include path
#
## 3: Components
# The following components are supported:
###  3.1. AIE
#  VITIS_AIE_INCLUDE_DIR - AIE full include path
#  VITIS_AIE_LIBME - 'libme.a' with full path
#  VITIS_AIE_LIBC - 'libc.a' with full path
#  VITIS_AIE_LIBM - 'libm.a' with full path
#  VITIS_AIE_RUNTIME_INCLUDE_DIR - AIE runtime full include path
#  VITIS_AIE_LIBSOFTFLOAT - 'softfloat.a' with full path
#
### 3.2. AIE2
#  VITIS_AIE2_INCLUDE_DIR - AIE2 full include path
#  VITIS_AIE2_LIBME - 'libme.a' with full path
#  VITIS_AIE2_LIBC - 'libc.a' with full path
#  VITIS_AIE2_LIBM - 'libm.a' with full path
#  VITIS_AIE2_RUNTIME_INCLUDE_DIR - AIE2 runtime full include path
#  VITIS_AIE2_LIBSOFTFLOAT - 'softfloat.a' with full path

### 3.2. AIE2P
#  VITIS_AIE2P_INCLUDE_DIR - AIE2P full include path
#  VITIS_AIE2P_LIBME - 'libme.a' with full path
#  VITIS_AIE2P_LIBC - 'libc.a' with full path
#  VITIS_AIE2P_LIBM - 'libm.a' with full path
#  VITIS_AIE2P_RUNTIME_INCLUDE_DIR - AIE2P runtime full include path
#  VITIS_AIE2P_LIBSOFTFLOAT - 'softfloat.a' with full path
#----------------------------------------------------------

include(FindPackageHandleStandardArgs)

list(LENGTH Vitis_FIND_COMPONENTS componentsSize)
if(componentsSize EQUAL 0)
 	message(STATUS "Error: AIE version needed as COMPONENT, setting AIE as default")
	list(APPEND Vitis_FIND_COMPONENTS "AIE")
endif()

#if Xilinx tools correctly installed they are added to $ENV{PATH} one of CMake's default search paths

# Find v++
find_program(VITIS_VPP v++)
if(NOT VITIS_VPP)
	message(STATUS "Unable to find v++")
else(NOT VITIS_VPP)
	message(STATUS "Found v++: ${VITIS_VPP}")
	get_filename_component(VITIS_PARENT ${VITIS_VPP} PATH)
	get_filename_component(VITIS_ROOT ${VITIS_PARENT} PATH)
	execute_process(COMMAND ${VITIS_VPP} -v
		OUTPUT_VARIABLE vppVersionOutput	
	)
	string(REGEX MATCH "v[0-9]+\.[0-9]" vppVersionNumber ${vppVersionOutput})
	string(REGEX MATCH "[0-9]+" vppVersionMajor ${vppVersionNumber})
	string(REGEX MATCH "[0-9]$" vppVersionMinor ${vppVersionNumber})
	message(STATUS "v++ version number: ${vppVersionNumber}")
	if(NOT vppVersionNumber)
		message(FATAL_ERROR "Vitis version not found")
		return()
	endif()

	if(NOT DEFINED Vitis_FIND_VERSION)
		set(Vitis_VERSION_MAJOR ${vppVersionMajor})
		set(Vitis_VERSION_MINOR ${vppVersionMinor})
	else()
		if (${vppVersionMajor} LESS ${Vitis_FIND_VERSION_MAJOR})
			message(STATUS "Error: Vitis major version is too old")
		elseif((${vppVersionMajor} EQUAL ${Vitis_FIND_VERSION_MAJOR}) AND (${vppVersionMinor} LESS ${Vitis_FIND_VERSION_MINOR}))
			message(STATUS "Error: Vitis minor version is too old")
		else()
			set(Vitis_VERSION_MAJOR ${vppVersionMajor})
			set(Vitis_VERSION_MINOR ${vppVersionMinor})
		endif()
	endif()
endif(NOT VITIS_VPP)

# Find AIE tools
if(VITIS_VPP)
	find_package(AIETools ${Vitis_VERSION_MAJOR}.${Vitis_VERSION_MINOR} COMPONENTS ${Vitis_FIND_COMPONENTS})
else()
	find_package(AIETools COMPONENTS ${Vitis_FIND_COMPONENTS})
endif(VITIS_VPP)
set(VITIS_AIETOOLS_DIR ${AIETOOLS_DIR})
set(VITIS_XCHESSCC ${AIETOOLS_XCHESSCC})
set(VITIS_XCHESS_MAKE ${AIETOOLS_XCHESS_MAKE})

# Find AIE tools components
foreach(comp ${Vitis_FIND_COMPONENTS})
	message(STATUS "looking for component: ${comp}")

	if(${comp} STREQUAL "AIE")
		set(aieVersionSpecificPath "versal_prod")
	elseif(${comp} STREQUAL "AIE2")
		set(aieVersionSpecificPath "aie_ml")
	elseif(${comp} STREQUAL "AIE2P")
		set(aieVersionSpecificPath "aie2p")
	else()
		message(ERROR "${comp} not supported")
		set(aieVersionSpecificPath "unknown")
	endif()

	# Find aie_core.h
	set(VITIS_${comp}_INCLUDE_DIR ${AIETOOLS_${comp}_INCLUDE_DIR})

	# Find libme.a
	set(VITIS_${comp}_LIBME ${AIETOOLS_${comp}_LIBME})

	# Find AIE LIBC
	set(VITIS_${comp}_LIBC ${AIETOOLS_${comp}_LIBC})

	# Find AIE LIBM
	set(VITIS_${comp}_LIBM ${AIETOOLS_${comp}_LIBM})

	# Find assert.h in AIE runtime include dir
	set(VITIS_${comp}_RUNTIME_INCLUDE_DIR ${AIETOOLS_${comp}_RUNTIME_INCLUDE_DIR})

	# Find AIE LIBSOFTFLOAT
	set(VITIS_${comp}_LIBSOFTFLOAT ${AIETOOLS_${comp}_LIBSOFTFLOAT})

	#find_package(Vitis${comp})
	if (VITIS_${comp}_INCLUDE_DIR AND VITIS_${comp}_LIBME AND VITIS_${comp}_LIBC AND VITIS_${comp}_LIBM AND VITIS_${comp}_RUNTIME_INCLUDE_DIR AND VITIS_${comp}_LIBSOFTFLOAT)
		set(Vitis_${comp}_FOUND TRUE)
	endif()

endforeach()

# Find DSPLIB include
find_path(VITIS_DSPLIB_INCLUDE_DIR "fir.h" PATHS ${VITIS_ROOT}/include/dsplib
		CMAKE_FIND_ROOT_PATH_BOTH)

if(NOT VITIS_DSPLIB_INCLUDE_DIR)
	message(STATUS "Unable to find Vitis DSPLIB")
else(NOT VITIS_DSPLIB_INCLUDE_DIR)
	message(STATUS "Found Vitis DSPLIB include folder: ${VITIS_DSPLIB_INCLUDE_DIR}")
	set(Vitis_DSPLIB_FOUND TRUE)
endif(NOT VITIS_DSPLIB_INCLUDE_DIR)

FIND_PACKAGE_HANDLE_STANDARD_ARGS(Vitis HANDLE_COMPONENTS REQUIRED_VARS
		VITIS_ROOT
		VITIS_VPP
		VITIS_AIETOOLS_DIR
		VITIS_XCHESSCC
		VITIS_XCHESS_MAKE
		Vitis_VERSION_MAJOR
		Vitis_VERSION_MINOR
		)
