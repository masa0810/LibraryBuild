cmake_minimum_required(VERSION 3.8.2)

# プロジェクト名
project(zlib)
# 大文字プロジェクト名
string(TOUPPER ${PROJECT_NAME} PROJECT_NAME_UPPER)

# ビルドフラグ
option(BUILD_${PROJECT_NAME_UPPER} "${PROJECT_NAME} build" OFF)

# ビルド
if(BUILD_${PROJECT_NAME_UPPER})
    # インクルードパス
    set(ZLIB_INCLUDE_DIR ${LIBRARY_BUILDER_INSTALL_DIR_VC}/${PROJECT_NAME}/include CACHE PATH "Include Directory")

    # ライブラリパス
    if(${LIBRARY_BUILDER_SHARED_LIBS})
        # 共有ライブラリの場合
        set(ZLIB_LIBRARY_DEBUG ${LIBRARY_BUILDER_INSTALL_DIR_VC}/${PROJECT_NAME}/lib/zlibd.lib CACHE PATH "Debug Library")
        set(ZLIB_LIBRARY_RELEASE ${LIBRARY_BUILDER_INSTALL_DIR_VC}/${PROJECT_NAME}/lib/zlib.lib CACHE PATH "Release Library")
    else()
        # 静的ライブラリの場合
        set(ZLIB_LIBRARY_DEBUG ${LIBRARY_BUILDER_INSTALL_DIR_VC}/${PROJECT_NAME}/lib/zlibstaticd.lib CACHE PATH "Debug Library")
        set(ZLIB_LIBRARY_RELEASE ${LIBRARY_BUILDER_INSTALL_DIR_VC}/${PROJECT_NAME}/lib/zlibstatic.lib CACHE PATH "Release Library")
    endif()

    # 上位スコープに変数をセット
    set(ZLIB_INCLUDE_DIR ${ZLIB_INCLUDE_DIR} PARENT_SCOPE)
    set(ZLIB_LIBRARY_DEBUG ${ZLIB_LIBRARY_DEBUG} PARENT_SCOPE)
    set(ZLIB_LIBRARY_RELEASE ${ZLIB_LIBRARY_RELEASE} PARENT_SCOPE)

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
            BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/${BINARY_DIR_NAME}
            BUILD_COMMAND ninja -j ${NUM_OF_BUILD}
            INSTALL_COMMAND ninja -j ${NUM_OF_BUILD} install
        )
    endforeach()
endif()