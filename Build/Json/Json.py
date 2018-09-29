"""
ライブラリビルド
"""

# -*- coding: utf-8 -*-

import argparse
import os
import shutil
import subprocess
import sys
from pathlib import Path

sys.path.append(str((Path(__file__).parent.parent / "Common").resolve()))
import Common as com


def result_copy(final_dir, build_dir, platform_name, enable_shared,
                enable_debug, args):
    """ビルド結果コピー処理"""
    # FastCopyの引数作成
    fastcopy_args = [
        str(args.fastcopy_path), args.fastcopy_mode, "/cmd=diff",
        str(build_dir / "install" / "include" / "nlohmann"), "/to={:s}".format(
            str(final_dir / "include" / "json"))
    ]
    if args.verbose:
        print("FastCopy Args :")
        for i in fastcopy_args:
            print(i)
    # FastCopyを実行
    result_state = com.run_proc(fastcopy_args)

    return result_state


def create_cmake_args(cmake_args, source_path, build_base_dir, platform_name,
                      vc_ver, args, enable_shared, enable_debug):
    """CMakeの引数作成"""
    cmake_args.append("-DBUILD_TESTING=OFF")
    cmake_args.append("-DJSON_BuildTests=OFF")

    return True


if __name__ == "__main__":
    """メイン"""
    # 引数取得
    args = com.get_args()

    # ライブラリ名
    lib_name = "Json"
    # バージョン設定
    lib_ver = "3.2.0"

    # ビルド実行
    success = com.build(
        lib_name,
        lib_ver,
        args,
        create_cmake_args,
        result_copy,
        enable_vs_share=True)

    sys.exit(0 if success else -1)
