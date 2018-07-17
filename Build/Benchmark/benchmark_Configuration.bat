@echo off
setlocal

REM CMake
set cmakePath=CMake\bin\cmake.exe

REM ninja
set ninjaPath=Ninja\ninja.exe

REM ライブラリパス
set benchmarkDir=benchmark

REM Staticビルド/Dynamicビルド切り替え
if /%1==/shared (
	set flagShared=ON
	set linkType=Shared
) else (
	set flagShared=OFF
	set linkType=Static
)
set postfixR=
set postfixD=d

REM Release/Debug切り替え
if /%2==/debug (
	set configType=Debug
) else (
	set configType=Release
)

REM ビルド条件表示
echo link type : %linkType%
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

REM benchmark
set benchmarkPath=%sourceDir%\%benchmarkDir%
REM benchmarkパス表示
echo Benchmark : %benchmarkPath%

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

REM ビルドディレクトリ
set buildDir=%buildBuf%\%vsVersion%\%platformName%\%configType%\%linkType%\Benchmark

REM ビルドディレクトリ表示
echo build directory : %buildDir%
REM ビルドディレクトリ確認
if not exist "%buildDir%" (
	mkdir "%buildDir%"
)
REM ビルドディレクトリへ移動
cd /d "%buildDir%"

%cmakeExe% "%benchmarkPath%" ^
-G "Ninja" ^
-DCMAKE_MAKE_PROGRAM=%ninjaExe:\=/% ^
-DCMAKE_BUILD_TYPE=%configType% ^
-DCMAKE_DEBUG_POSTFIX="d" ^
-DCMAKE_INSTALL_PREFIX="%buildDir:\=/%/install" ^
-DBENCHMARK_ENABLE_LTO=ON ^
-DBENCHMARK_ENABLE_TESTING=OFF

endlocal
