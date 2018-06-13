@echo off
setlocal

REM CMake
set cmakePath="C:\Program Files\CMake\bin\cmake.exe"

REM ninja
set ninjaPath="E:\Shared\Software\Ninja\ninja.exe"

REM FastCopy
set fastcopyPath="C:\Program Files\FastCopy\FastCopy.exe"

REM FastCopyモード
set fastcopyMode=/force_close

REM ビルドバッファ
set buildBuf=C:\Library\Temp

REM ライブラリパス
set eigenDir=Eigen

REM バージョン設定
set eigenVersion=3.3.4

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

REM FastCopyパス作成
set fastcopyExe=%fastcopyPath%
REM FastCopyパス表示
echo FastCopy : %fastcopyExe%

REM Eigenパス
set eigenPath=%sourceDir%\%eigenDir%
REM Eigenパス表示
echo Eigen : %eigenPath%

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
set buildDir=%buildBuf%\%vsVersion%\%platformName%\Eigen
REM ビルドディレクトリ表示
echo build directory : %buildDir%
REM ビルドディレクトリ確認
if not exist "%buildDir%" (
	mkdir "%buildDir%"
)
REM ビルドディレクトリへ移動
cd /d "%buildDir%"

%cmakeExe% "%eigenPath%" ^
-G "Ninja" ^
-DCMAKE_MAKE_PROGRAM=%ninjaExe:\=/% ^
-DBUILD_TESTING=OFF ^
-DCMAKE_BUILD_TYPE="Release" ^
-DCMAKE_INSTALL_PREFIX="%buildDir:\=/%/install"

%ninjaExe% install
call :ErrorCheck

REM インストールディレクトリ
set finalDir=%buildBuf%\Final\Eigen
REM インストールディレクトリ表示
echo install : %finalDir%

REM インストールディレクトリ削除
if exist "%finalDir%" (
	rd /S /Q "%finalDir%"
)

REM Eigenディレクトリコピー
%fastcopyExe% %fastcopyMode% /cmd=diff /exclude="*.txt;*.md" "install\include\eigen3" /to="%finalDir%\include"

REM バージョン番号ファイル追加
type nul > %finalDir%\Eigen_%eigenVersion%

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
