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
#  VITIS_HLS_APCC - 'apcc' with full path
#  VITIS_HLS_VITIS_HLS - 'vitis_hls' with full path
#  VITIS_HLS_ROOT - The path to the Vitis/$VERSION directory
#  VITIS_HLS_INCLUDE_DIR - The include direcotry for Vits_HLS
#
#----------------------------------------------------------

include(FindPackageHandleStandardArgs)

#if Xilinx tools correctly installed they are added to $ENV{PATH} one of CMake's default search paths

# Find apcc
find_program(VITIS_HLS_APCC apcc)
if(NOT VITIS_HLS_APCC)
	message(STATUS "Unable to find apcc")
else(NOT VITIS_HLS_APCC)
	message(STATUS "Found apcc: ${VITIS_HLS_APCC}")
	get_filename_component(VITIS_HLS_PARENT ${VITIS_HLS_APCC} PATH)
	get_filename_component(VITIS_HLS_ROOT ${VITIS_HLS_PARENT} PATH)
	message(STATUS "VITIS HLS ROOT: " ${VITIS_HLS_ROOT})
endif(NOT VITIS_HLS_APCC)

# Find vitis_hls
find_program(VITIS_HLS_VITIS_HLS vitis_hls)
if(NOT VITIS_HLS_VITIS_HLS)
	message(STATUS "Unable to find vitis_hls")
else(NOT VITIS_HLS_VITIS_HLS)
endif(NOT VITIS_HLS_VITIS_HLS)


# Find Vitis_HLS include directory
find_path(VITIS_HLS_INCLUDE_DIR "hls_stream.h" PATHS ${VITIS_HLS_ROOT}/include)

if(NOT VITIS_HLS_INCLUDE_DIR)
	message(STATUS "Unable to find Vitis include folder")
else(NOT VITIS_HLS_INCLUDE_DIR)
	message(STATUS "Found Vitis include folder: ${VITIS_HLS_INCLUDE_DIR}")
endif(NOT VITIS_HLS_INCLUDE_DIR)

FIND_PACKAGE_HANDLE_STANDARD_ARGS(VitisHLS HANDLE_COMPONENTS REQUIRED_VARS
		VITIS_HLS_ROOT
		VITIS_HLS_APCC
		VITIS_HLS_VITIS_HLS
		VITIS_HLS_INCLUDE_DIR)
