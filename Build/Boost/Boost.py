"""
Boost Build
"""

# -*- coding: utf-8 -*-

import os
import shutil
import sys
import sysconfig
from pathlib import Path

sys.path.append(str((Path(__file__).parent.parent / "Common").resolve()))
import Common as com


def result_copy(final_dir, build_dir, platform_name, enable_shared,
                enable_debug, args):
    """ビルド結果コピー処理"""
    # FastCopyの引数作成
    include_gen = (build_dir / "install" / "include").glob("boost-*")
    fastcopy_args = [
        str(args.fastcopy_path), args.fastcopy_mode,
        "/exclude=cvconfig.h",
        str(next(include_gen)), "/to={:s}".format(str(final_dir / "include"))
    ]
    if args.verbose:
        print("FastCopy Args :")
        for i in fastcopy_args:
            print(i)
    # FastCopyを実行
    result_state = com.run_proc(fastcopy_args)

    # FastCopyの引数作成
    fastcopy_args = [
        str(args.fastcopy_path), args.fastcopy_mode,
        "/include=*.lib",
        str(build_dir / "install" / "lib"), "/to={:s}".format(
            str(final_dir / "lib" / platform_name))
    ]
    if args.verbose:
        print("FastCopy Args :")
        for i in fastcopy_args:
            print(i)
    # FastCopyを実行
    result_state = com.run_proc(fastcopy_args)

    # FastCopyの引数作成
    fastcopy_args = [
        str(args.fastcopy_path), args.fastcopy_mode,
        "/include=*.dll",
        str(build_dir / "install" / "lib"), "/to={:s}".format(
            str(final_dir / "bin" / platform_name))
    ]
    if args.verbose:
        print("FastCopy Args :")
        for i in fastcopy_args:
            print(i)
    # FastCopyを実行
    result_state = com.run_proc(fastcopy_args)

    # FastCopyの引数作成
    _, vc_ver = com.get_vs_env()
    pdb_list = [
        str(itm)
        for itm in (build_dir / "Tmp").glob("**/boost*{}*.pdb".format(vc_ver))
    ]
    fastcopy_args = [
        str(args.fastcopy_path), args.fastcopy_mode,
        "/to={:s}".format(str(final_dir / "bin" / platform_name))
    ]
    fastcopy_args.extend(pdb_list)
    if args.verbose:
        print("FastCopy Args :")
        for i in fastcopy_args:
            print(i)
    # FastCopyを実行
    result_state = com.run_proc(fastcopy_args)

    return result_state


if __name__ == "__main__":
    """メイン"""
    # 引数取得
    args = com.get_args()

    # ライブラリ名
    lib_name = "Boost"
    # バージョン設定
    lib_ver = "1.68"

    # 引数表示
    print("Num Of CPU : {:d}".format(os.cpu_count()))
    print("Auto SIMD : {}".format(not args.disable_auto_simd))

    # ライブラリパス
    source_path = Path(__file__).resolve().parent.parent.parent
    lib_dir = source_path / lib_name.lower()
    print("Library Dir : {:s}".format(str(lib_dir)))

    # メモリモデル
    platform_name = os.getenv("Platform", "Win32")
    print("Platform : {:s}".format(platform_name))

    # Visual Studio 環境
    vs_ver, vc_ver = com.get_vs_env()
    print("VS : {:s}, VC : {:d}".format(vs_ver, vc_ver))

    # ビルドディレクトリ
    build_dir = args.build_buf / vs_ver / platform_name / lib_name
    print("Build Dir : {:s}".format(str(build_dir)))

    # 現在のディレクトリを保存
    cur_dir = str(Path.cwd())
    print("Current Dir : {:s}".format(cur_dir))
    # ディレクトリ移動
    os.chdir(lib_dir)

    # b2ファイル作成
    if not (lib_dir / "b2.exe").exists() or args.rebuild:
        jam_file = Path("project-config.jam")
        if jam_file.exists():
            jam_file.unlink()
        # Bootstrapを実行
        result_state = com.run_proc(["bootstrap.bat"])
        # python設定
        with open("project-config.jam", "a") as f:
            f.write(
                "using python : {0} : {1} : {1}\\include : {1}\\libs ;".format(
                    sysconfig.get_python_version(),
                    source_path.parent / "Python").replace("\\", "/"))

    # ビルドディレクトリ
    if build_dir.exists() and args.rebuild:
        if args.force or com.input_yes_or_no("{:s}を削除しますか？".format(
                str(build_dir))):
            shutil.rmtree(str(build_dir))
    build_tmp = build_dir / "Tmp"
    install_dir = build_dir / "install"

    # ツールセットバージョン作成
    if vc_ver == 110:
        toolset_name = "msvc-11.0"
    elif vc_ver == 120:
        toolset_name = "msvc-12.0"
    elif vc_ver == 140:
        toolset_name = "msvc-14.0"
    elif vc_ver == 141:
        toolset_name = "msvc-14.1"
    elif vc_ver == 100:
        toolset_name = "msvc-10.0"

    # ビルド引数
    build_args = [
        "b2.exe", "install" if args.enable_install else "stage",
        "toolset={}".format(toolset_name),
        "address-model={}".format("32" if platform_name == "Win32" else "64"),
        "link=static,shared", "runtime-link=shared", "threading=multi",
        "variant=release,debug", "embed-manifest=off", "debug-symbols=on",
        "-j{}".format(os.cpu_count()), "--build-dir={}".format(build_tmp),
        "--prefix={}".format(install_dir), "--stagedir={}".format(install_dir),
        "--build-type=complete", "--without-mpi"
    ]
    if args.disable_auto_simd:
        build_args.append("instruction-set=nehalem")
    if toolset_name == "msvc-14.0" or toolset_name == "msvc-14.1":
        build_args.append("cxxflags=/std:c++latest")
    if args.verbose:
        print("Boost Build Args :")
        for i in build_args:
            print(i)
    # Bootstrapを実行
    success = com.run_proc(build_args)

    # 出力ファイルコピー
    if success and args.enable_install:
        success = com.copy(build_dir, lib_name, lib_name, lib_ver,
                           platform_name, vc_ver, None, None, False, args,
                           result_copy, True)

    sys.exit(0 if success else -1)
