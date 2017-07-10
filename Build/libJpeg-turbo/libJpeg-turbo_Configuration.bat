@echo off
setlocal

rem CMake
set cmakePath=cmake-3.7.2-win64-x64\bin\cmake.exe

rem nasm
set nasmPath=nasm-2.13.01\nasm.exe

rem ninja
set ninjaPath=ninja-1.7.2\ninja.exe

rem ライブラリパス
set libJpeg-turboDir=libjpeg-turbo-1.5.1

rem Release/Debug切り替え
if /%1==/debug (
    set configType=Debug
) else (
    set configType=Release
)

rem ビルド条件表示
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

rem NASMパス作成
set nasmExe="%sourceDir%\Build\Tools\%nasmPath%"
rem NASMパス表示
echo NASM : %nasmExe%

rem Ninja
set ninjaExe="%sourceDir%\%ninjaPath%"
rem Ninjaパス表示
echo Ninja : %ninjaExe%

rem Ninjaファイルチェック
call "%sourceDir%\Build\Ninja\Ninja_Build.bat"

rem libJpeg-turbo
set libJpeg-turboPath=%sourceDir%\%libJpeg-turboDir%
rem libJpeg-turboパス表示
echo libJpeg-turbo : %libJpeg-turboPath%

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

rem ビルドディレクトリ
set buildDir=%batchPath%Build_%vsVersion%_%platformName%_%configType%

rem ビルドディレクトリ表示
echo build directory : %buildDir%
rem ビルドディレクトリ確認
if not exist "%buildDir%" (
	mkdir "%buildDir%"
)
rem ビルドディレクトリへ移動
cd /d "%buildDir%"

%cmakeExe% "%libJpeg-turboPath%" ^
-G "Ninja"  ^
-DCMAKE_MAKE_PROGRAM=%ninjaExe:\=/% ^
-DCMAKE_BUILD_TYPE=%configType% ^
-DCMAKE_DEBUG_POSTFIX=d ^
-DCMAKE_INSTALL_PREFIX="%buildDir:\=/%/install" ^
-DNASM=%nasmExe:\=/% ^
-DWITH_CRT_DLL=ON ^
-DWITH_JPEG8=ON ^
-DWITH_TURBOJPEG=OFF

endlocal
