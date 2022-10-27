# RUN: %cmake -P %s | tee %t
# RUN: %grep -e "-- Found VitisHLS:" %t

cmake_minimum_required(VERSION 3.17)

set(subDirLevels "../..")
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/${subDirLevels})

project(test_Find_VitisHLS)

find_package(VitisHLS)