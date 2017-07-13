cmake_minimum_required(VERSION 3.8.2)

set(CMAKE_BUILD_TYPE "Release" CACHE STRING "ビルドタイプ")
set(CMAKE_INSTALL_PREFIX ${CMAKE_CURRENT_LIST_DIR}/install CACHE PATH "インストール先")

# zlibフォルダ探索
file(GLOB zlib_cmake_paths ../zlib*/CMakeLists.txt)
# 複数見つかった場合用にソート
list(SORT zlib_cmake_paths)
# 先頭のパスを取り出し
list(GET zlib_cmake_paths 0 zlib_cmake_path)
# 絶対パスに変換
get_filename_component(zlib_cmake_path ${zlib_cmake_path} ABSOLUTE)
# ディレクトリ名取得
get_filename_component(zlib_dir ${zlib_cmake_path} DIRECTORY)
# zlibのルートパス作成
set(zlib_root ${zlib_dir} CACHE PATH "zlibのルートパス")
# zlibのcmakeリストパスを改めて作成
get_filename_component(zlib_cmake_path ${zlib_root}/CMakeLists.txt ABSOLUTE)

message(STATUS ${zlib_cmake_path})
message(STATUS ${CMAKE_CURRENT_BINARY_DIR})
message(STATUS ${CMAKE_CURRENT_SOURCE_DIR})

add_subdirectory(${zlib_root} ${CMAKE_CURRENT_BINARY_DIR}/zlib)