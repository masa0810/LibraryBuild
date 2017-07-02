#----------------------------------------------------------------
# Generated CMake target import file for configuration "Debug".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "gflags_shared" for configuration "Debug"
set_property(TARGET gflags_shared APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
set_target_properties(gflags_shared PROPERTIES
  IMPORTED_IMPLIB_DEBUG "${_IMPORT_PREFIX}/lib/x64/gflagsd.lib"
  IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/bin/x64/gflagsd.dll"
  )

list(APPEND _IMPORT_CHECK_TARGETS gflags_shared )
list(APPEND _IMPORT_CHECK_FILES_FOR_gflags_shared "${_IMPORT_PREFIX}/lib/x64/gflagsd.lib" "${_IMPORT_PREFIX}/bin/x64/gflagsd.dll" )

# Import target "gflags_nothreads_shared" for configuration "Debug"
set_property(TARGET gflags_nothreads_shared APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
set_target_properties(gflags_nothreads_shared PROPERTIES
  IMPORTED_IMPLIB_DEBUG "${_IMPORT_PREFIX}/lib/x64/gflags_nothreadsd.lib"
  IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/bin/x64/gflags_nothreadsd.dll"
  )

list(APPEND _IMPORT_CHECK_TARGETS gflags_nothreads_shared )
list(APPEND _IMPORT_CHECK_FILES_FOR_gflags_nothreads_shared "${_IMPORT_PREFIX}/lib/x64/gflags_nothreadsd.lib" "${_IMPORT_PREFIX}/bin/x64/gflags_nothreadsd.dll" )

# Import target "gflags_static" for configuration "Debug"
set_property(TARGET gflags_static APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
set_target_properties(gflags_static PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG "CXX"
  IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/lib/x64/gflags_staticd.lib"
  )

list(APPEND _IMPORT_CHECK_TARGETS gflags_static )
list(APPEND _IMPORT_CHECK_FILES_FOR_gflags_static "${_IMPORT_PREFIX}/lib/x64/gflags_staticd.lib" )

# Import target "gflags_nothreads_static" for configuration "Debug"
set_property(TARGET gflags_nothreads_static APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
set_target_properties(gflags_nothreads_static PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG "CXX"
  IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/lib/x64/gflags_nothreads_staticd.lib"
  )

list(APPEND _IMPORT_CHECK_TARGETS gflags_nothreads_static )
list(APPEND _IMPORT_CHECK_FILES_FOR_gflags_nothreads_static "${_IMPORT_PREFIX}/lib/x64/gflags_nothreads_staticd.lib" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
