# SPDX-License-Identifier: BSD-3-Clause
  ###############################################################################
#  Copyright (c) 2021, Xilinx, Inc.
#  Copyright (C) 2026 Advanced Micro Devices, Inc.
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
# The following variable is optionally searched for an installed prefix:
#  LibXAIE_ROOT - Path to a LibXAIE installation
#
## 2: Variables
# The following are set after configuration is done: 
#  
#  XILINX_XAIE_INCLUDE_DIR - LibXAIE (xaiengine) full include path
#  XILINX_XAIE_LIBS - LibXAIE (xaiengine) full library path
#
###########################################################

# Honor an explicit installation prefix.
if(NOT LibXAIE_ROOT AND DEFINED ENV{LibXAIE_ROOT})
  set(LibXAIE_ROOT "$ENV{LibXAIE_ROOT}")
endif()

if(LibXAIE_ROOT)
  # Keep headers and libraries inside the selected prefix.
  get_filename_component(LibXAIE_ROOT "${LibXAIE_ROOT}" ABSOLUTE)
  find_library(XILINX_XAIE_LIBS NAMES xaiengine xaienginecdo
    PATHS "${LibXAIE_ROOT}/lib" "${LibXAIE_ROOT}/lib64"
          "${LibXAIE_ROOT}/lib/${CMAKE_LIBRARY_ARCHITECTURE}"
    NO_DEFAULT_PATH)
  find_path(XILINX_XAIE_INCLUDE_DIR xaiengine.h
    PATHS "${LibXAIE_ROOT}/include" NO_DEFAULT_PATH)
else()
  # Retain the existing system-prefix search.
  find_library(XILINX_XAIE_LIBS NAMES xaiengine xaienginecdo
    PATHS /lib /usr/lib /usr/lib64 /opt/xaiengine/lib /opt/xaienginev2/lib
    PATH_SUFFIXES "${CMAKE_LIBRARY_ARCHITECTURE}")
  find_path(XILINX_XAIE_INCLUDE_DIR xaiengine.h
    PATHS /usr/include /opt/xaiengine/include /opt/xaienginev2/include)
endif()

if(XILINX_XAIE_LIBS)
  get_filename_component(XILINX_XAIE_LIBS "${XILINX_XAIE_LIBS}" REALPATH)
  get_filename_component(XILINX_XAIE_LIB_DIR "${XILINX_XAIE_LIBS}" DIRECTORY)
  if(LibXAIE_ROOT)
    set(XILINX_XAIE_DIR "${LibXAIE_ROOT}")
  elseif(XILINX_XAIE_INCLUDE_DIR)
    # Headers identify the prefix when the library is below a multiarch path.
    get_filename_component(XILINX_XAIE_DIR
      "${XILINX_XAIE_INCLUDE_DIR}" DIRECTORY)
  endif()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(LibXAIE
  FOUND_VAR LibXAIE_FOUND
  REQUIRED_VARS XILINX_XAIE_INCLUDE_DIR XILINX_XAIE_LIBS)
