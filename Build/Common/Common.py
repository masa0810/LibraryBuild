"""
共通
"""

# -*- coding: utf-8 -*-

import argparse
import os
import subprocess
import sys
from pathlib import Path

reset_dir_name = ""


def get_args():
    """コマンドライン引数作成"""
    global reset_dir_name

    # モジュール内変数のリセット
    reset_dir_name = ""
    # 準備
    parser = argparse.ArgumentParser(
        # プログラム名
        prog="Build",
        # プログラムの利用方法
        usage="ビルドスクリプト",
        # -h/–help オプションの追加
        add_help=True,
    )

    # 引数追加
    parser.add_argument("lib_names", help="ビルドするライブラリ", nargs="*")
    parser.add_argument(
        "-i",
        "--enable_install",
        help="インストール有効化",
        action="store_true",
        default=False)
    parser.add_argument(
        "-r",
        "--rebuild",
        help="ビルドディレクトリ再作成",
        action="store_true",
        default=False)
    parser.add_argument(
        "-f", "--force", help="強制実行", action="store_true", default=False)
    parser.add_argument(
        "-a",
        "--enable_avx2",
        help="AVX2の有効化",
        action="store_true",
        default=False)
    parser.add_argument(
        "-g", "--gui", help="CMake GUI 表示", action="store_true", default=False)
    parser.add_argument(
        "-v", "--verbose", help="詳細表示", action="store_true", default=False)
    parser.add_argument(
        "--fastcopy_path",
        help="FastCopy Path",
        default=r"C:\Library\Source\Build\Tools\FastCopy\FastCopy.exe",
        type=Path)
    parser.add_argument(
        "--fastcopy_mode", help="FastCopyモード", default="/force_close")
    parser.add_argument(
        "--cmake_dir",
        help="CMake Dir",
        default=r"C:\Library\Source\Build\Tools\CMake\bin",
        type=Path)
    parser.add_argument(
        "--nasm_path",
        help="NASM Path",
        default=r"C:\Library\Source\Build\Tools\NASM\nasm.exe",
        type=Path)
    parser.add_argument(
        "--ninja_path",
        help="Ninja Path",
        default=r"C:\Library\Source\Build\Tools\Ninja\ninja.exe",
        type=Path)
    parser.add_argument(
        "--build_buf",
        help="Build Buffer Path",
        default=r"C:\Library\Temp",
        type=Path)

    # 結果を受ける
    args = parser.parse_args()

    return (args)


def get_vs_env():
    """Visual Studio 環境取得"""
    visual_studio_version = os.getenv("VisualStudioVersion", "10.0")
    if visual_studio_version == "11.0":
        vs_ver = "vs2012"
        vc_ver = 110
    elif visual_studio_version == "12.0":
        vs_ver = "vs2013"
        vc_ver = 120
    elif visual_studio_version == "14.0":
        vs_ver = "vs2015"
        vc_ver = 140
    elif visual_studio_version == "15.0":
        if os.getenv("VSCMD_ARG_VCVARS_VER", "14.1") == "14.0":
            vs_ver = "vs2015"
            vc_ver = 140
        else:
            vs_ver = "vs2017"
            vc_ver = 141
    else:
        vs_ver = "vs2010"
        vc_ver = 100

    return vs_ver, vc_ver


def get_line(proc):
    """コマンドライン出力取得"""
    while True:
        line = proc.stdout.readline()
        if line:
            yield line
        if not line and proc.poll() is not None:
            break


def run_proc(proc_args):
    """プロセス実行"""
    # 実行
    proc = subprocess.Popen(
        proc_args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    # 出力をコンソールに出力
    for line in get_line(proc):
        sys.stdout.write(line.decode("sjis", "ignore"))
    return proc.returncode == 0


def input_yes_or_no(text=""):
    """入力確認"""
    if text:
        print(text)
    while True:
        inp = input("[Y]es/[N]o? >> ").lower()
        if inp in ("y", "yes", "n", "no"):
            return inp.startswith("y")
        print("Error! Input again.")


def copy_command(args, *copy_args):
    # 引数作成
    proc_args = [str(args.fastcopy_path), args.fastcopy_mode]
    proc_args.extend([arg for arg in copy_args])
    # 詳細表示
    if args.verbose:
        print("FastCopy Args :")
        for i in proc_args:
            print(i)
    # 実行
    return run_proc(proc_args)


def copy(build_dir, lib_name, dst_dir_name, lib_ver, platform_name, vc_ver,
         enable_shared, enable_debug, enable_vs_share, args, copy_func,
         enable_ver_check):
    """コピー実行"""
    global reset_dir_name

    # インストールディレクトリ
    final_dir = args.build_buf / "Final"
    if not enable_vs_share:
        final_dir /= "v{:d}".format(vc_ver)
    final_dir /= dst_dir_name
    print("Install Dir : {:s}".format(str(final_dir)))

    # バージョンチェック
    result_state = True
    ver_file = "{:s}_{:s}".format(lib_name, lib_ver)
    if final_dir.exists() and enable_ver_check:
        if args.rebuild:
            if reset_dir_name != final_dir and (args.force or input_yes_or_no(
                    "{:s}が存在します。削除しますか？".format(str(final_dir)))):
                # 削除処理
                result_state = copy_command(args, "/cmd=delete",
                                            "/no_confirm_del", str(final_dir))
                reset_dir_name = final_dir
        else:
            for itm in final_dir.glob("{:s}_*".format(lib_name)):
                itm_name = itm.name
                # 別バージョンが存在
                if itm_name != ver_file:
                    if args.force or input_yes_or_no(
                            "{:s}が存在します。削除しますか？".format(str(itm_name))):
                        # 削除処理
                        result_state = copy_command(args, "/cmd=delete",
                                                    "/no_confirm_del",
                                                    str(final_dir))
                    break
                # 同一バージョンが存在 かつ 共通ライブラリの場合
                elif enable_vs_share:
                    print("[{:s}] Skip Copy".format(lib_name))
                    return True

    # コピー処理
    if result_state:
        result_state = copy_func(final_dir, build_dir, platform_name,
                                 enable_shared, enable_debug, args)
    else:
        print("Error error final directory")

    # バージョン番号ファイル追加
    if result_state:
        ver_file_path = final_dir / ver_file
        if not ver_file_path.exists():
            ver_file_path.touch()
    else:
        print("Error result copy")

    return result_state


def build(lib_name,
          lib_ver,
          args,
          create_cmake_args_func,
          copy_func,
          lib_src_dir_name="",
          dst_dir_name="",
          enable_shared=False,
          enable_debug=False,
          enable_vs_share=False,
          enable_ver_check=True):
    """ビルド実行"""
    # 引数表示
    print("Num Of CPU : {:d}".format(os.cpu_count()))
    print("AVX2 : {}".format(args.enable_avx2))

    # ライブラリパス
    source_path = Path(__file__).resolve().parent.parent.parent
    lib_dir = source_path / (lib_src_dir_name
                             if lib_src_dir_name else lib_name.lower())
    print("Library Dir : {:s}".format(str(lib_dir)))

    # メモリモデル
    platform_name = os.getenv("Platform", "Win32").lower()
    print("Platform : {:s}".format(platform_name))

    # Visual Studio 環境
    vs_ver, vc_ver = get_vs_env()
    print("VS : {:s}, VC : {:d}".format(vs_ver, vc_ver))

    result_state = True
    if create_cmake_args_func != None:
        # ビルドタイプ
        build_type = "Debug" if enable_debug else "Release"
        print("Build Type : {:s}".format(build_type))
        # リンクタイプ
        link_type = "Shared" if enable_shared else "Static"
        print("Link Type : {:s}".format(link_type))

        # ビルドディレクトリ
        build_dir = args.build_buf / vs_ver / platform_name
        if enable_debug:
            build_dir /= build_type
        if enable_shared:
            build_dir /= link_type
        build_dir /= lib_name
        print("Build Dir : {:s}".format(str(build_dir)))

        # 現在のディレクトリを保存
        cur_dir = str(Path.cwd())
        print("Current Dir : {:s}".format(cur_dir))

        # ディレクトリチェック
        if build_dir.exists() and args.rebuild:
            if args.force or input_yes_or_no("{:s}を削除しますか？".format(
                    str(build_dir))):
                # 削除処理
                result_state = copy_command(args, "/cmd=delete",
                                            "/no_confirm_del", str(build_dir))
        if result_state:
            # ディレクトリ作成
            if not build_dir.exists():
                build_dir.mkdir(parents=True)

            # ディレクトリ移動
            os.chdir(build_dir)

            # マニュフェスト無効化
            linker_flag = "/machine:{:s} /MANIFEST:NO".format(
                "x64" if platform_name == "x64" else "x86")
            # CMake引数リスト
            cmake_args = [
                str(args.cmake_dir / "cmake"),
                str(lib_dir), "-G", "Ninja",
                "-DCMAKE_MAKE_PROGRAM={:s}".format(
                    str(args.ninja_path).replace(
                        "\\",
                        "/")), "-DCMAKE_BUILD_TYPE={:s}".format(build_type),
                "-DCMAKE_INSTALL_PREFIX={:s}".format(
                    str(build_dir / "install").replace("\\", "/")),
                "-DCMAKE_EXE_LINKER_FLAGS={:s}".format(linker_flag),
                "-DCMAKE_MODULE_LINKER_FLAGS={:s}".format(linker_flag),
                "-DCMAKE_SHARED_LINKER_FLAGS={:s}".format(linker_flag)
            ]
            result_state = create_cmake_args_func(
                cmake_args, source_path, platform_name, vs_ver, vc_ver, args,
                enable_shared, enable_debug)
        else:
            print("Error delete old directory")

        # CMakeを実行
        if result_state:
            print("CMake Args :")
            for i in cmake_args:
                print(i)
            result_state = run_proc(cmake_args)
            # CMake GUIを表示
            if args.gui:
                result_state &= run_proc(
                    [str(args.cmake_dir / "cmake-gui"),
                     str(build_dir)])
        else:
            print("Error create cmake args")

        # Ninjaを実行
        if result_state:
            # Ninja引数リスト
            ninja_args = [
                str(args.ninja_path), "-j",
                str(os.cpu_count()), "install"
            ]
            if args.verbose:
                print("Ninja Args :")
                for i in ninja_args:
                    print(i)
            result_state = run_proc(ninja_args)
        else:
            print("Error cmake")

        # ディレクトリ移動
        os.chdir(cur_dir)
    else:
        build_dir = lib_dir

    # 出力ファイルコピー
    if result_state:
        if args.enable_install and copy_func != None:
            result_state = copy(build_dir.resolve(), lib_name,
                                dst_dir_name if dst_dir_name else lib_name,
                                lib_ver, platform_name, vc_ver, enable_shared,
                                enable_debug, enable_vs_share, args, copy_func,
                                enable_ver_check)
            if not result_state:
                print("Error copy")
    else:
        print("Error ninja")

    return result_state
