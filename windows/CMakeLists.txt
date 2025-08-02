cmake_minimum_required(VERSION 3.14)
project(tanger_map_app LANGUAGES CXX)

set(BINARY_NAME "tanger_map_app")

cmake_policy(SET CMP0063 NEW)

set(CMAKE_INSTALL_RPATH "$ORIGIN/lib")

# Configure build options.
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_BUILD_TYPE "Release" CACHE
    STRING "Flutter build mode" FORCE)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
    "Debug" "Profile" "Release")
endif()

set(CMAKE_EXE_LINKER_FLAGS_PROFILE "${CMAKE_EXE_LINKER_FLAGS_RELEASE}")
set(CMAKE_SHARED_LINKER_FLAGS_PROFILE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE}")
set(CMAKE_C_FLAGS_PROFILE "${CMAKE_C_FLAGS_RELEASE}")
set(CMAKE_CXX_FLAGS_PROFILE "${CMAKE_CXX_FLAGS_RELEASE}")

# Use colored output if the terminal supports it and the CMAKE_COLOR_MAKEFILE
# variable is enabled.
if(CMAKE_COLOR_MAKEFILE)
  set(CMAKE_COLOR_MAKEFILE ON)
endif()

# Generate build configuration files.
configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/generated_configs.h.in"
  "${CMAKE_CURRENT_BINARY_DIR}/generated_configs.h"
)

# Add precompiled header file.
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /FI\"${CMAKE_CURRENT_BINARY_DIR}/generated_configs.h\"")

# Application build; see runner/CMakeLists.txt.
add_subdirectory("runner") 