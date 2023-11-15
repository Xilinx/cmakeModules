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
#----------------------------------------------------------

include(FindPackageHandleStandardArgs)

list(LENGTH Vitis_FIND_COMPONENTS componentsSize)
if(componentsSize EQUAL 0)
 	message(STATUS "Error: AIE version needed as COMPONENT, setting AIE as default")
	list(APPEND Vitis_FIND_COMPONENTS "AIE")
endif()

#if Xilinx tools correctly installed they are added to $ENV{PATH} one of CMake's default search paths

# Find v++
find_program(VITIS_VPP v++ PATHS "${VITIS_ROOT}/bin")
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
find_program(VITIS_XCHESSCC xchesscc PATHS ${VITIS_ROOT}/aietools/bin)
if(NOT VITIS_XCHESSCC)
	message(STATUS "Unable to find xchesscc")
else(NOT VITIS_XCHESSCC)
	message(STATUS "Found xchesscc: ${VITIS_XCHESSCC}")
	get_filename_component(_bindir ${VITIS_XCHESSCC} DIRECTORY)
	get_filename_component(VITIS_AIETOOLS_DIR ${_bindir} DIRECTORY)
endif(NOT VITIS_XCHESSCC)

find_program(VITIS_XCHESS_MAKE xchessmk PATHS ${VITIS_ROOT}/aietools/bin)
if(NOT VITIS_XCHESS_MAKE)
	message(STATUS "Unable to find xchessmk")
else(NOT VITIS_XCHESS_MAKE)
	message(STATUS "Found xchessmk: ${VITIS_XCHESS_MAKE}")
	get_filename_component(_bindir ${VITIS_XCHESS_MAKE} DIRECTORY)
	get_filename_component(VITIS_AIETOOLS_DIR ${_bindir} DIRECTORY)
endif(NOT VITIS_XCHESS_MAKE)

# Find DSPLIB include
find_path(VITIS_DSPLIB_INCLUDE_DIR "fir.h" PATHS ${VITIS_ROOT}/include/dsplib
		CMAKE_FIND_ROOT_PATH_BOTH)

if(NOT VITIS_DSPLIB_INCLUDE_DIR)
	message(STATUS "Unable to find Vitis DSPLIB")
else(NOT VITIS_DSPLIB_INCLUDE_DIR)
	message(STATUS "Found Vitis DSPLIB include folder: ${VITIS_DSPLIB_INCLUDE_DIR}")
	set(Vitis_DSPLIB_FOUND TRUE)
endif(NOT VITIS_DSPLIB_INCLUDE_DIR)

# Find Components
foreach(comp ${Vitis_FIND_COMPONENTS})
	message(STATUS "looking for component: ${comp}")

	if(${comp} STREQUAL "AIE")
		set(aieVersionSpecificPath "versal_prod")
	elseif(${comp} STREQUAL "AIE2")
		set(aieVersionSpecificPath "aie_ml")
	endif()

	# Find aie_core.h
	find_path(VITIS_${comp}_INCLUDE_DIR "aie_core.h" PATHS ${VITIS_AIETOOLS_DIR}/data/${aieVersionSpecificPath}/lib
			NO_DEFAULT_PATH CMAKE_FIND_ROOT_PATH_BOTH)
	if(NOT VITIS_${comp}_INCLUDE_DIR)
		message(STATUS "Unable to find ${comp} include dir")
	else(NOT VITIS_${comp}_INCLUDE_DIR)
		message(STATUS "Found ${comp} include folder: ${VITIS_${comp}_INCLUDE_DIR}")
	endif(NOT VITIS_${comp}_INCLUDE_DIR)

	# Find libme.a
	find_library(VITIS_${comp}_LIBME me NO_DEFAULT_PATH CMAKE_FIND_ROOT_PATH_BOTH PATHS
			${VITIS_AIETOOLS_DIR}/data/${aieVersionSpecificPath}/lib/Release)
	if(NOT VITIS_${comp}_LIBME)
		message(STATUS "Unable to find ${comp} libme.a")
	else(NOT VITIS_${comp}_LIBME)
		message(STATUS "Found ${comp} libme.a: ${VITIS_${comp}_LIBME}")
	endif(NOT VITIS_${comp}_LIBME)

	# Find AIE LIBC
	find_library(VITIS_${comp}_LIBC c NO_DEFAULT_PATH CMAKE_FIND_ROOT_PATH_BOTH PATHS
				${VITIS_AIETOOLS_DIR}/data/${aieVersionSpecificPath}/lib/runtime/lib/Release)
	if(NOT VITIS_${comp}_LIBC)
		message(STATUS "Unable to find ${comp} libc.a")
	else(NOT VITIS_${comp}_LIBC)
		message(STATUS "Found ${comp} libc.a:${VITIS_${comp}_LIBC}")
	endif(NOT VITIS_${comp}_LIBC)

	# Find AIE LIBM
	find_library(VITIS_${comp}_LIBM m NO_DEFAULT_PATH CMAKE_FIND_ROOT_PATH_BOTH PATHS
				${VITIS_AIETOOLS_DIR}/data/${aieVersionSpecificPath}/lib/runtime/lib/Release)
	if(NOT VITIS_${comp}_LIBM)
		message(STATUS "Unable to find ${comp} libm.a")
	else(NOT VITIS_${comp}_LIBM)
		message(STATUS "Found ${comp} libm.a:${VITIS_${comp}_LIBM}")
	endif(NOT VITIS_${comp}_LIBM)

	# Find assert.h in AIE runtime include dir
	find_path(VITIS_${comp}_RUNTIME_INCLUDE_DIR "assert.h" PATHS ${VITIS_AIETOOLS_DIR}/data/${aieVersionSpecificPath}/lib/runtime/include
		NO_DEFAULT_PATH CMAKE_FIND_ROOT_PATH_BOTH)
	
	if(NOT VITIS_${comp}_RUNTIME_INCLUDE_DIR)
		message(STATUS "Unable to find ${comp} runtime include dir")
	else(NOT VITIS_${comp}_RUNTIME_INCLUDE_DIR)
		message(STATUS "Found ${comp} runtime include folder: ${VITIS_${comp}_RUNTIME_INCLUDE_DIR}")
	endif(NOT VITIS_${comp}_RUNTIME_INCLUDE_DIR)

	# Find AIE LIBSOFTFLOAT
	find_library(VITIS_${comp}_LIBSOFTFLOAT softfloat NO_DEFAULT_PATH CMAKE_FIND_ROOT_PATH_BOTH PATHS
				${VITIS_AIETOOLS_DIR}/data/${aieVersionSpecificPath}/lib/softfloat/lib/Release)
	if(NOT VITIS_${comp}_LIBSOFTFLOAT)
		message(STATUS "Unable to find ${comp} libsoftfloat.a")
	else(NOT VITIS_${comp}_LIBSOFTFLOAT)
		message(STATUS "Found ${comp} libsoftfloat.a:${VITIS_${comp}_LIBSOFTFLOAT}")
	endif(NOT VITIS_${comp}_LIBSOFTFLOAT)

	#find_package(Vitis${comp})
	if (VITIS_${comp}_INCLUDE_DIR AND VITIS_${comp}_LIBME AND VITIS_${comp}_LIBC AND VITIS_${comp}_LIBM AND VITIS_${comp}_RUNTIME_INCLUDE_DIR AND VITIS_${comp}_LIBSOFTFLOAT)
		set(Vitis_${comp}_FOUND TRUE)
	endif()

endforeach()

FIND_PACKAGE_HANDLE_STANDARD_ARGS(Vitis HANDLE_COMPONENTS REQUIRED_VARS
		VITIS_ROOT
		VITIS_VPP
		VITIS_AIETOOLS_DIR
		VITIS_XCHESSCC
		VITIS_XCHESS_MAKE
		VITIS_DSPLIB_INCLUDE_DIR
		Vitis_VERSION_MAJOR
		Vitis_VERSION_MINOR
		)
