# SPDX-License-Identifier: BSD-3-Clause
###############################################################################
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

include(FindPackageHandleStandardArgs)

# Resolve AIEBU independently except in the Windows XRT bundle.
if(NOT AIEBU_ROOT)
  if(DEFINED ENV{AIEBU_ROOT} AND NOT "$ENV{AIEBU_ROOT}" STREQUAL "")
    set(AIEBU_ROOT "$ENV{AIEBU_ROOT}")
  elseif(WIN32 AND XRT_ROOT)
    set(AIEBU_ROOT "${XRT_ROOT}")
  elseif(WIN32 AND XILINX_XRT)
    set(AIEBU_ROOT "${XILINX_XRT}")
  elseif(WIN32 AND DEFINED ENV{XILINX_XRT} AND
         NOT "$ENV{XILINX_XRT}" STREQUAL "")
    set(AIEBU_ROOT "$ENV{XILINX_XRT}")
  endif()
endif()

# Load the config package from the selected prefix.
if(AIEBU_ROOT)
  get_filename_component(AIEBU_ROOT "${AIEBU_ROOT}" ABSOLUTE)
  find_package(AIEBU CONFIG QUIET
    PATHS "${AIEBU_ROOT}"
    PATH_SUFFIXES share/cmake/AIEBU lib/cmake/AIEBU
    NO_DEFAULT_PATH)
else()
  find_package(AIEBU CONFIG QUIET)
endif()

if(TARGET AIEBU::aiebu_static)
  if(AIEBU_INCLUDE_DIRS)
    list(GET AIEBU_INCLUDE_DIRS 0 AIEBU_INCLUDE_DIR)
  elseif(AIEBU_ROOT)
    find_path(AIEBU_INCLUDE_DIR aiebu/aiebu.h
      PATHS "${AIEBU_ROOT}/include" NO_DEFAULT_PATH)
  endif()

  if(AIEBU_INCLUDE_DIR)
    get_target_property(_aiebu_includes AIEBU::aiebu_static
      INTERFACE_INCLUDE_DIRECTORIES)
    if(NOT _aiebu_includes OR _aiebu_includes MATCHES "-NOTFOUND$")
      set(_aiebu_includes)
    endif()
    list(FIND _aiebu_includes "${AIEBU_INCLUDE_DIR}" _aiebu_include_index)
    if(_aiebu_include_index EQUAL -1)
      # Repair the released Windows target's missing public include path.
      set_property(TARGET AIEBU::aiebu_static APPEND PROPERTY
        INTERFACE_INCLUDE_DIRECTORIES "${AIEBU_INCLUDE_DIR}")
    endif()
  endif()

  # Resolve the archive selected by the imported target.
  get_target_property(AIEBU_LIBRARY AIEBU::aiebu_static IMPORTED_LOCATION)
  if(NOT AIEBU_LIBRARY OR AIEBU_LIBRARY MATCHES "-NOTFOUND$")
    get_target_property(_aiebu_configurations AIEBU::aiebu_static
      IMPORTED_CONFIGURATIONS)
    foreach(_aiebu_configuration IN LISTS _aiebu_configurations)
      string(TOUPPER "${_aiebu_configuration}" _aiebu_configuration)
      get_target_property(AIEBU_LIBRARY AIEBU::aiebu_static
        "IMPORTED_LOCATION_${_aiebu_configuration}")
      if(AIEBU_LIBRARY AND NOT AIEBU_LIBRARY MATCHES "-NOTFOUND$")
        break()
      endif()
    endforeach()
  endif()

  if(MSVC)
    # Prefer package metadata; inspect older archives only as a fallback.
    if(NOT AIEBU_MSVC_RUNTIME_LIBRARY AND EXISTS "${AIEBU_LIBRARY}")
      file(STRINGS "${AIEBU_LIBRARY}" _aiebu_runtime
        REGEX "RuntimeLibrary=(MT_Static|MD_Dynamic)(Debug|Release)"
        LIMIT_COUNT 1)
      if(_aiebu_runtime MATCHES "MT_StaticDebug")
        set(AIEBU_MSVC_RUNTIME_LIBRARY MultiThreadedDebug)
      elseif(_aiebu_runtime MATCHES "MT_StaticRelease")
        set(AIEBU_MSVC_RUNTIME_LIBRARY MultiThreaded)
      elseif(_aiebu_runtime MATCHES "MD_DynamicDebug")
        set(AIEBU_MSVC_RUNTIME_LIBRARY MultiThreadedDebugDLL)
      elseif(_aiebu_runtime MATCHES "MD_DynamicRelease")
        set(AIEBU_MSVC_RUNTIME_LIBRARY MultiThreadedDLL)
      endif()
    endif()

    if(AIEBU_MSVC_RUNTIME_LIBRARY STREQUAL "MultiThreaded")
      set(_aiebu_runtime_option /MT)
    elseif(AIEBU_MSVC_RUNTIME_LIBRARY STREQUAL "MultiThreadedDebug")
      set(_aiebu_runtime_option /MTd)
    elseif(AIEBU_MSVC_RUNTIME_LIBRARY STREQUAL "MultiThreadedDLL")
      set(_aiebu_runtime_option /MD)
    elseif(AIEBU_MSVC_RUNTIME_LIBRARY STREQUAL "MultiThreadedDebugDLL")
      set(_aiebu_runtime_option /MDd)
    elseif(AIEBU_MSVC_RUNTIME_LIBRARY STREQUAL
           "MultiThreaded$<$<CONFIG:Debug>:Debug>")
      set(_aiebu_runtime_option "/MT$<$<CONFIG:Debug>:d>")
    elseif(AIEBU_MSVC_RUNTIME_LIBRARY STREQUAL
           "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")
      set(_aiebu_runtime_option "/MD$<$<CONFIG:Debug>:d>")
    endif()
    if(_aiebu_runtime_option)
      set_property(TARGET AIEBU::aiebu_static APPEND PROPERTY
        INTERFACE_COMPILE_OPTIONS "${_aiebu_runtime_option}")
    endif()
  endif()

  # Preserve the variables published by the package config.
  if(AIEBU_LIBRARY)
    get_filename_component(AIEBU_LIB_DIR "${AIEBU_LIBRARY}" DIRECTORY)
  endif()
  set(AIEBU_INCLUDE_DIRS "${AIEBU_INCLUDE_DIR}")
  set(AIEBU_LINK_DIRS "${AIEBU_LIB_DIR}")
  set(AIEBU_CORE_LIBRARIES AIEBU::aiebu_static)
endif()

set(_aiebu_required_vars AIEBU_INCLUDE_DIR AIEBU_LIBRARY)
if(MSVC)
  list(APPEND _aiebu_required_vars AIEBU_MSVC_RUNTIME_LIBRARY)
endif()
find_package_handle_standard_args(AIEBU
  REQUIRED_VARS ${_aiebu_required_vars}
  VERSION_VAR AIEBU_VERSION)

mark_as_advanced(AIEBU_INCLUDE_DIR AIEBU_LIB_DIR AIEBU_LIBRARY)
