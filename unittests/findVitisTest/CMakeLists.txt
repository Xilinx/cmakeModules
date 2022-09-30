# RUN: %cmake -P %s | tee %t
# RUN: %grep -e "-- Found Vitis:" %t

cmake_minimum_required(VERSION 3.17)

project(test_Find_Vitis)

find_package(Vitis)