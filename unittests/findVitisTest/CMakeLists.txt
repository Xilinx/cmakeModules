# RUN: %cmake -P %s | tee %t
# RUN: %grep -e "found components: AIE" %t
# RUN: %grep -e "found components: AIE2" %t

cmake_minimum_required(VERSION 3.21)
cmake_policy(SET CMP0144 OLD)

set(subDirLevels "../..")
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/${subDirLevels})

project(test_Find_Vitis)

#find_package(Vitis COMPONENTS AIE)
#find_package(Vitis COMPONENTS AIE2)
#find_package(Vitis)
#find_package(Vitis COMPONENTS AIE AIE2)
find_package(Vitis 2022.2 COMPONENTS AIE AIE2)