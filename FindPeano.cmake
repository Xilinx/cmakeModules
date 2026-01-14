###############################################################################
#  Copyright (c) 2025, AMD, Inc.
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
#  PEANO_INSTALL_DIR - Path to Peano (llvm-aie) installation
#
## 2: Variables
# The following are set after configuration is done: 
#  
#  PEANO_DIR - The path to Peano installation directory
#  PEANO_BIN_DIR - The path to Peano binary directory
#  PEANO_INCLUDE_DIR - The path to Peano include directory
#  PEANO_LLC - 'llc' with full path
#  PEANO_CLANG - 'clang' with full path
#
## 3: Components
# The following components are supported:
###  3.1. AIE2
#  PEANO_AIE2_INCLUDE_DIR - AIE2 target include path
#  Peano_AIE2_FOUND - TRUE if AIE2 support is detected
#
### 3.2. AIE2P
#  PEANO_AIE2P_INCLUDE_DIR - AIE2P target include path
#  Peano_AIE2P_FOUND - TRUE if AIE2P support is detected
#----------------------------------------------------------

include(FindPackageHandleStandardArgs)

cmake_policy(SET CMP0144 NEW)

list(LENGTH Peano_FIND_COMPONENTS componentsSize)
if(componentsSize EQUAL 0)
 	message(STATUS "No Peano components specified, checking for AIE2 and AIE2P")
	list(APPEND Peano_FIND_COMPONENTS "AIE2" "AIE2P")
endif()

# Find Peano installation directory
# First check PEANO_INSTALL_DIR cache variable, then environment variable
if(NOT PEANO_INSTALL_DIR OR PEANO_INSTALL_DIR STREQUAL "" OR PEANO_INSTALL_DIR STREQUAL "<unset>")
    set(PEANO_INSTALL_DIR "$ENV{PEANO_INSTALL_DIR}" CACHE STRING "Location of Peano compiler" FORCE)
endif()

if(NOT PEANO_INSTALL_DIR OR PEANO_INSTALL_DIR STREQUAL "" OR PEANO_INSTALL_DIR STREQUAL "<unset>")
    message(STATUS "PEANO_INSTALL_DIR not set, Peano will not be available")
    set(PEANO_DIR "PEANO_DIR-NOTFOUND")
else()
    set(PEANO_DIR ${PEANO_INSTALL_DIR})
    message(STATUS "Checking for Peano at: ${PEANO_DIR}")
endif()

# Find Peano tools
if(PEANO_DIR AND NOT PEANO_DIR STREQUAL "PEANO_DIR-NOTFOUND")
    find_program(PEANO_LLC llc PATHS ${PEANO_DIR}/bin NO_DEFAULT_PATH)
    find_program(PEANO_CLANG clang PATHS ${PEANO_DIR}/bin NO_DEFAULT_PATH)
    
    if(PEANO_LLC)
        message(STATUS "Found Peano llc: ${PEANO_LLC}")
        get_filename_component(PEANO_BIN_DIR ${PEANO_LLC} DIRECTORY)
        
        # Verify this is actually llvm-aie by checking for AIE support
        execute_process(
            COMMAND ${PEANO_LLC} -mtriple=aie --version
            OUTPUT_VARIABLE peanoVersionOutput
            ERROR_QUIET
            RESULT_VARIABLE peanoResult
        )
        
        if(peanoResult EQUAL 0 AND peanoVersionOutput MATCHES "Xilinx AI Engine")
            message(STATUS "Verified Peano llc supports AIE")
        else()
            message(STATUS "llc found but does not support AIE, ignoring")
            set(PEANO_LLC "PEANO_LLC-NOTFOUND")
        endif()
    else()
        message(STATUS "Peano llc not found")
    endif()
    
    if(PEANO_CLANG)
        message(STATUS "Found Peano clang: ${PEANO_CLANG}")
    else()
        message(STATUS "Peano clang not found")
    endif()
    
    # Find include directory
    find_path(PEANO_INCLUDE_DIR "aie2-none-unknown-elf"
        PATHS ${PEANO_DIR}/include
        NO_DEFAULT_PATH)
    
    if(PEANO_INCLUDE_DIR)
        message(STATUS "Found Peano include directory: ${PEANO_INCLUDE_DIR}")
    else()
        message(STATUS "Peano include directory not found")
    endif()
endif()

# Find Components - check for architecture-specific support
foreach(comp ${Peano_FIND_COMPONENTS})
	message(STATUS "Looking for Peano component: ${comp}")

	if(${comp} STREQUAL "AIE2")
		set(peanoArchIncludePath "aie2-none-unknown-elf")
	elseif(${comp} STREQUAL "AIE2P")
		set(peanoArchIncludePath "aie2p-none-unknown-elf")
	else()
		message(STATUS "${comp} not supported by Peano")
		set(peanoArchIncludePath "unknown")
	endif()

	# Check if architecture-specific include directory exists
	if(PEANO_INCLUDE_DIR AND NOT peanoArchIncludePath STREQUAL "unknown")
		find_path(PEANO_${comp}_INCLUDE_DIR ${peanoArchIncludePath}
			PATHS ${PEANO_DIR}/include
			NO_DEFAULT_PATH CMAKE_FIND_ROOT_PATH_BOTH)
		
		if(PEANO_${comp}_INCLUDE_DIR)
			message(STATUS "Found Peano ${comp} support: ${PEANO_${comp}_INCLUDE_DIR}/${peanoArchIncludePath}")
			set(Peano_${comp}_FOUND TRUE)
		else()
			message(STATUS "Peano ${comp} support not found")
			set(Peano_${comp}_FOUND FALSE)
		endif()
	else()
		set(Peano_${comp}_FOUND FALSE)
	endif()
endforeach()

# Set overall Peano_FOUND if basic tools are available
if(PEANO_DIR AND PEANO_LLC AND PEANO_CLANG AND PEANO_INCLUDE_DIR)
    set(Peano_FOUND TRUE)
    message(STATUS "Peano found and validated")
else()
    set(Peano_FOUND FALSE)
    message(STATUS "Peano not found or incomplete")
endif()

FIND_PACKAGE_HANDLE_STANDARD_ARGS(Peano 
    HANDLE_COMPONENTS 
    REQUIRED_VARS
		PEANO_DIR
		PEANO_BIN_DIR
		PEANO_LLC
		PEANO_CLANG
		PEANO_INCLUDE_DIR
)
