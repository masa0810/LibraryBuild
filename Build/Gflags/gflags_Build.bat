@echo off
setlocal

REM FastCopy
set fastcopyPath=FastCopy341_x64\FastCopy.exe

REM FastCopyモード
set fastcopyMode=/force_close

REM ninja
set ninjaPath=Ninja\ninja.exe

REM ビルドバッファ
set buildBuf=C:\Library\Temp

REM バージョン設定
set gflagsVersion=2.2.1

REM 並列ビルド数
set numOfParallel=%NUMBER_OF_PROCESSORS%

REM 引数解析
if /%1==/install (
	set buildType=install
) else (
	set buildType=
)

REM ビルド条件表示
echo build type : %buildType%

REM 現在のパスの保持
for /f "delims=" %%f in ( 'cd' ) do set currentPath=%%f

REM バッチファイルの場所
set batchPath=%~dp0

REM ソース置き場
cd /d "%batchPath%..\..\"
for /f "delims=" %%f in ( 'cd' ) do set sourceDir=%%f
cd /d "%currentPath%"

REM FastCopyパス作成
set fastcopyExe="%sourceDir%\Build\Tools\%fastcopyPath%"
REM FastCopyパス表示
echo FastCopy : %fastcopyExe%

REM Ninja
set ninjaExe="%sourceDir%\Build\Tools\%ninjaPath%"
REM Ninjaパス表示
echo Ninja : %ninjaExe%

REM Ninjaファイルチェック
call "%sourceDir%\Build\Ninja\Ninja_Build.bat"

REM アドレスモデル切り替え
if /%Platform%==/ (
	set platformName=Win32
) else (
	set platformName=x64
)

REM Visual Studioバージョン切り替え
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

echo Release
cd /d %batchPath%
call :Main release
echo Debug
cd /d %batchPath%
call :Main debug

goto :EOF

:Main

REM Release/Debug切り替え
if /%1==/debug (
	set configType=Debug
) else (
	set configType=Release
)

REM Configuration実行
call %batchPath%gflags_Configuration.bat %1

REM ビルドディレクトリ
set buildDir=%buildBuf%\%vsVersion%\%platformName%\%configType%\Gflags

REM ビルドディレクトリ表示
echo build directory : %buildDir%

REM ビルドディレクトリへ移動
cd /d "%buildDir%"
%ninjaExe% %buildType% -j %numOfParallel%
call :ErrorCheck

exit /b

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
