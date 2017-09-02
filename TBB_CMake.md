# 前書き

多くの開発者がCMakeを使用して開発プロジェクトを管理しているため、Intel（R）Threading Building Blocks（Intel（R）TBB）**チームは、TBBライブラリとCMakeプロジェクトの統合を簡素化するためにCMakeモジュールのセットを作成しました。

これらのモジュールは、TBB 2017 U7から、[<tbb_root>/cmake](https://github.com/01org/tbb/tree/tbb_2017/cmake)から利用できます。


## TBBについて

TBBは、標準のISO C ++コードを使用してスケーラブルな並列プログラミングをサポートするライブラリです。特別な言語やコンパイラは必要ありません。

スケーラブルなデータ並列プログラミングを促進するように設計されています。

さらに、ネストされた並列性を完全にサポートしているため、より小さい並列コンポーネントからより大きな並列コンポーネントを構築できます。ライブラリを使用するには、スレッドではなくタスクを指定し、ライブラリがタスクを効率的にスレッドにマッピングさせるようにします。

ライブラリインタフェースの多くは、ジェネリックプログラミングを採用しています。

インタフェースは、特定のタイプではなくタイプに関する要件によって定義されます。

C++標準テンプレートライブラリ（STL）は、汎用プログラミングの例です。汎用プログラミングにより、TBBは柔軟で効率的です。ジェネリックインターフェイスを使用すると、特定のニーズに合わせてコンポーネントをカスタマイズできます。

結果として、TBBを使用すると、生スレッドを使用するよりもはるかに便利に並列処理を指定できると同時に、パフォーマンスを向上させることができます。


## 参考文献

* [公式TBBオープンソースサイト](https://www.threadingbuildingblocks.org)
* [公式GitHubリポジトリ](https://github.com/01org/tbb)


## エンジニアリングチーム連絡先

TBBチームは、TBBライブラリを顧客プロジェクトに簡単に統合することに非常に関心があります。

これらのCMakeモジュールは、シンプルで強力なインターフェースを使用してCMakeプロジェクトにこのような可能性を提供するために作成されました。

これらのモジュールをお試しいただければ幸いです。

皆様のご意見をお待ちしております！

私たちに電子メールを送ってください：[inteltbbdevelopers@intel.com](mailto：inteltbbdevelopers@intel.com)

[フォーラム](https://software.intel.com/en-us/forums/intel-threading-building-blocks)をご覧ください。


## リリースノート

サポートされている最小限のCMakeバージョン：
> `3.0.0`

[find_package](https://cmake.org/cmake/help/latest/command/find_package.html)によるTBBのバージョニングは機能が制限されています：
> アップデート番号（インタフェースバージョンだけでなく）の互換性もチェックされていません。

サポートされているバージョン管理：
> `find_package（TBB <major>。<minor>`。

TBBインタフェースのバージョンは、 `TBB_INTERFACE_VERSION`変数を使用してカスタマプロジェクトで取得できます。


## CMake対応プロジェクトへのTBB統合の使用事例

TBBパッケージには2種類あります。

*Windows*OS、*LinuxOS*、および*macOS*用のバイナリがあらかじめ組み込まれたバイナリパッケージ。

これらはGithubリポジトリの[リリースページ](https://github.com/01org/tbb/releases)で入手できます。

バイナリパッケージの統合の主な目的は、TBBヘッダーファイルとバイナリをCMake対応のプロジェクトにビルドする機能です。

ソースパッケージは、リリースページから「ソースコード」リンクを介してダウンロードすることもできます。

さらに、 `git clone https：//github.com/01org/tbb.git`でリポジトリからクローンを作成することもできます。

ソース・パッケージ統合の主な目的は、ソース・ファイルからTBBライブラリーのカスタムビルドを行い、それをCMake対応プロジェクトに組み込むことです。

TBBを統合するために使用できるCMakeモジュールには、 **TBBConfig**、**TBBGet**、**TBBMakeConfig**、**TBBBuild**の4種類があります。

詳細は、*CMakeモジュールの技術文書*セクションを参照してください。


## バイナリパッケージの統合

次の使用例は、TBB 2017 U7から始まるパッケージで有効です。

### パッケージを手動でダウンロードして統合する。

### 前提条件：
> TBBConfig.cmakeの場所は `TBB_DIR`で、または`CMAKE_PREFIX_PATH`からはTBBルートへのパスが含まれています。

### 統合のためのCMakeコード：
```cmake
find_package（TBB <options>）
```

次の使用例は、すべてのTBB 2017パッケージで有効です。

### **TBBGet**を使ってパッケージをダウンロードし、統合する。

### 事前条件：
> TBB CMakeモジュールは、`<path-to-tbb-cmake-modules>`を介して利用できます。

### 統合のためのCMakeコード：
```cmake
include（<path-to-tbb-cmake-modules>/TBBGet.cmake）
tbb_get（TBB_ROOT tbb_root CONFIG_DIR TBB_DIR）
find_package（TBB <options>）
```

## ソースパッケージの統合

### **TBBBuild**を使用して既存のソースファイルからTBBをビルドし、統合する。

### 事前条件：
> TBBソース・コードは`<tbb_root>`で、TBB CMakeモジュールは`<path-tobb-cmake-modules>`で利用できます。

### 統合のためのCMakeコード：
```cmake
include（<path-to-tbb-cmake-modules> /TBBBuild.cmake）
tbb_build（TBB_ROOT <tbb_root> CONFIG_DIR TBB_DIR）
find_package（TBB <options>）
```

### **TBBGet**を使用してTBBソースファイルをダウンロードし、**TBBBuild**を使用してビルドして統合する。

### 事前条件：
> TBB CMakeモジュールは、`<path-to-tbb-cmake-modules>`を介して利用できます。

### 統合のためのCMakeコード：
```cmake
include（<path-to-tbb-cmake-modules> /TBBGet.cmake）
include（<path-to-tbb-cmake-modules> /TBBBuild.cmake）
tbb_get（TBB_ROOT tbb_root SOURCE_CODE）
tbb_build（TBB_ROOT $ {tbb_root} CONFIG_DIR TBB_DIR）
find_package（TBB <options>）
```


## チュートリアル：CMakeを使用したTBBの統合

### `sub_string_finder`サンプル（*Windows*OS）へのバイナリーTBBの統合

この例では、バイナリのTBBパッケージを*Windows*OS（Microsoft Visual Studio）の`sub_string_finder`サンプルに統合します。

この例は、わずかな変更を加えた他のプラットフォームにも適用できます。

プレースホルダ`<version>`と`<date>`は、使用中のTBBパッケージの実際の値に置き換えてください。

この例は `CMake 3.7.1`のために書かれています。


#### 前提条件：
> `Microsoft Visual Studio 11`以上

> `CMake 3.0.0`以上

[このページ](https://github.com/01org/tbb/releases/latest)から最新のWindows用バイナリパッケージをダウンロードし、`C：\demo_tbb_cmake`ディレクトリに解凍してください。

#### ディレクトリ`C：\demo_tbb_cmake\tbb<version>_<date>oss\examples\GettingStarted\sub_string_finder`は、以下の内容の`CMakeLists.txt`ファイルを作成します：
```cmake
cmake_minimum_required(VERSION 3.0.0 FATAL_ERROR)

project(sub_string_finder CXX)
add_executable(sub_string_finder sub_string_finder.cpp)

# find_package will search for available TBBConfig using variables CMAKE_PREFIX_PATH and TBB_DIR.
find_package(TBB REQUIRED tbb)

# Link TBB imported targets to the executable;
# "TBB::tbb" can be used instead of "${TBB_IMPORTED_TARGETS}".
target_link_libraries(sub_string_finder ${TBB_IMPORTED_TARGETS})
```

#### CMake GUIを実行して：
1. 以下のフィールドを入力します（`ソースの参照`と`参照のビルド`を使用することができます）
1. ソースコードはどこにありますか：
`C：/demo_tbb_cmake/tbb<version>_<date>oss/examples/GettingStarted/sub_string_finder`
1. バイナリをビルドする場所：
`C：/demo_tbb_cmake/tbb<version>_<date>oss/examples/GettingStarted/sub_string_finder/build`
1. `Add Entry`ボタンを使って新しいキャッシュエントリを追加して、CMakeに**TBBConfig**の検索場所を知らせます：
    - Name: `CMAKE_PREFIX_PATH`
    - Type: `PATH`
    - Value: `C:/demo_tbb_cmake/tbb<version>_<date>oss`
1. `Generate`ボタンを押し、Microsoft Visual Studioバージョンに適切なジェネレータを選択します。

    > これで、Microsoft Visual Studioで、生成されたソリューション `C:/demo_tbb_cmake/tbb<version>_<date>oss/examples/GettingStarted/sub_string_finder/build/sub_string_finder.sln`を開いてビルドできます。


### TBBと`sub_string_finder`サンプルのソースコード統合（*Linux*OS）

この例では、コミュニティ・プレビュー機能を有効にしたソース・コードからTBBをビルドし、`sub_string_finder`サンプルとビルド・ライブラリをリンクします。

この例は、わずかな変更を加えた他のプラットフォームにも適用できます。

#### 前提条件：
> `CMake 3.0.0`以上
> `Git`（GitHubからTBBリポジトリをクローンする）

#### ディレクトリ`~/demo_tbb_cmake`を作成し、作成したディレクトリに移動してそこにあるTBBリポジトリをクローンします：
```bash
$ mkdir ~/demo_tbb_cmake
$ cd ~/demo_tbb_cmake
$ git clone https://github.com/01org/tbb.git
```

#### `~/demo_tbb_cmake/tbb/examples/GettingStarted/sub_string_finder`ディレクトリに以下の内容の`CMakeLists.txt`ファイルを作成します：
```cmake
cmake_minimum_required(VERSION 3.0.0 FATAL_ERROR)

project(sub_string_finder CXX)
add_executable(sub_string_finder sub_string_finder.cpp)

include(${TBB_ROOT}/cmake/TBBBuild.cmake)

# Build TBB with enabled Community Preview Features (CPF).
tbb_build(TBB_ROOT ${TBB_ROOT} CONFIG_DIR TBB_DIR MAKE_ARGS tbb_cpf=1)

find_package(TBB REQUIRED tbb_preview)

# Link TBB imported targets to the executable;
# "TBB::tbb_preview" can be used instead of "${TBB_IMPORTED_TARGETS}".
target_link_libraries(sub_string_finder ${TBB_IMPORTED_TARGETS})
```

ソースのビルドを実行するための`sub_string_finder`サンプルのビルドディレクトリを作成し、作成されたディレクトリに移動します。
```bash
$ mkdir ~/demo_tbb_cmake/tbb/examples/GettingStarted/sub_string_finder/build
$ cd ~/demo_tbb_cmake/tbb/examples/GettingStarted/sub_string_finder/build
```

CMakeを実行して、`sub_string_finder`サンプルのMakefileを準備し、ビルドを実行する場所にTBBの場所（ルート）を指定します。
```bash
cmake -DTBB_ROOT=${HOME}/demo_tbb_cmake/tbb
```

実行可能ファイルを作成して実行します。
```cmake
make
./sub_string_finder
```


## CMakeモジュールの技術文書

### TBBConfig

Intel（R）TBB（TBBライブラリ用の設定モジュールです。

#### CMakeプロジェクトでこのモジュールを使用する方法：

TBB（ルート）の場所を[CMAKE_PREFIX_PATH](https://cmake.org/cmake/help/latest/variable/CMAKE_PREFIX_PATH.html)もしくは`TBB_DIR`に**TBBConfig.cmake**の場所を指定してください。

TBBを構成するには、[find_package](https://cmake.org/cmake/help/latest/command/find_package.html)を使用します。

提供された変数および/またはインポートされたターゲット（後述）を使用して、TBBを操作します。

TBBのコンポーネントは、 [find_package](https://cmake.org/cmake/help/latest/command/find_package.html)
キーワード`COMPONENTS`または`REQUIRED`の後に入力します。
コンポーネントの基本名（`tbb`、`tbbmalloc`、`tbb_preview`など）を使用します。

コンポーネントが指定されていない場合、デフォルトは`tbb`、`tbbmalloc`、`tbb_preview`です。

`tbbmalloc_proxy`が要求された場合、`tbbmalloc_proxy`のための`tbbmalloc`コンポーネントも追加され、依存関係として設定されます。

**TBBConfig**は [インポートされたターゲット](https://cmake.org/cmake/help/latest/manual/cmake-buildsystem.7.html#imported-targets)を作成します。
`TBB::<component>`(`TBB::tbb`,`TBB::tbbmalloc`)のような形式の共有ライブラリを作成します。

TBB構成時に設定される変数：
| 変数                     | 説明                                   |
|:------------------------|:---------------------------------------|
| `TBB_FOUND`             | TBBライブラリが見つかりました                 |
| `TBB_<component>_FOUND` | 特定のTBBコンポーネントが見つかりました         |
| `TBB_IMPORTED_TARGETS`  | すべてTBBのインポートされたターゲットを作成しました |
| `TBB_VERSION`           | TBBのバージョン（形式：`<major>.<minor>`）    |
| `TBB_INTERFACE_VERSION` | TBBインターフェースのバージョン               |


### TBBGet

[GitHub](https://github.com/01org/tbb)からTBBライブラリを入手するためのモジュールです。

以下の機能を提供します。

```cmake
tbb_get(TBB_ROOT <variable> [RELEASE_TAG <release_tag>|LATEST] [SAVE_TO <path>] [SYSTEM_NAME Linux|Windows|Darwin] [CONFIG_DIR <variable> | SOURCE_CODE])
```

**TBBConfig**がない場合、GitHubからTBBをダウンロードし、ダウンロードしたバイナリパッケージ用の**TBBConfig**を作成します。

| パラメータ                            | 説明 |
|:-----------------------------------|:-----|
| `TBB_ROOT <variable>`              | TBBのルートを保存する変数、`<variable>-NOTFOUND`は`tbb_get`が失敗した場合に備えて提供されます |
| `RELEASE_TAG <release_tag>|LATEST` | ダウンロードするTBBリリースタグ（たとえば`2017_U6`）<br>`LATEST`がデフォルトで使用されます |
| `SAVE_TO <path>`                   | ダウンロードされたTBBをアンパックする場所へのパス<br>`${CMAKE_CURRENT_BINARY_DIR}/tbb_downloaded`がデフォルトで使用されます |
| `SYSTEM_NAME Linux|Windows|Darwin` | バイナリパッケージをダウンロードするためのオペレーティングシステム名<br>[`CMAKE_SYSTEM_NAME`](https://cmake.org/cmake/help/latest/variable/CMAKE_SYSTEM_NAME.html)の値はデフォルトで使用されます |
| `CONFIG_DIR <variable>`            | **TBBConfig.cmake**と**TBBConfigVersion.cmake**の場所を保存する変数<br>`SOURCE_CODE`が指定されている場合は無視されます |
| `SOURCE_CODE`                      | TBBソースコードを取得するフラグ（バイナリパッケージではなく） |


### TBBMakeConfig

TBBバイナリパッケージで**TBBConfig**を作るためのモジュールです。

このモジュールは、**TBBConfig**を持たないパッケージに使用されます。

以下の機能を提供します。
```cmake
tbb_make_config(TBB_ROOT <path> CONFIG_DIR <variable> [SYSTEM_NAME Linux|Windows|Darwin])
```
インテル®TBBバイナリー・パッケージ用のCMake構成ファイル（**TBBConfig.cmake**および**TBBConfigVersion.cmake**）を作成します。

| パラメータ                            | 説明 |
|:-----------------------------------|:-----|
| `TBB_ROOT <variable>`              | TBBルートへのパス |
| `CONFIG_DIR <variable>`            | 作成された設定ファイルの場所を格納する変数 |
| `SYSTEM_NAME Linux|Windows|Darwin` | バイナリのTBBパッケージのオペレーティング・システム名、デフォルトで[`CMAKE_SYSTEM_NAME`](https://cmake.org/cmake/help/latest/variable/CMAKE_SYSTEM_NAME.html)の値が使用されます |


### TBBBuild

TBBライブラリをソースコードからビルドするためのモジュールです。

以下の機能を提供します。
```cmake
tbb_build(TBB_ROOT <tbb_root> CONFIG_DIR <variable> [MAKE_ARGS <custom_make_arguments>])
```

`Makefile`を使ってTBBをソースコードからビルドし、CMakeの設定ファイル（**TBBConfig.cmake**と**TBBConfigVersion.cmake**）の場所を作成して提供します。

| パラメータ | 説明 |
|:-|:-|
| `TBB_ROOT <variable>` | TBBルートへのパス |
| `CONFIG_DIR <variable>` | `tbb_build`が失敗した場合に備えて、作成された設定ファイルの場所を格納する変数`<variable>-NOTFOUND`が提供されます |
| `MAKE_ARGS <custom_make_arguments>` | `make`ツールに渡されるカスタム引数<br> 以下の引数は`<custom_make_arguments>`で再定義されていなければ、自動的に検出された値とともに`make`ツールに渡されます：<br> - `compiler=<compiler>`<br> - `tbb_build_dir=<tbb_build_dir>`<br> - `tbb_build_prefix=<tbb_build_prefix>`<br> - `-j<n>` |
