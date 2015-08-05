<<<<<<< HEAD
# Install script for directory: /slfs1/users/xkc09/CNNRSR2015/CNNsrc/htklua
=======
# Install script for directory: /slfs1/users/xkc09/CNNRSR2015/DNNsrc/htklua
>>>>>>> 2d75f91783f3cee1624a726da8fc7dc50c44d368

# Set the install prefix
IF(NOT DEFINED CMAKE_INSTALL_PREFIX)
  SET(CMAKE_INSTALL_PREFIX "/slfs1/users/xkc09/TOOLS/torch/install")
ENDIF(NOT DEFINED CMAKE_INSTALL_PREFIX)
STRING(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
IF(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  IF(BUILD_TYPE)
    STRING(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  ELSE(BUILD_TYPE)
    SET(CMAKE_INSTALL_CONFIG_NAME "Release")
  ENDIF(BUILD_TYPE)
  MESSAGE(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
ENDIF(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)

# Set the component getting installed.
IF(NOT CMAKE_INSTALL_COMPONENT)
  IF(COMPONENT)
    MESSAGE(STATUS "Install component: \"${COMPONENT}\"")
    SET(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  ELSE(COMPONENT)
    SET(CMAKE_INSTALL_COMPONENT)
  ENDIF(COMPONENT)
ENDIF(NOT CMAKE_INSTALL_COMPONENT)

# Install shared libraries without execute permission?
IF(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)
  SET(CMAKE_INSTALL_SO_NO_EXE "1")
ENDIF(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)

IF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified")
  IF(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/luarocks/rocks/htktoth/1.0-0/lib/libhtktoth.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/luarocks/rocks/htktoth/1.0-0/lib/libhtktoth.so")
    FILE(RPATH_CHECK
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/luarocks/rocks/htktoth/1.0-0/lib/libhtktoth.so"
         RPATH "$ORIGIN/../lib:/slfs1/users/xkc09/TOOLS/torch/install/lib:/opt/OpenBLAS/lib")
  ENDIF()
<<<<<<< HEAD
  FILE(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/luarocks/rocks/htktoth/1.0-0/lib" TYPE MODULE FILES "/slfs1/users/xkc09/CNNRSR2015/CNNsrc/htklua/build/libhtktoth.so")
=======
  FILE(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/luarocks/rocks/htktoth/1.0-0/lib" TYPE MODULE FILES "/slfs1/users/xkc09/CNNRSR2015/DNNsrc/htklua/build/libhtktoth.so")
>>>>>>> 2d75f91783f3cee1624a726da8fc7dc50c44d368
  IF(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/luarocks/rocks/htktoth/1.0-0/lib/libhtktoth.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/luarocks/rocks/htktoth/1.0-0/lib/libhtktoth.so")
    FILE(RPATH_CHANGE
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/luarocks/rocks/htktoth/1.0-0/lib/libhtktoth.so"
<<<<<<< HEAD
         OLD_RPATH "/slfs1/users/xkc09/CNNRSR2015/CNNsrc/htklua/build/chtk:/slfs1/users/xkc09/TOOLS/torch/install/lib:/opt/OpenBLAS/lib:"
=======
         OLD_RPATH "/slfs1/users/xkc09/CNNRSR2015/DNNsrc/htklua/build/chtk:/slfs1/users/xkc09/TOOLS/torch/install/lib:/opt/OpenBLAS/lib:"
>>>>>>> 2d75f91783f3cee1624a726da8fc7dc50c44d368
         NEW_RPATH "$ORIGIN/../lib:/slfs1/users/xkc09/TOOLS/torch/install/lib:/opt/OpenBLAS/lib")
    IF(CMAKE_INSTALL_DO_STRIP)
      EXECUTE_PROCESS(COMMAND "/usr/bin/strip" "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/luarocks/rocks/htktoth/1.0-0/lib/libhtktoth.so")
    ENDIF(CMAKE_INSTALL_DO_STRIP)
  ENDIF()
ENDIF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified")

IF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified")
<<<<<<< HEAD
  FILE(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/luarocks/rocks/htktoth/1.0-0/lua/htktoth" TYPE FILE FILES "/slfs1/users/xkc09/CNNRSR2015/CNNsrc/htklua/init.lua")
=======
  FILE(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/luarocks/rocks/htktoth/1.0-0/lua/htktoth" TYPE FILE FILES "/slfs1/users/xkc09/CNNRSR2015/DNNsrc/htklua/init.lua")
>>>>>>> 2d75f91783f3cee1624a726da8fc7dc50c44d368
ENDIF(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified")

IF(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
<<<<<<< HEAD
  INCLUDE("/slfs1/users/xkc09/CNNRSR2015/CNNsrc/htklua/build/chtk/cmake_install.cmake")
=======
  INCLUDE("/slfs1/users/xkc09/CNNRSR2015/DNNsrc/htklua/build/chtk/cmake_install.cmake")
>>>>>>> 2d75f91783f3cee1624a726da8fc7dc50c44d368

ENDIF(NOT CMAKE_INSTALL_LOCAL_ONLY)

IF(CMAKE_INSTALL_COMPONENT)
  SET(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INSTALL_COMPONENT}.txt")
ELSE(CMAKE_INSTALL_COMPONENT)
  SET(CMAKE_INSTALL_MANIFEST "install_manifest.txt")
ENDIF(CMAKE_INSTALL_COMPONENT)

<<<<<<< HEAD
FILE(WRITE "/slfs1/users/xkc09/CNNRSR2015/CNNsrc/htklua/build/${CMAKE_INSTALL_MANIFEST}" "")
FOREACH(file ${CMAKE_INSTALL_MANIFEST_FILES})
  FILE(APPEND "/slfs1/users/xkc09/CNNRSR2015/CNNsrc/htklua/build/${CMAKE_INSTALL_MANIFEST}" "${file}\n")
=======
FILE(WRITE "/slfs1/users/xkc09/CNNRSR2015/DNNsrc/htklua/build/${CMAKE_INSTALL_MANIFEST}" "")
FOREACH(file ${CMAKE_INSTALL_MANIFEST_FILES})
  FILE(APPEND "/slfs1/users/xkc09/CNNRSR2015/DNNsrc/htklua/build/${CMAKE_INSTALL_MANIFEST}" "${file}\n")
>>>>>>> 2d75f91783f3cee1624a726da8fc7dc50c44d368
ENDFOREACH(file)
