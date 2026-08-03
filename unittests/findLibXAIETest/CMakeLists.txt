# Copyright (C) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: BSD-3-Clause
#

cmake_minimum_required(VERSION 3.17)
project(test_Find_LibXAIE)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../..")
find_package(LibXAIE REQUIRED)

if(NOT EXISTS "${XILINX_XAIE_INCLUDE_DIR}/xaiengine.h")
  message(FATAL_ERROR "FindLibXAIE returned an invalid include directory")
endif()
if(NOT EXISTS "${XILINX_XAIE_LIBS}")
  message(FATAL_ERROR "FindLibXAIE returned an invalid library")
endif()
