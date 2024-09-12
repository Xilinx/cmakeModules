# RUN: %cmake -P %s | tee %t
# RUN: %grep -e "found components: AIE" %t
# RUN: %grep -e "found components: AIE2" %t

cmake_minimum_required(VERSION 3.21)
cmake_policy(SET CMP0144 OLD)

set(subDirLevels "../..")
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/${subDirLevels})

project(test_Find_AIETools)

find_package(AIETools 2022.2 COMPONENTS AIE AIE2)