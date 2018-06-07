@echo off
setlocal

REM CMake
set cmakePath=CMake\bin\cmake.exe

REM ninja
set ninjaPath=Ninja\ninja.exe

REM ライブラリパス
set gflagsDir=gflags

REM Release/Debug切り替え
if /%1==/debug (
	set configType=Debug
) else (
	set configType=Release
)

REM ビルド条件表示
echo config type : %configType%

REM 現在のパスの保持
for /f "delims=" %%f in ( 'cd' ) do set currentPath=%%f

REM バッチファイルの場所
set batchPath=%~dp0

REM ソース置き場
cd /d "%batchPath%..\..\"
for /f "delims=" %%f in ( 'cd' ) do set sourceDir=%%f
cd /d "%currentPath%"

REM CMakeパス作成
set cmakeExe="%sourceDir%\Build\Tools\%cmakePath%"
REM CMakeパス表示
echo CMake : %cmakeExe%

REM Ninja
set ninjaExe="%sourceDir%\Build\Tools\%ninjaPath%"
REM Ninjaパス表示
echo Ninja : %ninjaExe%

REM Ninjaファイルチェック
call "%sourceDir%\Build\Ninja\Ninja_Build.bat"

REM gflags
set gflagsPath=%sourceDir%\%gflagsDir%
REM gflagsパス表示
echo gflags : %gflagsPath%

REM アドレスモデル切り替え
if /%Platform%==/ (
	set platformName=Win32
	set platformNameShort=x86
) else (
	set platformName=x64
	set platformNameShort=x64
)

REM Visual Studioバージョン切り替え
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

REM ビルドディレク
set buildDir=%buildBuf%\%vsVersion%\%platformName%\%configType%\Gflags

REM ビルドディレクトリ表示
echo build directory : %buildDir%
REM ビルドディレクトリ確認
if not exist "%buildDir%" (
	mkdir "%buildDir%"
)
REM ビルドディレクトリへ移動
cd /d "%buildDir%"

%cmakeExe% "%gflagsPath%" ^
-G "Ninja" ^
-DCMAKE_MAKE_PROGRAM=%ninjaExe:\=/% ^
-DCMAKE_BUILD_TYPE=%configType% ^
-DCMAKE_INSTALL_PREFIX="%buildDir:\=/%/install" ^
-DCMAKE_DEBUG_POSTFIX=d ^
-DCMAKE_EXE_LINKER_FLAGS="/machine:%platformNameShort% /MANIFEST:NO" ^
-DCMAKE_MODULE_LINKER_FLAGS="/machine:%platformNameShort% /MANIFEST:NO" ^
-DCMAKE_SHARED_LINKER_FLAGS="/machine:%platformNameShort% /MANIFEST:NO" ^
-DBUILD_SHARED_LIBS=ON ^
-DBUILD_STATIC_LIBS=ON ^
-DREGISTER_BUILD_DIR=OFF ^
-DREGISTER_INSTALL_PREFIX=OFF

endlocal
