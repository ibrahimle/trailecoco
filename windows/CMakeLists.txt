cmake_minimum_required(VERSION 3.14)

project(eco_trail LANGUAGES CXX)

set(BINARY_NAME "eco_trail")

cmake_policy(SET CMP0063 NEW)

set(CMAKE_INSTALL_RPATH "$ORIGIN/lib")

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/bundle" CACHE PATH "..." FORCE)
endif()

include(${CMAKE_SOURCE_DIR}/../windows/app_configuration.cmake OPTIONAL)

add_subdirectory(flutter)

add_subdirectory(runner)

