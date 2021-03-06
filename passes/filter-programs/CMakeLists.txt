cmake_minimum_required(VERSION 3.4.3)

#===============================================================================
# 1. LOAD LLVM CONFIGURATION
#===============================================================================
# Set this to a valid LLVM installation dir
set(LT_LLVM_INSTALL_DIR "" CACHE PATH "LLVM installation directory")

# Add the location of LLVMConfig.cmake to CMake search paths (so that
# find_package can locate it)
list(APPEND CMAKE_PREFIX_PATH "${LT_LLVM_INSTALL_DIR}/lib/cmake/llvm/")

find_package(LLVM REQUIRED)
if (${LLVM_VERSION_MAJOR} VERSION_LESS 9)
    message(SEND_ERROR "Unsupported LLVM version found: ${LLVM_PACKAGE_VERSION}")
endif()

# filter-programs includes headers from LLVM - update the include paths accordingly
include_directories(${LLVM_INCLUDE_DIRS})

#===============================================================================
# 2. LLVM-TUTOR BUILD CONFIGURATION
#===============================================================================
# Use the same C++ standard as LLVM does
set(CMAKE_CXX_STANDARD 14 CACHE STRING "")

# LLVM is normally built without RTTI. Be consistent with that.
if(NOT LLVM_ENABLE_RTTI)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-rtti")
endif()

# The following flag is used to enable the registration of filter-programs with the
# optimisation pipelines.
OPTION(FILTERPROGRAMS_OPT_PIPELINE_REG "Register filter-programs with the optimisation pipelines" OFF)
if(FILTERPROGRAMS_OPT_PIPELINE_REG)
  add_definitions(-DFILTERPROGRAMS_OPT_PIPELINE_REG)
endif()

#===============================================================================
# 3. ADD THE TARGET
#===============================================================================
add_library(filter-programs SHARED filter-programs.cpp)

# Allow undefined symbols in shared objects on Darwin (this is the default
# behaviour on Linux)
target_link_libraries(filter-programs
  "$<$<PLATFORM_ID:Darwin>:-undefined dynamic_lookup>")
