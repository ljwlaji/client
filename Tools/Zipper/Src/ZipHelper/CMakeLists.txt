
file(GLOB_RECURSE sources_Exec 		*.cpp 	*.h)

set(firecore_SRCS
  ${firecore_SRCS}
  ${sources_Exec}
)

add_executable(Zipper
  ${firecore_SRCS}
)

# link_directories(${CMAKE_CURRENT_SOURCE_DIR}/../)

target_link_libraries(Zipper ZLib)

include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}
	${CMAKE_CURRENT_SOURCE_DIR}/../
)