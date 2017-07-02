#----------------------------------------------------------------
# Generated CMake target import file for configuration "Debug".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "leveldb" for configuration "Debug"
set_property(TARGET leveldb APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
set_target_properties(leveldb PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG "CXX"
  IMPORTED_LINK_INTERFACE_LIBRARIES_DEBUG "${BOOST_LIBRARYDIR}/libboost_date_time-vc140-mt-gd-1_64.lib;${BOOST_LIBRARYDIR}/libboost_filesystem-vc140-mt-gd-1_64.lib;${BOOST_LIBRARYDIR}/libboost_system-vc140-mt-gd-1_64.lib"
  IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/lib/x64/static/leveldbd.lib"
  )

list(APPEND _IMPORT_CHECK_TARGETS leveldb )
list(APPEND _IMPORT_CHECK_FILES_FOR_leveldb "${_IMPORT_PREFIX}/lib/x64/static/leveldbd.lib" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
