cmake_minimum_required(VERSION 3.0)
project(Zipper)

include(CheckCXXSourceRuns)
include(CheckIncludeFiles)

set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -DEBUG")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DEBUG")

set(LIBRARY_OUTPUT_DIR ${CMAKE_BINARY_DIR}/lib)
set(EXECUTE_OUTPUT_DIR ${CMAKE_BINARY_DIR}/bin)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${LIBRARY_OUTPUT_DIR})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${LIBRARY_OUTPUT_DIR})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${EXECUTE_OUTPUT_DIR})

add_subdirectory(Src)