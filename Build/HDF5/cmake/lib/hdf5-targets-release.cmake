#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "hdf5::hdf5-shared" for configuration "Release"
set_property(TARGET hdf5::hdf5-shared APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(hdf5::hdf5-shared PROPERTIES
  IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/lib/x64/hdf5.lib"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/bin/x64/hdf5.dll"
  INTERFACE_LINK_LIBRARIES "${_IMPORT_PREFIX}/../zlib/lib/x64/zlib.lib"
  )

list(APPEND _IMPORT_CHECK_TARGETS hdf5::hdf5-shared )
list(APPEND _IMPORT_CHECK_FILES_FOR_hdf5::hdf5-shared "${_IMPORT_PREFIX}/lib/x64/hdf5.lib" "${_IMPORT_PREFIX}/bin/x64/hdf5.dll" )

# Import target "hdf5::hdf5_hl-shared" for configuration "Release"
set_property(TARGET hdf5::hdf5_hl-shared APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(hdf5::hdf5_hl-shared PROPERTIES
  IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/lib/x64/hdf5_hl.lib"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/bin/x64/hdf5_hl.dll"
  )

list(APPEND _IMPORT_CHECK_TARGETS hdf5::hdf5_hl-shared )
list(APPEND _IMPORT_CHECK_FILES_FOR_hdf5::hdf5_hl-shared "${_IMPORT_PREFIX}/lib/x64/hdf5_hl.lib" "${_IMPORT_PREFIX}/bin/x64/hdf5_hl.dll" )

# Import target "hdf5::hdf5_cpp-shared" for configuration "Release"
set_property(TARGET hdf5::hdf5_cpp-shared APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(hdf5::hdf5_cpp-shared PROPERTIES
  IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/lib/x64/hdf5_cpp.lib"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/bin/x64/hdf5_cpp.dll"
  )

list(APPEND _IMPORT_CHECK_TARGETS hdf5::hdf5_cpp-shared )
list(APPEND _IMPORT_CHECK_FILES_FOR_hdf5::hdf5_cpp-shared "${_IMPORT_PREFIX}/lib/x64/hdf5_cpp.lib" "${_IMPORT_PREFIX}/bin/x64/hdf5_cpp.dll" )

# Import target "hdf5::hdf5_hl_cpp-shared" for configuration "Release"
set_property(TARGET hdf5::hdf5_hl_cpp-shared APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(hdf5::hdf5_hl_cpp-shared PROPERTIES
  IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/lib/x64/hdf5_hl_cpp.lib"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/bin/x64/hdf5_hl_cpp.dll"
  )

list(APPEND _IMPORT_CHECK_TARGETS hdf5::hdf5_hl_cpp-shared )
list(APPEND _IMPORT_CHECK_FILES_FOR_hdf5::hdf5_hl_cpp-shared "${_IMPORT_PREFIX}/lib/x64/hdf5_hl_cpp.lib" "${_IMPORT_PREFIX}/bin/x64/hdf5_hl_cpp.dll" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
