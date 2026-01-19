cmake_minimum_required(VERSION 3.10)

project(runner LANGUAGES CXX)

set(BINARY_NAME "eco_trail")
set(APPLICATION_ID "com.ecotrail.rayclosets")

cmake_policy(SET CMP0063 NEW)

set(CMAKE_INSTALL_RPATH "$ORIGIN/lib")

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/bundle" CACHE PATH "..." FORCE)
endif()

include(${CMAKE_SOURCE_DIR}/../linux/app_configuration.cmake OPTIONAL)

add_subdirectory(${CMAKE_SOURCE_DIR}/flutter)

add_executable(${BINARY_NAME}
  "main.cc"
  "my_application.cc"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
)

apply_standard_settings(${BINARY_NAME})

target_link_libraries(${BINARY_NAME} PRIVATE flutter)
target_link_libraries(${BINARY_NAME} PRIVATE PkgConfig::GTK)

target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")

install(TARGETS ${BINARY_NAME} RUNTIME DESTINATION "${CMAKE_INSTALL_PREFIX}"
  COMPONENT Runtime)

install(FILES "${FLUTTER_ICU_DATA_FILE}" DESTINATION "${CMAKE_INSTALL_PREFIX}"
  COMPONENT Runtime)

install(FILES "${FLUTTER_LIBRARY}" DESTINATION "${CMAKE_INSTALL_PREFIX}/lib"
  COMPONENT Runtime)

foreach(bundled_library ${FLUTTER_BUNDLED_LIBRARIES})
  install(FILES "${bundled_library}"
    DESTINATION "${CMAKE_INSTALL_PREFIX}/lib"
    COMPONENT Runtime)
endforeach(bundled_library)

install(DIRECTORY "${PROJECT_BUILD_DIR}/../blobs/"
  DESTINATION "${CMAKE_INSTALL_PREFIX}"
  COMPONENT Runtime)

if(PLUGIN_BUNDLED_LIBRARIES)
  install(FILES "${PLUGIN_BUNDLED_LIBRARIES}"
    DESTINATION "${CMAKE_INSTALL_PREFIX}/lib"
    COMPONENT Runtime)
endif()

install(DIRECTORY "${PROJECT_BUILD_DIR}/flutter_assets"
  DESTINATION "${CMAKE_INSTALL_PREFIX}"
  COMPONENT Runtime)

include(${CMAKE_SOURCE_DIR}/../linux/packaging.cmake OPTIONAL)

