cmake_minimum_required(VERSION 3.0)
project(Zipper)

include(CheckCXXSourceRuns)
include(CheckIncludeFiles)

# set macro-directory
# set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/macros")

# set default buildoptions and print them
# include(cmake/options.cmake)

# find_package(MySQL REQUIRED)

# add core sources
add_subdirectory(Src)