# SPDX-License-Identifier: BSD-3-Clause
###############################################################################
#  Copyright (C) 2023-2026 Advanced Micro Devices, Inc.
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

# Resolve an explicit SDK root before normal package discovery.
if(NOT XRT_ROOT)
  if(DEFINED ENV{XRT_ROOT} AND NOT "$ENV{XRT_ROOT}" STREQUAL "")
    set(XRT_ROOT "$ENV{XRT_ROOT}")
  elseif(XILINX_XRT)
    set(XRT_ROOT "${XILINX_XRT}")
  elseif(DEFINED ENV{XILINX_XRT} AND NOT "$ENV{XILINX_XRT}" STREQUAL "")
    set(XRT_ROOT "$ENV{XILINX_XRT}")
  endif()
endif()

if(XRT_ROOT)
  get_filename_component(XRT_ROOT "${XRT_ROOT}" ABSOLUTE)
endif()

# Windows uses the driver's DLL and the SDK's import library.
if(NOT WIN32)
  if(XRT_ROOT)
    find_package(XRT CONFIG QUIET PATHS "${XRT_ROOT}" NO_DEFAULT_PATH)
  else()
    find_package(XRT CONFIG QUIET)
  endif()
endif()

# Prefer the package target when the installed config provides one.
if(TARGET XRT::xrt_coreutil)
  get_target_property(_xrt_include_dirs XRT::xrt_coreutil
    INTERFACE_INCLUDE_DIRECTORIES)
  foreach(_xrt_include_dir IN LISTS _xrt_include_dirs)
    if(EXISTS "${_xrt_include_dir}/xrt/xrt_device.h")
      set(XRT_INCLUDE_DIR "${_xrt_include_dir}")
      break()
    endif()
  endforeach()
  if(NOT XRT_INCLUDE_DIR AND XRT_INCLUDE_DIRS)
    list(GET XRT_INCLUDE_DIRS 0 XRT_INCLUDE_DIR)
  endif()

  # Preserve XRT_COREUTIL while adding the imported-target contract.
  set(_xrt_artifact_property IMPORTED_LOCATION)
  if(WIN32)
    set(_xrt_artifact_property IMPORTED_IMPLIB)
  endif()
  get_target_property(XRT_COREUTIL XRT::xrt_coreutil
    "${_xrt_artifact_property}")
  if(NOT XRT_COREUTIL OR XRT_COREUTIL MATCHES "-NOTFOUND$")
    get_target_property(_xrt_configurations XRT::xrt_coreutil
      IMPORTED_CONFIGURATIONS)
    foreach(_xrt_configuration IN LISTS _xrt_configurations)
      string(TOUPPER "${_xrt_configuration}" _xrt_configuration)
      get_target_property(XRT_COREUTIL XRT::xrt_coreutil
        "${_xrt_artifact_property}_${_xrt_configuration}")
      if(XRT_COREUTIL AND NOT XRT_COREUTIL MATCHES "-NOTFOUND$")
        break()
      endif()
    endforeach()
  endif()
else()
  # Fall back to the installed header and library layout.
  if(XRT_ROOT)
    find_path(XRT_INCLUDE_DIR xrt/xrt_device.h
      PATHS "${XRT_ROOT}/include" NO_DEFAULT_PATH)
    find_library(XRT_COREUTIL xrt_coreutil
      PATHS "${XRT_ROOT}/lib" "${XRT_ROOT}/lib64"
            "${XRT_ROOT}/lib/${CMAKE_LIBRARY_ARCHITECTURE}"
      NO_DEFAULT_PATH)
  else()
    find_path(XRT_INCLUDE_DIR xrt/xrt_device.h PATH_SUFFIXES include)
    find_library(XRT_COREUTIL xrt_coreutil
      PATH_SUFFIXES lib lib64 "lib/${CMAKE_LIBRARY_ARCHITECTURE}")
  endif()

  if(XRT_INCLUDE_DIR AND XRT_COREUTIL)
    add_library(XRT::xrt_coreutil SHARED IMPORTED)
    if(WIN32)
      set_target_properties(XRT::xrt_coreutil PROPERTIES
        IMPORTED_IMPLIB "${XRT_COREUTIL}"
        INTERFACE_INCLUDE_DIRECTORIES "${XRT_INCLUDE_DIR}")
    else()
      set_target_properties(XRT::xrt_coreutil PROPERTIES
        IMPORTED_LOCATION "${XRT_COREUTIL}"
        INTERFACE_INCLUDE_DIRECTORIES "${XRT_INCLUDE_DIR}")
    endif()
  endif()
endif()

if(TARGET XRT::xrt_coreutil)
  # Correct MSVC's __cplusplus so XRT uses std::any instead of Boost.
  set(_xrt_cplusplus "$<$<COMPILE_LANG_AND_ID:CXX,MSVC>:/Zc:__cplusplus>")
  get_target_property(_xrt_options XRT::xrt_coreutil INTERFACE_COMPILE_OPTIONS)
  if(NOT _xrt_options OR _xrt_options MATCHES "-NOTFOUND$")
    set(_xrt_options)
  endif()
  list(FIND _xrt_options "${_xrt_cplusplus}" _xrt_cplusplus_index)
  if(_xrt_cplusplus_index EQUAL -1)
    set_property(TARGET XRT::xrt_coreutil APPEND PROPERTY
      INTERFACE_COMPILE_OPTIONS "${_xrt_cplusplus}")
  endif()

  if(NOT XRT_ROOT AND XRT_INCLUDE_DIR)
    get_filename_component(XRT_ROOT "${XRT_INCLUDE_DIR}" DIRECTORY)
  endif()
  set(XRT_INCLUDE_DIRS "${XRT_INCLUDE_DIR}")
  if(XRT_LINK_DIRS)
    list(GET XRT_LINK_DIRS 0 XRT_LIB_DIR)
  elseif(XRT_COREUTIL AND IS_ABSOLUTE "${XRT_COREUTIL}")
    get_filename_component(XRT_LIB_DIR "${XRT_COREUTIL}" DIRECTORY)
  else()
    set(XRT_LIB_DIR "${XRT_ROOT}/lib")
  endif()
  set(XRT_LINK_DIRS "${XRT_LIB_DIR}")
  set(XRT_COREUTIL_LIBRARIES XRT::xrt_coreutil)
  if(NOT XRT_DIR)
    set(XRT_DIR "${XRT_ROOT}")
  endif()
  if(WIN32)
    set(XRT_BIN_DIR "${XRT_ROOT}")
    set(XRT_RUNTIME_DIRS "${XRT_ROOT}")
  else()
    set(XRT_BIN_DIR "${XRT_ROOT}/bin")
    set(XRT_RUNTIME_DIRS "${XRT_LIB_DIR}")
  endif()
  if(IS_DIRECTORY "${XRT_ROOT}/python")
    set(XRT_PYTHON_DIR "${XRT_ROOT}/python")
  endif()
endif()

find_package_handle_standard_args(XRT
  REQUIRED_VARS XRT_INCLUDE_DIR XRT_COREUTIL
  VERSION_VAR XRT_VERSION)

mark_as_advanced(XRT_INCLUDE_DIR XRT_LIB_DIR XRT_BIN_DIR XRT_PYTHON_DIR
  XRT_COREUTIL)
