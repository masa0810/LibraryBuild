@echo off
setlocal

REM CMake
set cmakePath=CMake\bin\cmake.exe

REM ninja
set ninjaPath=Ninja\ninja.exe

REM FastCopy
set fastcopyPath=FastCopy341_x64\FastCopy.exe

REM FastCopyモード
set fastcopyMode=/force_close

REM ビルドバッファ
set buildBuf=C:\Library\Temp

REM ライブラリパス
set cerealDir=cereal

REM バージョン設定
set cerealVersion=1.2.2

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

REM FastCopyパス作成
set fastcopyExe="%sourceDir%\Build\Tools\%fastcopyPath%"
REM FastCopyパス表示
echo FastCopy : %fastcopyExe%

REM Cerealパス
set cerealPath=%sourceDir%\%cerealDir%
REM Cerealパス表示
echo Cereal : %cerealPath%

REM アドレスモデル切り替え
if /%Platform%==/ (
	set platformName=Win32
) else (
	set platformName=x64
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
set buildDir=%buildBuf%\%vsVersion%\%platformName%\Cereal
REM ビルドディレクトリ表示
echo build directory : %buildDir%
REM ビルドディレクトリ確認
if not exist "%buildDir%" (
	mkdir "%buildDir%"
)
REM ビルドディレクトリへ移動
cd /d "%buildDir%"

%cmakeExe% "%cerealPath%" ^
-G "Ninja" ^
-DCMAKE_MAKE_PROGRAM=%ninjaExe:\=/% ^
-DCMAKE_BUILD_TYPE="Release" ^
-DCMAKE_INSTALL_PREFIX="%buildDir:\=/%/install" ^
-DJUST_INSTALL_CEREAL=ON ^
-DSKIP_PORTABILITY_TEST=ON

%ninjaExe% install
call :ErrorCheck

REM インストールディレクトリ
set finalDir=%buildBuf%\Final\Cereal
REM インストールディレクトリ表示
echo install : %finalDir%

REM インストールディレクトリ削除
if exist "%finalDir%" (
	rd /S /Q "%finalDir%"
)

REM Cerealディレクトリコピー
%fastcopyExe% %fastcopyMode% /cmd=diff /exclude="*.txt" "install/include" /to="%finalDir%\"

REM バージョン番号ファイル追加
type nul > %finalDir%\Cereal_%cerealVersion%

goto :EOF

:ErrorCheck
if not %errorlevel% == 0 (
	echo ERROR
	cd /d "%currentPath%"
	exit 1
) else (
	exit /b
)

goto :EOF

endlocal
