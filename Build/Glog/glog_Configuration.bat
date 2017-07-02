@echo off
setlocal

rem CMake
set cmakePath=cmake-3.7.2-win64-x64\bin\cmake.exe

rem ninja
set ninjaPath=ninja-1.7.2\ninja.exe

rem ライブラリパス
set glogDir=glog-0.3.5

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

rem glog
set glogPath=%sourceDir%\%glogDir%
rem glogパス表示
echo glog : %glogPath%

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
set buildDir=%batchPath%Build_%vsVersion%_%platformName%_%linkType%_%configType%

rem ビルドディレクトリ表示
echo build directory : %buildDir%
rem ビルドディレクトリ確認
if not exist "%buildDir%" (
	mkdir "%buildDir%"
)
rem ビルドディレクトリへ移動
cd /d "%buildDir%"

%cmakeExe% "%glogPath%" ^
-G "Ninja"  ^
-DCMAKE_MAKE_PROGRAM=%ninjaExe:\=/% ^
-DCMAKE_BUILD_TYPE=%configType% ^
-DCMAKE_DEBUG_POSTFIX=d ^
-DCMAKE_INSTALL_PREFIX="%buildDir:\=/%/install" ^
-DBUILD_SHARED_LIBS=%flagShared% ^
-DBUILD_TESTING=OFF ^
-DWITH_GFLAGS=OFF

endlocal
