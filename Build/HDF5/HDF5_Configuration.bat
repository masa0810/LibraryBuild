@echo off
setlocal

rem CMake
set cmakePath=cmake-3.7.2-win64-x64\bin\cmake.exe

rem ninja
set ninjaPath=ninja-1.7.2\ninja.exe

rem ライブラリパス
set hdf5Dir=hdf5-1.10.1

rem Staticビルド/Dynamicビルド切り替え
if /%1==/shared (
	set flagShared=ON
    set linkType=Shared
) else (
	set flagShared=OFF
    set linkType=Static
)

rem Release/Debug切り替え
if /%2==/debug (
    set configType=Debug
) else (
    set configType=Release
)

rem ビルド条件表示
echo link type : %linkType%
echo config type : %configType%

rem 現在のパスの保持
for /f "delims=" %%f in ( 'cd' ) do set currentPath=%%f

rem バッチファイルの場所
set batchPath=%~dp0

rem ソース置き場
cd /d "%batchPath%..\..\"
for /f "delims=" %%f in ( 'cd' ) do set sourceDir=%%f
cd /d "%currentPath%"

rem CMakeパス作成
set cmakeExe="%sourceDir%\Build\Tools\%cmakePath%"
rem CMakeパス表示
echo CMake : %cmakeExe%

rem Ninja
set ninjaExe="%sourceDir%\%ninjaPath%"
rem Ninjaパス表示
echo Ninja : %ninjaExe%

rem Ninjaファイルチェック
call "%sourceDir%\Build\Ninja\Ninja_Build.bat"

rem HDF5
set hdf5Path=%sourceDir%\%hdf5Dir%
rem HDF5パス表示
echo HDF5 : %hdf5Path%

rem アドレスモデル切り替え
if /%Platform%==/ (
	set platformName=Win32
) else (
	set platformName=x64
)

rem Visual Studioバージョン切り替え
if /%VisualStudioVersion%==/11.0 (
	set vsVersion=vs2012
) else if /%VisualStudioVersion%==/12.0 (
	set vsVersion=vs2013
) else if /%VisualStudioVersion%==/14.0 (
	set vsVersion=vs2015
) else if /%VisualStudioVersion%==/15.0 (
	set vsVersion=vs2017
) else (
	set vsVersion=vs2010
)

rem zlib
set zlibPath=%sourceDir%\Build\Zlib\Build_%vsVersion%_%platformName%_%configType%\install
set zlibDebugPath=%sourceDir%\Build\Zlib\Build_%vsVersion%_%platformName%_Debug\install
set zlibReleasePath=%sourceDir%\Build\Zlib\Build_%vsVersion%_%platformName%_Release\install
rem zlibインクルード
set zlibIncludePath=%zlibPath%\include
rem zlibライブラリ
if /%linkType%==/Shared (
	set zlibDebugLibPath=%zlibDebugPath%\lib\zlibd.lib
	set zlibReleaseLibPath=%zlibReleasePath%\lib\zlib.lib
) else (
	set zlibDebugLibPath=%zlibDebugPath%\lib\zlibstaticd.lib
	set zlibReleaseLibPath=%zlibReleasePath%\lib\zlibstatic.lib
)

rem zlibパス表示
echo zlib Path : %zlibPath%
echo zlib include Path : %zlibIncludePath%
echo zlib debug lib Path : %zlibDebugLibPath%
echo zlib release lib Path : %zlibReleaseLibPath%

rem ビルドディレクトリ
set buildDir=%batchPath%Build_%vsVersion%_%platformName%_%linkType%_%configType%

rem ビルドディレクトリ表示
echo build directory : %buildDir%
rem ビルドディレクトリ確認
if not exist "%buildDir%" (
	mkdir "%buildDir%"
)
rem ビルドディレクトリへ移動
cd /d "%buildDir%"

%cmakeExe% "%hdf5Path%" ^
-G "Ninja"  ^
-DCMAKE_MAKE_PROGRAM=%ninjaExe:\=/% ^
-DCMAKE_BUILD_TYPE=%configType% ^
-DBUILD_SHARED_LIBS=%flagShared% ^
-DBUILD_STATIC_EXECS=ON ^
-DBUILD_TESTING=OFF ^
-DCMAKE_INSTALL_PREFIX="%buildDir:\=/%/install" ^
-DHDF5_BUILD_EXAMPLES=OFF ^
-DHDF5_BUILD_TOOLS=OFF ^
-DHDF5_ENABLE_Z_LIB_SUPPORT=ON ^
-DZLIB_INCLUDE_DIR="%zlibIncludePath:\=/%" ^
-DZLIB_LIBRARY_DEBUG="%zlibDebugLibPath:\=/%" ^
-DZLIB_LIBRARY_RELEASE="%zlibReleaseLibPath:\=/%"

endlocal
