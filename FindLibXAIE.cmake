  ###############################################################################
#  Copyright (c) 2021, Xilinx, Inc.
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
#  XILINX_XAIE_INCLUDE_DIR - LibXAIE (xaiengine) full include path
#  XILINX_XAIE_LIBS - LibXAIE (xaiengine) full library path
#
###########################################################

#set(CMAKE_FIND_DEBUG_MODE 1)

find_library(XILINX_XAIE_LIBS xaiengine
  PATHS /lib /usr/lib /opt/xaiengine/lib /opt/xaienginev2/lib 
)

if(XILINX_XAIE_LIBS)
  get_filename_component(XILINX_XAIE_LIBS ${XILINX_XAIE_LIBS} REALPATH)
  get_filename_component(XILINX_XAIE_LIB_DIR ${XILINX_XAIE_LIBS} DIRECTORY)
  get_filename_component(XILINX_XAIE_DIR ${XILINX_XAIE_LIB_DIR} DIRECTORY)

  find_path(XILINX_XAIE_INCLUDE_DIR xaiengine.h
    PATHS ${XILINX_XAIE_DIR}/include
  )
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(LibXAIE
  FOUND_VAR LibXAIE_FOUND
  REQUIRED_VARS XILINX_XAIE_INCLUDE_DIR XILINX_XAIE_LIBS
  )
