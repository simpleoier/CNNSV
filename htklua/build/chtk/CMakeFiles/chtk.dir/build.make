# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 2.8

#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:

# Remove some rules from gmake that .SUFFIXES does not remove.
SUFFIXES =

.SUFFIXES: .hpux_make_needs_suffix_list

# Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:
.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/bin/cmake

# The command to remove a file.
RM = /usr/bin/cmake -E remove -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
<<<<<<< HEAD
CMAKE_SOURCE_DIR = /slfs1/users/xkc09/CNNRSR2015/DNNsrc/htklua

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /slfs1/users/xkc09/CNNRSR2015/DNNsrc/htklua/build
=======
CMAKE_SOURCE_DIR = /home/chao/speechlab/summervacation/NeuralNetwork/DNNsrc/htklua

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/chao/speechlab/summervacation/NeuralNetwork/DNNsrc/htklua/build
>>>>>>> f545cc7c14b10ec1e879ee5cd4d7c5e234efa35d

# Include any dependencies generated for this target.
include chtk/CMakeFiles/chtk.dir/depend.make

# Include the progress variables for this target.
include chtk/CMakeFiles/chtk.dir/progress.make

# Include the compile flags for this target's objects.
include chtk/CMakeFiles/chtk.dir/flags.make

chtk/CMakeFiles/chtk.dir/chtk.cpp.o: chtk/CMakeFiles/chtk.dir/flags.make
chtk/CMakeFiles/chtk.dir/chtk.cpp.o: ../chtk/chtk.cpp
<<<<<<< HEAD
	$(CMAKE_COMMAND) -E cmake_progress_report /slfs1/users/xkc09/CNNRSR2015/DNNsrc/htklua/build/CMakeFiles $(CMAKE_PROGRESS_1)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object chtk/CMakeFiles/chtk.dir/chtk.cpp.o"
	cd /slfs1/users/xkc09/CNNRSR2015/DNNsrc/htklua/build/chtk && /usr/bin/c++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/chtk.dir/chtk.cpp.o -c /slfs1/users/xkc09/CNNRSR2015/DNNsrc/htklua/chtk/chtk.cpp

chtk/CMakeFiles/chtk.dir/chtk.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/chtk.dir/chtk.cpp.i"
	cd /slfs1/users/xkc09/CNNRSR2015/DNNsrc/htklua/build/chtk && /usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -E /slfs1/users/xkc09/CNNRSR2015/DNNsrc/htklua/chtk/chtk.cpp > CMakeFiles/chtk.dir/chtk.cpp.i

chtk/CMakeFiles/chtk.dir/chtk.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/chtk.dir/chtk.cpp.s"
	cd /slfs1/users/xkc09/CNNRSR2015/DNNsrc/htklua/build/chtk && /usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -S /slfs1/users/xkc09/CNNRSR2015/DNNsrc/htklua/chtk/chtk.cpp -o CMakeFiles/chtk.dir/chtk.cpp.s
=======
	$(CMAKE_COMMAND) -E cmake_progress_report /home/chao/speechlab/summervacation/NeuralNetwork/DNNsrc/htklua/build/CMakeFiles $(CMAKE_PROGRESS_1)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object chtk/CMakeFiles/chtk.dir/chtk.cpp.o"
	cd /home/chao/speechlab/summervacation/NeuralNetwork/DNNsrc/htklua/build/chtk && /usr/bin/c++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/chtk.dir/chtk.cpp.o -c /home/chao/speechlab/summervacation/NeuralNetwork/DNNsrc/htklua/chtk/chtk.cpp

chtk/CMakeFiles/chtk.dir/chtk.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/chtk.dir/chtk.cpp.i"
	cd /home/chao/speechlab/summervacation/NeuralNetwork/DNNsrc/htklua/build/chtk && /usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -E /home/chao/speechlab/summervacation/NeuralNetwork/DNNsrc/htklua/chtk/chtk.cpp > CMakeFiles/chtk.dir/chtk.cpp.i

chtk/CMakeFiles/chtk.dir/chtk.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/chtk.dir/chtk.cpp.s"
	cd /home/chao/speechlab/summervacation/NeuralNetwork/DNNsrc/htklua/build/chtk && /usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -S /home/chao/speechlab/summervacation/NeuralNetwork/DNNsrc/htklua/chtk/chtk.cpp -o CMakeFiles/chtk.dir/chtk.cpp.s
>>>>>>> f545cc7c14b10ec1e879ee5cd4d7c5e234efa35d

chtk/CMakeFiles/chtk.dir/chtk.cpp.o.requires:
.PHONY : chtk/CMakeFiles/chtk.dir/chtk.cpp.o.requires

chtk/CMakeFiles/chtk.dir/chtk.cpp.o.provides: chtk/CMakeFiles/chtk.dir/chtk.cpp.o.requires
	$(MAKE) -f chtk/CMakeFiles/chtk.dir/build.make chtk/CMakeFiles/chtk.dir/chtk.cpp.o.provides.build
.PHONY : chtk/CMakeFiles/chtk.dir/chtk.cpp.o.provides

chtk/CMakeFiles/chtk.dir/chtk.cpp.o.provides.build: chtk/CMakeFiles/chtk.dir/chtk.cpp.o

# Object files for target chtk
chtk_OBJECTS = \
"CMakeFiles/chtk.dir/chtk.cpp.o"

# External object files for target chtk
chtk_EXTERNAL_OBJECTS =

chtk/libchtk.so: chtk/CMakeFiles/chtk.dir/chtk.cpp.o
chtk/libchtk.so: chtk/CMakeFiles/chtk.dir/build.make
chtk/libchtk.so: chtk/CMakeFiles/chtk.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --red --bold "Linking CXX shared library libchtk.so"
<<<<<<< HEAD
	cd /slfs1/users/xkc09/CNNRSR2015/DNNsrc/htklua/build/chtk && $(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/chtk.dir/link.txt --verbose=$(VERBOSE)
=======
	cd /home/chao/speechlab/summervacation/NeuralNetwork/DNNsrc/htklua/build/chtk && $(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/chtk.dir/link.txt --verbose=$(VERBOSE)
>>>>>>> f545cc7c14b10ec1e879ee5cd4d7c5e234efa35d

# Rule to build all files generated by this target.
chtk/CMakeFiles/chtk.dir/build: chtk/libchtk.so
.PHONY : chtk/CMakeFiles/chtk.dir/build

chtk/CMakeFiles/chtk.dir/requires: chtk/CMakeFiles/chtk.dir/chtk.cpp.o.requires
.PHONY : chtk/CMakeFiles/chtk.dir/requires

chtk/CMakeFiles/chtk.dir/clean:
<<<<<<< HEAD
	cd /slfs1/users/xkc09/CNNRSR2015/DNNsrc/htklua/build/chtk && $(CMAKE_COMMAND) -P CMakeFiles/chtk.dir/cmake_clean.cmake
.PHONY : chtk/CMakeFiles/chtk.dir/clean

chtk/CMakeFiles/chtk.dir/depend:
	cd /slfs1/users/xkc09/CNNRSR2015/DNNsrc/htklua/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /slfs1/users/xkc09/CNNRSR2015/DNNsrc/htklua /slfs1/users/xkc09/CNNRSR2015/DNNsrc/htklua/chtk /slfs1/users/xkc09/CNNRSR2015/DNNsrc/htklua/build /slfs1/users/xkc09/CNNRSR2015/DNNsrc/htklua/build/chtk /slfs1/users/xkc09/CNNRSR2015/DNNsrc/htklua/build/chtk/CMakeFiles/chtk.dir/DependInfo.cmake --color=$(COLOR)
=======
	cd /home/chao/speechlab/summervacation/NeuralNetwork/DNNsrc/htklua/build/chtk && $(CMAKE_COMMAND) -P CMakeFiles/chtk.dir/cmake_clean.cmake
.PHONY : chtk/CMakeFiles/chtk.dir/clean

chtk/CMakeFiles/chtk.dir/depend:
	cd /home/chao/speechlab/summervacation/NeuralNetwork/DNNsrc/htklua/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/chao/speechlab/summervacation/NeuralNetwork/DNNsrc/htklua /home/chao/speechlab/summervacation/NeuralNetwork/DNNsrc/htklua/chtk /home/chao/speechlab/summervacation/NeuralNetwork/DNNsrc/htklua/build /home/chao/speechlab/summervacation/NeuralNetwork/DNNsrc/htklua/build/chtk /home/chao/speechlab/summervacation/NeuralNetwork/DNNsrc/htklua/build/chtk/CMakeFiles/chtk.dir/DependInfo.cmake --color=$(COLOR)
>>>>>>> f545cc7c14b10ec1e879ee5cd4d7c5e234efa35d
.PHONY : chtk/CMakeFiles/chtk.dir/depend

