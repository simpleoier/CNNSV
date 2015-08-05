SET(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR})

CMAKE_MINIMUM_REQUIRED(VERSION 2.6 FATAL_ERROR)

IF(LUAROCKS_PREFIX)
    MESSAGE(STATUS "Installing Torch through Luarocks")
    STRING(REGEX REPLACE "(.*)lib/luarocks/rocks.*" "\\1" CMAKE_INSTALL_PREFIX  "${LUAROCKS_PREFIX}")
    MESSAGE(STATUS "Prefix inferred from Luarocks: ${CMAKE_INSTALL_PREFIX}")
ENDIF()

if(COMMAND cmake_policy)
	cmake_policy(SET CMP0003 NEW)
endif(COMMAND cmake_policy)

add_subdirectory (chtk)

#Torch includes

FIND_PACKAGE(Torch REQUIRED)
set(TORCH_INCLUDE_DIR ${CMAKE_INSTALL_PREFIX})
include_directories(${TORCH_INCLUDE_DIR} "chtk/")

include(CheckCXXCompilerFlag)
CHECK_CXX_COMPILER_FLAG("-std=c++11" COMPILER_SUPPORTS_CXX11)
CHECK_CXX_COMPILER_FLAG("-std=c++0x" COMPILER_SUPPORTS_CXX0X)
if(COMPILER_SUPPORTS_CXX11)
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
elseif(COMPILER_SUPPORTS_CXX0X)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")
else()
        message(STATUS "The compiler ${CMAKE_CXX_COMPILER} has no C++11 support. Please use a different C++ compiler.")
endif()

#LINK_DIRECTORIES(${TORCH_LIBRARY_DIR})


SET(src htktoth.cpp)
SET(luasrc init.lua)
ADD_TORCH_PACKAGE(htktoth "${src}" "${luasrc}" "Compatibility Tools")
target_link_libraries(htktoth chtk TH luaT z)

#add_executable(htktothtest htktoth.cpp)
#target_include_directories(htktothtest PUBLIC ${TORCH_INCLUDE_DIR} ${TORCH_LIBRARY_DIR})
#target_link_libraries(htktothtest TH luaT z)
