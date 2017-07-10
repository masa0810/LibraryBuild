@echo off
setlocal ENABLEDELAYEDEXPANSION

rem CMake
set cmakePath=cmake-3.7.2-win64-x64\bin\cmake.exe

rem ninja
set ninjaPath=ninja-1.7.2\ninja.exe

rem ライブラリパス
set leveldbDir=leveldb-1.18

rem Boostバージョン
set boostVersion=1_64

rem Staticビルド/Dynamicビルド切り替え
if /%1==/shared (
	set flagShared=OFF
	set flagStatic=OFF
    set linkType=Shared
	set boostPrefix=
	set boostPreProcesserOrig="/DBOOST_ALL_DYN_LINK"
) else (
	set flagShared=OFF
	set flagStatic=ON
    set linkType=Static
	set boostPrefix=lib
	set boostPreProcesserOrig=""
)
set boostPreProcesse=%boostPreProcesserOrig:"=%

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

rem LevelDB
set leveldbPath=%sourceDir%\%leveldbDir%
rem LevelDBパス表示
echo LevelDB : %leveldbPath%

rem アドレスモデル切り替え
if /%Platform%==/ (
	set platformName=Win32
) else (
	set platformName=x64
)

rem Visual Studioバージョン切り替え
if /%VisualStudioVersion%==/11.0 (
	set vsVersion=vs2012
	set vcVersion=110
) else if /%VisualStudioVersion%==/12.0 (
	set vsVersion=vs2013
	set vcVersion=120
) else if /%VisualStudioVersion%==/14.0 (
	set vsVersion=vs2015
	set vcVersion=140
) else if /%VisualStudioVersion%==/15.0 (
	set vsVersion=vs2017
	set vcVersion=141
) else (
	set vsVersion=vs2010
	set vcVersion=100
)

rem Boostインクルードパス
set boostIncludePath=%sourceDir%\Final\v%vcVersion%\Boost\include
rem Boostライブラリパス
set boostLibDir=%sourceDir%\Final\v%vcVersion%\Boost\lib
set boostLibDir2=%boostLibDir%\%platformName%
rem Boost Date Time
set boostDateTimeDebug=%boostLibDir%\%boostPrefix%boost_date_time-vc%vcVersion%-mt-gd-%boostVersion%.lib
if not exist "%boostDateTimeDebug%" (
	set boostDateTimeDebug=%boostLibDir2%\%boostPrefix%boost_date_time-vc%vcVersion%-mt-gd-%boostVersion%.lib
)
set boostDateTimeRelease=%boostLibDir%\%boostPrefix%boost_date_time-vc%vcVersion%-mt-%boostVersion%.lib
if not exist "%boostDateTimeRelease%" (
	set boostDateTimeRelease=%boostLibDir2%\%boostPrefix%boost_date_time-vc%vcVersion%-mt-%boostVersion%.lib
)
rem Boost Filesystem
set boostFilesystemDebug=%boostLibDir%\%boostPrefix%boost_filesystem-vc%vcVersion%-mt-gd-%boostVersion%.lib
if not exist "%boostFilesystemDebug%" (
	set boostFilesystemDebug=%boostLibDir2%\%boostPrefix%boost_filesystem-vc%vcVersion%-mt-gd-%boostVersion%.lib
)
set boostFilesystemRelease=%boostLibDir%\%boostPrefix%boost_filesystem-vc%vcVersion%-mt-%boostVersion%.lib
if not exist "%boostFilesystemRelease%" (
	set boostFilesystemRelease=%boostLibDir2%\%boostPrefix%boost_filesystem-vc%vcVersion%-mt-%boostVersion%.lib
)
rem Boost System
set boostSystemDebug=%boostLibDir%\%boostPrefix%boost_system-vc%vcVersion%-mt-gd-%boostVersion%.lib
if not exist "%boostSystemDebug%" (
	set boostSystemDebug=%boostLibDir2%\%boostPrefix%boost_system-vc%vcVersion%-mt-gd-%boostVersion%.lib
)
set boostSystemRelease=%boostLibDir%\%boostPrefix%boost_system-vc%vcVersion%-mt-%boostVersion%.lib
if not exist "%boostSystemRelease%" (
	set boostSystemRelease=%boostLibDir2%\%boostPrefix%boost_system-vc%vcVersion%-mt-%boostVersion%.lib
)

rem Boostパス表示
echo Boost Include : %boostIncludePath%
echo Boost Date Time Debug : %boostDateTimeDebug%
echo Boost Date Time Release : %boostDateTimeRelease%
echo Boost Filesystem Debug : %boostFilesystemDebug%
echo Boost Filesystem Release : %boostFilesystemRelease%
echo Boost System Debug : %boostSystemDebug%
echo Boost System Release : %boostSystemRelease%

rem Snappy
set snappyPath=%sourceDir%\Build\Snappy\Build_%vsVersion%_%platformName%_%linkType%_%configType%\install
rem Snappyインクルード
set snappyIncludePath=%snappyPath%\include
rem Snappyライブラリ
if /%linkType%==/Shared (
	if /%configType%==/Debug (
		set snappyLibPath=%snappyPath%\lib\snappyd.lib
	) else (
		set snappyLibPath=%snappyPath%\lib\snappy.lib
	)
) else (
	if /%configType%==/Debug (
		set snappyLibPath=%snappyPath%\lib\snappy_staticd.lib
	) else (
		set snappyLibPath=%snappyPath%\lib\snappy_static.lib
	)
)

rem Snappyパス表示
echo Snappy Include : %snappyIncludePath%
echo Snappy Library : %snappyLibPath%

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

%cmakeExe% "%leveldbPath%" ^
-G "Ninja"  ^
-DCMAKE_MAKE_PROGRAM=%ninjaExe:\=/% ^
-DCMAKE_BUILD_TYPE=%configType% ^
-DCMAKE_CXX_FLAGS="/DWIN32 /D_WINDOWS /W3 /GR /EHsc %boostPreProcesser%" ^
-DCMAKE_C_FLAGS="/DWIN32 /D_WINDOWS /W3 %boostPreProcesser%" ^
-DCMAKE_DEBUG_POSTFIX=d ^
-DCMAKE_INSTALL_PREFIX="%buildDir:\=/%/install" ^
-DBUILD_SHARED_LIBS=%flagShared% ^
-DBoost_USE_STATIC_LIBS=%flagStatic% ^
-DBoost_USE_STATIC_RUNTIME=OFF ^
-DBoost_USE_MULTITHREAD=ON ^
-DBoost_DATE_TIME_LIBRARY_DEBUG="%boostDateTimeDebug:\=/%" ^
-DBoost_DATE_TIME_LIBRARY_RELEASE="%boostDateTimeRelease:\=/%" ^
-DBoost_FILESYSTEM_LIBRARY_DEBUG="%boostFilesystemDebug:\=/%" ^
-DBoost_FILESYSTEM_LIBRARY_RELEASE="%boostFilesystemRelease:\=/%" ^
-DBoost_INCLUDE_DIR="%boostIncludePath:\=/%" ^
-DBoost_SYSTEM_LIBRARY_DEBUG="%boostSystemDebug:\=/%" ^
-DBoost_SYSTEM_LIBRARY_RELEASE="%boostSystemRelease:\=/%" ^
-DSNAPPY_INCLUDE_DIRS="%snappyIncludePath:\=/%" ^
-DSNAPPY_LIBRARY="%snappyLibPath:\=/%"

endlocal
