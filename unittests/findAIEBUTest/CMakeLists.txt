# Copyright (C) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: BSD-3-Clause
#

cmake_minimum_required(VERSION 3.17)
project(test_Find_AIEBU)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../..")
find_package(AIEBU REQUIRED)

if(NOT TARGET AIEBU::aiebu_static)
  message(FATAL_ERROR "FindAIEBU did not provide AIEBU::aiebu_static")
endif()

add_library(aiebu_consumer INTERFACE)
target_link_libraries(aiebu_consumer INTERFACE AIEBU::aiebu_static)

get_target_property(_aiebu_includes AIEBU::aiebu_static
  INTERFACE_INCLUDE_DIRECTORIES)
if(NOT AIEBU_INCLUDE_DIR IN_LIST _aiebu_includes)
  message(FATAL_ERROR "AIEBU::aiebu_static does not publish its public headers")
endif()
