
####### Expanded from @PACKAGE_INIT@ by configure_package_config_file() #######
####### Any changes to this file will be overwritten by the next CMake run ####
####### The input file was package-config.cmakein                            ########

get_filename_component(PACKAGE_PREFIX_DIR "${CMAKE_CURRENT_LIST_DIR}/../" ABSOLUTE)

macro(set_and_check _var _file)
  set(${_var} "${_file}")
  if(NOT EXISTS "${_file}")
    message(FATAL_ERROR "File or directory ${_file} referenced by variable ${_var} does not exist !")
  endif()
endmacro()

macro(check_required_components _NAME)
  foreach(comp ${${_NAME}_FIND_COMPONENTS})
    if(NOT ${_NAME}_${comp}_FOUND)
      if(${_NAME}_FIND_REQUIRED_${comp})
        set(${_NAME}_FOUND FALSE)
      endif()
    endif()
  endforeach()
endmacro()

####################################################################################

if(OFF)
    find_package(Boost COMPONENTS
        date_time
        filesystem
        system
        REQUIRED)
endif()
if(BUILD_SHARED_LIBS)
  include("${CMAKE_CURRENT_LIST_DIR}/lib/leveldb-targets.cmake")
else()
  include("${CMAKE_CURRENT_LIST_DIR}/staticlib/leveldb-targets.cmake")
endif()

set(${CMAKE_FIND_PACKAGE_NAME}_INCLUDE_DIR ${PACKAGE_PREFIX_DIR}/include)
set(${CMAKE_FIND_PACKAGE_NAME}_INCLUDE_DIRS ${PACKAGE_PREFIX_DIR}/include)
set(${CMAKE_FIND_PACKAGE_NAME}_LIBRARIES leveldb)

string(TOUPPER "${CMAKE_FIND_PACKAGE_NAME}" UPPER_PACKAGE_NAME)

set(${UPPER_PACKAGE_NAME}_INCLUDE_DIR ${PACKAGE_PREFIX_DIR}/include)
set(${UPPER_PACKAGE_NAME}_INCLUDE_DIRS ${PACKAGE_PREFIX_DIR}/include)
set(${UPPER_PACKAGE_NAME}_LIBRARIES leveldb)
