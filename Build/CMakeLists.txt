cmake_minimum_required(VERSION 3.8.2)

# プロジェクト名
project(library-builder)

# コア数取得
include(ProcessorCount)
ProcessorCount(NUMBER_OF_PROCESSORS)

# 同時ビルド数
set(NUM_OF_BUILD ${NUMBER_OF_PROCESSORS} CACHE STRING "Number of build")

# Microsoft Visual C++ バージョンマップ
set(MSVC_VERSION_MAP_1600 v100)
set(MSVC_VERSION_MAP_1700 v110)
set(MSVC_VERSION_MAP_1800 v120)
set(MSVC_VERSION_MAP_1900 v140)
set(MSVC_VERSION_MAP_1910 v141)

# ツールセットバージョン
set(PLATFORM_TOOLSET_VER "${MSVC_VERSION_MAP_${MSVC_VERSION}}")

# ルートパス
get_filename_component(LIBRARY_BUILDER_LISTS_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)
get_filename_component(LIBRARY_BUILDER_LISTS_DIR "${LIBRARY_BUILDER_LISTS_DIR}" PATH)

# インストール先設定(ベース)
set(LIBRARY_BUILDER_INSTALL_DIR ${CMAKE_CURRENT_LIST_DIR}/Library CACHE PATH "Install Directory")
# インストール先設定(VSバージョン別)
set(LIBRARY_BUILDER_INSTALL_DIR_VC ${LIBRARY_BUILDER_INSTALL_DIR}/${PLATFORM_TOOLSET_VER} CACHE PATH "Install Directory(vc++ version)")
# ビルドタイプ
set(LIBRARY_BUILDER_CONFIGURATION_TYPES "Debug;Release" CACHE STRING "Configuration")
# リンクタイプ
option(LIBRARY_BUILDER_SHARED_LIBS "Create Shared library" OFF)

# Python探索
#set(Python_ADDITIONAL_VERSIONS 3.5)
#find_package(PythonInterp 3 REQUIRED)
#find_package(PythonLibs 3 REQUIRED)

# ソース名取得
include(CMake/SourcePath.cmake)

# Zlibビルド
if(EXISTS "${ZLIB_SRC}")
    add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/zlib ${CMAKE_CURRENT_BINARY_DIR}/zlib)
endif()

# HDF5
if(EXISTS "${HDF5_SRC}")
    add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/HDF5 ${CMAKE_CURRENT_BINARY_DIR}/HDF5)
endif()

# ProtoBuf
if(EXISTS "${PROTOBUF_SRC}")
    add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/ProtoBuf ${CMAKE_CURRENT_BINARY_DIR}/ProtoBuf)
endif()

# libJpeg-turbo
if(EXISTS "${LIBJPEGTURBO_SRC}")
    set(LIBJPEGTURBO_NASM ${CMAKE_CURRENT_LIST_DIR}/Tools/${LIBJPEGTURBO_NASM_NAME}/nasm.exe CACHE PATH "nasm path")
    add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/libJpeg-turbo ${CMAKE_CURRENT_BINARY_DIR}/libJpeg-turbo)
endif()

# gflags
if(EXISTS "${GFLAGS_SRC}")
    add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/gflags ${CMAKE_CURRENT_BINARY_DIR}/gflags)
endif()

# glog
if(EXISTS "${GLOG_SRC}")
    add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/glog ${CMAKE_CURRENT_BINARY_DIR}/glog)
endif()

# LMDB
if(EXISTS "${LMDB_SRC}")
    add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/LMDB ${CMAKE_CURRENT_BINARY_DIR}/LMDB)
endif()

# Snappy
if(EXISTS "${SNAPPY_SRC}")
    add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/Snappy ${CMAKE_CURRENT_BINARY_DIR}/Snappy)
endif()
