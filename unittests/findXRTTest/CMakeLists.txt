# usage: cmake .. 
# usage with hint: cmake .. -DLibXAIE_ROOT=<path hint to xaiengine>  

cmake_minimum_required(VERSION 3.17)

set(subDirLevels "../..")
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/${subDirLevels})

project(test_Find_XRT)

find_package(XRT)