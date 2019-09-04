
file(GLOB_RECURSE sources_Core 	  Core/*.c            Core/*.h)
file(GLOB_RECURSE sources_Exec 		ZipHelper/*.cpp 		ZipHelper/*.h)

set(firecore_SRCS
  ${firecore_SRCS}
  ${sources_Core}
  ${sources_Exec}
)

add_executable(FireCore
  ${firecore_SRCS}
)

include_directories(
	${CMAKE_BINARY_DIR}
	${CMAKE_CURRENT_SOURCE_DIR}
	${MYSQL_INCLUDE_DIR}
)


target_link_libraries(FireCore

)