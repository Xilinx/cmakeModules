###############################################################################
#  Copyright (c) 2024, AMD, Inc.
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
#  AIETOOLS_DIR - The path to AIETools installation directory for the specified version
#  AIETOOLS_BINARY_DIR - The path to AIETools binary installation directory
#  AIETOOLS_INCLUDE_DIR - The path to AIETools include installation directory
#  AIETOOLS_XCHESSCC - 'xchesscc' with full path
#  AIETOOLS_XCHESS_MAKE - 'xchessmk' with full path
#
## 3: Components
# The following components are supported:
###  3.1. AIE
#  AIETOOLS_AIE_INCLUDE_DIR - AIE full include path
#  AIETOOLS_AIE_LIBME - 'libme.a' with full path
#  AIETOOLS_AIE_LIBC - 'libc.a' with full path
#  AIETOOLS_AIE_LIBM - 'libm.a' with full path
#  AIETOOLS_AIE_RUNTIME_INCLUDE_DIR - AIE runtime full include path
#  AIETOOLS_AIE_LIBSOFTFLOAT - 'softfloat.a' with full path
#
### 3.2. AIE2
#  AIETOOLS_AIE2_INCLUDE_DIR - AIE2 full include path
#  AIETOOLS_AIE2_LIBME - 'libme.a' with full path
#  AIETOOLS_AIE2_LIBC - 'libc.a' with full path
#  AIETOOLS_AIE2_LIBM - 'libm.a' with full path
#  AIETOOLS_AIE2_RUNTIME_INCLUDE_DIR - AIE2 runtime full include path
#  AIETOOLS_AIE2_LIBSOFTFLOAT - 'softfloat.a' with full path
#----------------------------------------------------------

include(FindPackageHandleStandardArgs)

cmake_policy(SET CMP0144 NEW)

list(LENGTH AIETools_FIND_COMPONENTS componentsSize)
if(componentsSize EQUAL 0)
 	message(STATUS "Error: AIE version needed as COMPONENT, setting AIE as default")
	list(APPEND AIETools_FIND_COMPONENTS "AIE")
endif()

#if Xilinx tools correctly installed they are added to $ENV{PATH} one of CMake's default search paths

# Find aiecompiler to derive version
find_program(AIETOOLS_AIECOMPILER aiecompiler)
if(NOT AIETOOLS_AIECOMPILER)
	message(STATUS "Unable to find aiecompiler")
else(NOT AIETOOLS_AIECOMPILER)
	message(STATUS "Found aiecompiler: ${AIETOOLS_AIECOMPILER}")
	get_filename_component(_bindir ${AIETOOLS_AIECOMPILER} DIRECTORY)
	get_filename_component(AIETOOLS_DIR ${_bindir} DIRECTORY)
	execute_process(COMMAND ${AIETOOLS_AIECOMPILER} --version
		OUTPUT_VARIABLE aiecompilerVersionOutput
	)

	message(STATUS "aiecompiler version number: ${aiecompilerVersionOutput}")
	string(REGEX MATCH "Version [0-9]+\.[0-9]" aiecompilerVersionNumber ${aiecompilerVersionOutput})
	message(STATUS "aiecompiler version number: ${aiecompilerVersionNumber}")
	string(REGEX MATCH "[0-9]+" aiecompilerVersionMajor ${aiecompilerVersionNumber})
	string(REGEX MATCH "[0-9]$" aiecompilerVersionMinor ${aiecompilerVersionNumber})
	message(STATUS "aiecompiler major version number: ${aiecompilerVersionMajor}")
	message(STATUS "aiecompiler minor version number: ${aiecompilerVersionMinor}")

	message(STATUS "aiecompiler version number: ${aiecompilerVersionNumber}")
	if(NOT aiecompilerVersionNumber)
		message(FATAL_ERROR "aiecompiler version not found")
		return()
	endif()

	if(NOT DEFINED AIETools_FIND_VERSION)
		set(AIETools_VERSION_MAJOR ${aiecompilerVersionMajor})
		set(AIETools_VERSION_MINOR ${aiecompilerVersionMinor})
	else()
		if (${aiecompilerVersionMajor} LESS ${AIETools_FIND_VERSION_MAJOR})
			message(STATUS "Error: AIETools major version is too old")
		elseif((${aiecompilerVersionMajor} EQUAL ${AIETools_FIND_VERSION_MAJOR}) AND (${aiecompilerVersionMinor} LESS ${AIETools_FIND_VERSION_MINOR}))
			message(STATUS "Error: AIETools minor version is too old")
		else()
			set(AIETools_VERSION_MAJOR ${aiecompilerVersionMajor})
			set(AIETools_VERSION_MINOR ${aiecompilerVersionMinor})
		endif()
	endif()
endif(NOT AIETOOLS_AIECOMPILER)

# Find AIE tools
find_program(AIETOOLS_XCHESSCC xchesscc)
if(NOT AIETOOLS_XCHESSCC)
	message(STATUS "Unable to find xchesscc")
else(NOT VITIS_XCHESSCC)
	message(STATUS "Found xchesscc: ${AIETOOLS_XCHESSCC}")
	get_filename_component(AIETOOLS_BINARY_DIR ${AIETOOLS_XCHESSCC} DIRECTORY)
	get_filename_component(_aietools_dir ${AIETOOLS_BINARY_DIR} DIRECTORY)
endif(NOT AIETOOLS_XCHESSCC)

# Find the include directory by searching for adf.h. Search in:
#  1) dirname(`which xchesscc`)/../include which is the Vitis install path
#  2) $ENV{SITE_PACKAGES}/include which is the RyzenAI Software install path
find_path(AIETOOLS_INCLUDE_DIR "adf.h"
		PATHS ${_aietools_dir}/include $ENV{SITE_PACKAGES}/include)
if(NOT AIETOOLS_INCLUDE_DIR)
	message(STATUS "Unable to find aietools directory")
else()
	get_filename_component(AIETOOLS_DIR ${AIETOOLS_INCLUDE_DIR} DIRECTORY)
endif()

message(STATUS "aietools directory: ${AIETOOLS_DIR}")
message(STATUS "aietools binary directory: ${AIETOOLS_BINARY_DIR}")
message(STATUS "aietools include directory: ${AIETOOLS_INCLUDE_DIR}")

find_program(AIETOOLS_XCHESS_MAKE xchessmk PATHS ${AIETOOLS_BINARY_DIR})
if(NOT AIETOOLS_XCHESS_MAKE)
	message(STATUS "Unable to find xchessmk")
else(NOT AIETOOLS_XCHESS_MAKE)
	message(STATUS "Found xchessmk: ${AIETOOLS_XCHESS_MAKE}")
endif(NOT AIETOOLS_XCHESS_MAKE)

# Find Components
foreach(comp ${AIETools_FIND_COMPONENTS})
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

	if(${comp} STREQUAL "AIE")
		set(aieVersionTargetPath "target")
	elseif(${comp} STREQUAL "AIE2")
		set(aieVersionTargetPath "target_aie_ml")
	else()
		string(TOLOWER ${comp} aiearch)
		set(aieVersionTargetPath "target_${aiearch}")
	endif()

	# Find chesscc
	find_path(AIETOOLS_${comp}_TARGET_DIR "chesscc" PATHS ${AIETOOLS_DIR}/tps/lnx64/${aieVersionTargetPath}/bin/LNa64bin
			NO_DEFAULT_PATH CMAKE_FIND_ROOT_PATH_BOTH)
	if(NOT AIETOOLS_${comp}_TARGET_DIR)
		message(STATUS "Unable to find ${comp} target dir")
	else(NOT AIETOOLS_${comp}_TARGET_DIR)
		message(STATUS "Found ${comp} target dir: ${AIETOOLS_${comp}_TARGET_DIR}")
	endif(NOT AIETOOLS_${comp}_TARGET_DIR)

	# Find aie_core.h
	find_path(AIETOOLS_${comp}_INCLUDE_DIR "aie_core.h" PATHS ${AIETOOLS_DIR}/data/${aieVersionSpecificPath}/lib
			NO_DEFAULT_PATH CMAKE_FIND_ROOT_PATH_BOTH)
	if(NOT AIETOOLS_${comp}_INCLUDE_DIR)
		message(STATUS "Unable to find ${comp} include dir")
	else(NOT AIETOOLS_${comp}_INCLUDE_DIR)
		message(STATUS "Found ${comp} include folder: ${AIETOOLS_${comp}_INCLUDE_DIR}")
	endif(NOT AIETOOLS_${comp}_INCLUDE_DIR)

	# Find libme.a
	find_library(AIETOOLS_${comp}_LIBME me NO_DEFAULT_PATH CMAKE_FIND_ROOT_PATH_BOTH PATHS
			${AIETOOLS_DIR}/data/${aieVersionSpecificPath}/lib/Release)
	if(NOT AIETOOLS_${comp}_LIBME)
		message(STATUS "Unable to find ${comp} libme.a")
	else(NOT AIETOOLS_${comp}_LIBME)
		message(STATUS "Found ${comp} libme.a: ${AIETOOLS_${comp}_LIBME}")
	endif(NOT AIETOOLS_${comp}_LIBME)

	# Find AIE LIBC
	find_library(AIETOOLS_${comp}_LIBC c NO_DEFAULT_PATH CMAKE_FIND_ROOT_PATH_BOTH PATHS
				${AIETOOLS_DIR}/data/${aieVersionSpecificPath}/lib/runtime/lib/Release)
	if(NOT AIETOOLS_${comp}_LIBC)
		message(STATUS "Unable to find ${comp} libc.a")
	else(NOT AIETOOLS_${comp}_LIBC)
		message(STATUS "Found ${comp} libc.a:${AIETOOLS_${comp}_LIBC}")
	endif(NOT AIETOOLS_${comp}_LIBC)

	# Find AIE LIBM
	find_library(AIETOOLS_${comp}_LIBM m NO_DEFAULT_PATH CMAKE_FIND_ROOT_PATH_BOTH PATHS
				${AIETOOLS_DIR}/data/${aieVersionSpecificPath}/lib/runtime/lib/Release)
	if(NOT AIETOOLS_${comp}_LIBM)
		message(STATUS "Unable to find ${comp} libm.a")
	else(NOT AIETOOLS_${comp}_LIBM)
		message(STATUS "Found ${comp} libm.a:${AIETOOLS_${comp}_LIBM}")
	endif(NOT AIETOOLS_${comp}_LIBM)

	# Find assert.h in AIE runtime include dir
	find_path(AIETOOLS_${comp}_RUNTIME_INCLUDE_DIR "assert.h" PATHS ${AIETOOLS_DIR}/data/${aieVersionSpecificPath}/lib/runtime/include
		NO_DEFAULT_PATH CMAKE_FIND_ROOT_PATH_BOTH)
	
	if(NOT AIETOOLS_${comp}_RUNTIME_INCLUDE_DIR)
		message(STATUS "Unable to find ${comp} runtime include dir")
	else(NOT AIETOOLS_${comp}_RUNTIME_INCLUDE_DIR)
		message(STATUS "Found ${comp} runtime include folder: ${AIETOOLS_${comp}_RUNTIME_INCLUDE_DIR}")
	endif(NOT AIETOOLS_${comp}_RUNTIME_INCLUDE_DIR)

	# Find AIE LIBSOFTFLOAT
	find_library(AIETOOLS_${comp}_LIBSOFTFLOAT softfloat NO_DEFAULT_PATH CMAKE_FIND_ROOT_PATH_BOTH PATHS
				${AIETOOLS_DIR}/data/${aieVersionSpecificPath}/lib/softfloat/lib/Release)
	if(NOT AIETOOLS_${comp}_LIBSOFTFLOAT)
		message(STATUS "Unable to find ${comp} libsoftfloat.a")
	else(NOT AIETOOLS_${comp}_LIBSOFTFLOAT)
		message(STATUS "Found ${comp} libsoftfloat.a:${AIETOOLS_${comp}_LIBSOFTFLOAT}")
	endif(NOT AIETOOLS_${comp}_LIBSOFTFLOAT)

	#find_package(AIETools${comp})
	if (AIETOOLS_${comp}_INCLUDE_DIR AND AIETOOLS_${comp}_LIBME AND AIETOOLS_${comp}_LIBC AND AIETOOLS_${comp}_LIBM AND AIETOOLS_${comp}_RUNTIME_INCLUDE_DIR AND AIETOOLS_${comp}_LIBSOFTFLOAT AND AIETOOLS_${comp}_TARGET_DIR)
		set(AIETools_${comp}_FOUND TRUE)
	endif()

endforeach()

FIND_PACKAGE_HANDLE_STANDARD_ARGS(AIETools HANDLE_COMPONENTS REQUIRED_VARS
		AIETOOLS_DIR
		AIETOOLS_BINARY_DIR
		AIETOOLS_INCLUDE_DIR
		AIETOOLS_XCHESSCC
		AIETOOLS_XCHESS_MAKE
		AIETools_VERSION_MAJOR
		AIETools_VERSION_MINOR
		)
