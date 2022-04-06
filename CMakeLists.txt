############################################################################
#                                                                          #
#  file: CMakeLists.txt                                                    #
#  Copyright (C) 2016                                                      #
#      Enrico Bertolazzi                                                   #
#      Dipartimento di Ingegneria Industriale                              #
#      Universita` degli Studi di Trento                                   #
#      <mailto:enrico.bertolazzi@unitn.it>                                 #
#                                                                          #
############################################################################

cmake_minimum_required(VERSION 2.8.13)
set( CMAKE_VERBOSE_MAKEFILE OFF )
set( CMAKE_INSTALL_MESSAGE NEVER )

if( CMAKE_BUILD_TYPE STREQUAL "Debug" )
  set( DEBUG_SUFFIX "_debug" )
else()
  set( DEBUG_SUFFIX )
endif()

if( BUILD_SHARED )
  if( APPLE )
    set( TARGET Communication_osx${DEBUG_SUFFIX} )
  elseif( LINUX OR UNIX )
    set( TARGET Communication_linux${DEBUG_SUFFIX} )
  else()
    set( TARGET Communication_win_${BITS}${DEBUG_SUFFIX} )
    set( CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON )
  endif()
endif()

if( APPLE )
  set( TARGETS Communication_osx_static${DEBUG_SUFFIX} )
elseif( LINUX OR UNIX )
  set( TARGETS Communication_linux_static${DEBUG_SUFFIX} )
else()
  set( TARGETS Communication_win_${BITS}_static${DEBUG_SUFFIX} )
endif()

project( Communication CXX C )

include( ./CMakeLists-cflags.txt )
message( STATUS "Compiler used: ${CMAKE_CXX_COMPILER_ID}")

set( CMAKE_C_FLAGS_RELEASE ${CMAKE_CXX_FLAGS_RELEASE} )
set( CMAKE_C_FLAGS_DEBUG   ${CMAKE_CXX_FLAGS_DEBUG} )

set( SOURCES )
file( GLOB S ./src/*.c )
foreach(F ${S})
  file( RELATIVE_PATH RF ${CMAKE_CURRENT_SOURCE_DIR} "${F}" )
  list( APPEND SOURCES ${RF} )
endforeach()
file( GLOB S ./src/*.cc )
foreach (F ${S})
  file( RELATIVE_PATH RF ${CMAKE_CURRENT_SOURCE_DIR} "${F}" )
  list( APPEND SOURCES ${RF} )
endforeach()

set( HEADERS )
file( GLOB S ./src/*.h* )
foreach (F ${S})
  file( RELATIVE_PATH RF ${CMAKE_CURRENT_SOURCE_DIR} "${F}" )
  list( APPEND HEADERS ${RF} )
endforeach()

include_directories( src )

set( CMAKE_INSTALL_PREFIX ${CMAKE_CURRENT_SOURCE_DIR}/lib )

if( BUILD_SHARED )
  add_library( ${TARGETS} STATIC ${SOURCES} ${HEADERS} )
  add_library( ${TARGET}  SHARED ${SOURCES} ${HEADERS} )
  install(
    TARGETS ${TARGET} ${TARGETS}
    RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX}/bin
    LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX}/dll
    ARCHIVE DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
  )
else()
  add_library( ${TARGETS} STATIC ${SOURCES} ${HEADERS} )
  install(
    TARGETS ${TARGETS}
    RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX}/bin
    LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX}/dll
    ARCHIVE DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
  )
endif()

if( BUILD_EXECUTABLE )
  set(EXECUTABLE_OUTPUT_PATH ${CMAKE_CURRENT_SOURCE_DIR}/bin)
  set( EXECUTABLE client_c server_c )
  foreach( EXE ${EXECUTABLE} )
    add_executable( ${EXE} test/${EXE}.c test/codriver_interfaces_data_structs.c ${HEADERS} )
    target_link_libraries( ${EXE} ${TARGETS} )
    if( NOT APPLE AND NOT UNIX AND NOT LINUX )
      target_link_libraries( ${EXE} Ws2_32.lib )
    endif()
  endforeach()
  set(
    EXECUTABLE
    client_cpp
    server_cpp
    server_client_test
    server_client_test2
    server_client_test3
    server_client_test4
  )
  foreach( EXE ${EXECUTABLE} )
    add_executable( ${EXE} test/${EXE}.cc test/codriver_interfaces_data_structs.c ${HEADERS} )
    target_link_libraries( ${EXE} ${TARGETS} )
    IF ( NOT APPLE AND NOT UNIX AND NOT LINUX )
      target_link_libraries( ${EXE} Ws2_32.lib )
    endif()
  endforeach()
endif()

install( FILES ${HEADERS} DESTINATION ${CMAKE_INSTALL_PREFIX}/include )

message( STATUS "Using ${SSE_FLAGS} extensions")
message( STATUS "C compiler                  = ${CMAKE_C_COMPILER_ID} ${CMAKE_C_COMPILER}" )
message( STATUS "C++ compiler                = ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER}" )
message( STATUS "CMAKE_CXX_FLAGS_RELEASE     = ${CMAKE_CXX_FLAGS_RELEASE}" )
message( STATUS "CMAKE_CXX_FLAGS             = ${CMAKE_CXX_FLAGS}" )
message( STATUS "CMAKE_C_FLAGS_RELEASE       = ${CMAKE_C_FLAGS_RELEASE}" )
message( STATUS "CMAKE_C_FLAGS               = ${CMAKE_C_FLAGS}" )
message( STATUS "CMAKE_SYSTEM_NAME           = ${CMAKE_SYSTEM_NAME}" )
message( STATUS "CMAKE_SYSTEM_PROCESSOR      = ${CMAKE_SYSTEM_PROCESSOR}" )
if(APPLE)
  message( STATUS "CMAKE_OSX_SYSROOT           = ${CMAKE_OSX_SYSROOT}" )
  message( STATUS "CMAKE_OSX_ARCHITECTURES     = ${CMAKE_OSX_ARCHITECTURES}" )
  message( STATUS "CMAKE_OSX_DEPLOYMENT_TARGET = ${CMAKE_OSX_DEPLOYMENT_TARGET}" )
endif()
message( STATUS "BUILD_EXECUTABLE            = ${BUILD_EXECUTABLE}" )
