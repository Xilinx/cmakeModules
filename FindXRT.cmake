  ###############################################################################
#  Copyright (c) 2023, Advanced Micro Devices, Inc.
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

include(FindPackageHandleStandardArgs)

find_program(XRT_XBUTIL xbutil)
if (XRT_XBUTIL)
  get_filename_component(XRT_XBUTIL ${XRT_XBUTIL} REALPATH)
  get_filename_component(XRT_BIN_DIR ${XRT_XBUTIL} DIRECTORY)
  get_filename_component(XRT_DIR ${XRT_BIN_DIR} DIRECTORY)
  message(STATUS "Found XRT: ${XRT_DIR}")

  execute_process(COMMAND xbutil examine
    OUTPUT_VARIABLE xbutilOutput
  )
  string(REPLACE "\n" ";" xbutilOutput ${xbutilOutput})

  #  Devices present
  #  BDF             :  Shell    Logic UUID                            Device ID     Device Ready*
  # -----------------------------------------------------------------------------------------------
  # [0000:c5:00.1]  :  Phoenix  00000000-0000-0000-0000-000000000000  user(inst=0)  Yes
  foreach(line ${xbutilOutput})
    if (line MATCHES "^\\[.*Phoenix.* Yes")
      string(REGEX REPLACE "^\\[(.*)\\].*" "\\1" XRT_DEVICE ${line})
      message(STATUS "Found ready XRT device: ${XRT_DEVICE}")
    endif()
  endforeach()

endif()

find_library(XRT_COREUTIL xrt_coreutil PATHS ${XRT_DIR}/lib)
if (XRT_COREUTIL)
  message(STATUS "Found libxrt_coreutil")
  get_filename_component(XRT_COREUTIL ${XRT_COREUTIL} REALPATH)
  get_filename_component(XRT_LIB_DIR ${XRT_COREUTIL} DIRECTORY)
endif()

find_package_handle_standard_args(XRT
  FOUND_VAR XRT_FOUND
  REQUIRED_VARS XRT_LIB_DIR XRT_BIN_DIR
  )
