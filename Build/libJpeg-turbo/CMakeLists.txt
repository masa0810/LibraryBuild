cmake_minimum_required(VERSION 3.8.2)

# プロジェクト名
project(libJpegTurbo)
# 大文字プロジェクト名
string(TOUPPER ${PROJECT_NAME} PROJECT_NAME_UPPER)

# ビルドフラグ
option(BUILD_${PROJECT_NAME_UPPER} "${PROJECT_NAME} build" OFF)

# ビルド
if(BUILD_${PROJECT_NAME_UPPER})
    # 外部プロジェクトビルド
    include(ExternalProject)
    foreach(_config ${LIBRARY_BUILDER_CONFIGURATION_TYPES})
        # 小文字コンフィグタイプ
        string(TOLOWER ${_config} _config_lower)
        # バイナリディレクトリ
        set(BINARY_DIR_NAME ${PROJECT_NAME}_${PLATFORM_TOOLSET_VER}_${_config_lower})
        # 外部プロジェクトビルド
        ExternalProject_Add(
            ${BINARY_DIR_NAME}
            SOURCE_DIR ${${PROJECT_NAME_UPPER}_SRC}
            CMAKE_GENERATOR "Ninja"
            CMAKE_ARGS
                -DCMAKE_BUILD_TYPE=${_config}
                -DCMAKE_INSTALL_PREFIX=${LIBRARY_BUILDER_INSTALL_DIR_VC}/${PROJECT_NAME}
                -DCMAKE_DEBUG_POSTFIX=d
                -DNASM=${LIBJPEGTURBO_NASM}
                -DWITH_CRT_DLL=ON
                -DWITH_JPEG8=ON
                -DWITH_TURBOJPEG=OFF
            BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/${BINARY_DIR_NAME}
            BUILD_COMMAND ninja -j ${NUM_OF_BUILD}
            INSTALL_COMMAND ninja -j ${NUM_OF_BUILD} install
        )
    endforeach()
endif()