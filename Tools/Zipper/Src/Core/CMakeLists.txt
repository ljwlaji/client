
file(GLOB_RECURSE sources_Core 	  *.c            *.h)

set(zlib_SRCS
  ${zlib_SRCS}
  ${sources_Core}
)

# add_library(ZLib SHARED
add_library(ZLib STATIC
  ${zlib_SRCS}
)

include_directories(
	${CMAKE_BINARY_DIR}
	${CMAKE_CURRENT_SOURCE_DIR}
)