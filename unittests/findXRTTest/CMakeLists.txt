# Copyright (C) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: BSD-3-Clause
#

cmake_minimum_required(VERSION 3.17)
project(test_Find_XRT)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../..")
find_package(XRT REQUIRED)

if(NOT TARGET XRT::xrt_coreutil)
  message(FATAL_ERROR "FindXRT did not provide XRT::xrt_coreutil")
endif()

add_library(xrt_consumer INTERFACE)
target_link_libraries(xrt_consumer INTERFACE XRT::xrt_coreutil)

if(NOT IS_ABSOLUTE "${XRT_COREUTIL}" OR NOT EXISTS "${XRT_COREUTIL}")
  message(FATAL_ERROR "FindXRT did not preserve the xrt_coreutil library path")
endif()
