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
    # include
    include_gen = (build_dir / "install" / "include").glob("boost-*")
    result_state = com.copy_command(
        args, str(next(include_gen)), "/to={:s}".format(
            str(final_dir / "include")))

    # bin
    result_state &= com.copy_command(
        args, "/include=*.dll", str(build_dir / "install" / "lib"),
        "/to={:s}".format(str(final_dir / "bin" / platform_name)))

    # bin
    result_state &= com.copy_command(
        args, "/include=*.pdb", *[
            str(itm) for itm in (
                build_dir / "Tmp").glob("**/boost*{:d}*.pdb".format(vc_ver))
        ], "/to={:s}".format(str(final_dir / "bin" / platform_name)))

    # lib
    result_state &= com.copy_command(
        args, "/include=*.lib", str(build_dir / "install" / "lib"),
        "/to={:s}".format(str(final_dir / "lib" / platform_name)))

    return result_state


if __name__ == "__main__":
    """メイン"""
    # 引数取得
    args = com.get_args()

    # ライブラリ名
    lib_name = "Boost"
    # バージョン設定
    lib_ver = "1.69"

    # 引数表示
    print("Num Of CPU : {:d}".format(os.cpu_count()))
    print("AVX2 : {}".format(args.enable_avx2))

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
        "toolset={:s}".format(toolset_name), "address-model={:s}".format(
            "32" if platform_name == "Win32" else "64"), "link=static,shared",
        "runtime-link=shared", "threading=multi", "variant=release,debug",
        "embed-manifest=off", "debug-symbols=on", "-j{:d}".format(
            os.cpu_count()), "-sBZIP2_SOURCE={:s}".format(
                str(source_path / "bzip2")), "-sZLIB_SOURCE={:s}".format(
                    str(source_path / "zlib")), "--build-dir={:s}".format(
                        str(build_tmp)),
        "--prefix={:s}".format(str(install_dir)), "--stagedir={:s}".format(
            str(install_dir)), "--build-type=complete", "--without-mpi"
    ]
    if not args.enable_avx2:
        build_args.append("instruction-set=ivy-bridge")
    if toolset_name == "msvc-14.0":
        build_args.append("cxxflags=/std:c++latest")
    elif toolset_name == "msvc-14.1":
        arch_flag = "/arch:AVX2" if args.enable_avx2 else "/arch:AVX"
        build_args.append("cxxflags=/std:c++latest {:s}".format(arch_flag))
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
