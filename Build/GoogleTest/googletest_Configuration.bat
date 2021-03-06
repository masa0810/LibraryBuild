@echo off
setlocal

REM CMake
set cmakePath="C:\Program Files\CMake\bin\cmake.exe"

REM ninja
set ninjaPath="E:\Shared\Software\Ninja\ninja.exe"

REM ライブラリパス
set googletestDir=googletest

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
set cmakeExe=%cmakePath%
REM CMakeパス表示
echo CMake : %cmakeExe%

REM Ninja
set ninjaExe=%ninjaPath%
REM Ninjaパス表示
echo Ninja : %ninjaExe%

REM googletest
set googletestPath=%sourceDir%\%googletestDir%
REM googletestパス表示
echo GoogleTest : %googletestPath%

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
set buildDir=%buildBuf%\%vsVersion%\%platformName%\%configType%\%linkType%\GoogleTest

REM ビルドディレクトリ表示
echo build directory : %buildDir%
REM ビルドディレクトリ確認
if not exist "%buildDir%" (
	mkdir "%buildDir%"
)
REM ビルドディレクトリへ移動
cd /d "%buildDir%"

%cmakeExe% "%googletestPath%" ^
-G "Ninja" ^
-DCMAKE_MAKE_PROGRAM=%ninjaExe:\=/% ^
-DCMAKE_BUILD_TYPE=%configType% ^
-DCMAKE_DEBUG_POSTFIX="d" ^
-DCMAKE_INSTALL_PREFIX="%buildDir:\=/%/install" ^
-DCMAKE_CXX_FLAGS="/DWIN32 /D_WINDOWS /W3 /GR /EHsc /D_SILENCE_TR1_NAMESPACE_DEPRECATION_WARNING" ^
-DCMAKE_C_FLAGS="/DWIN32 /D_WINDOWS /W3 /D_SILENCE_TR1_NAMESPACE_DEPRECATION_WARNING" ^
-DBUILD_GTEST=ON ^
-DBUILD_SHARED_LIBS=ON ^
-Dgtest_force_shared_crt=ON

endlocal
