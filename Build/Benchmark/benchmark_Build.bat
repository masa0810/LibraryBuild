@echo off
setlocal

REM FastCopy
set fastcopyPath="C:\Program Files\FastCopy\FastCopy.exe"

REM FastCopyモード
set fastcopyMode=/force_close

REM ninja
set ninjaPath="E:\Shared\Software\Ninja\ninja.exe"

REM ビルドバッファ
set buildBuf=C:\Library\Temp

REM バージョン設定
set benchmarkVersion=1.4.1

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
set fastcopyExe=%fastcopyPath%
REM FastCopyパス表示
echo FastCopy : %fastcopyExe%

REM Ninja
set ninjaExe=%ninjaPath%
REM Ninjaパス表示
echo Ninja : %ninjaExe%

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

echo Static Release
cd /d %batchPath%
call :Main static release
REM echo Shared Release
REM cd /d %batchPath%
REM call :Main shared release
echo Static Debug
cd /d %batchPath%
call :Main static debug
REM echo Shared Debug
REM cd /d %batchPath%
REM call :Main shared debug

goto :EOF

:Main

REM Staticビルド/Dynamicビルド切り替え
if /%1==/shared (
	set linkType=Shared
) else (
	set linkType=Static
)

REM Release/Debug切り替え
if /%2==/debug (
	set configType=Debug
) else (
	set configType=Release
)
REM Configuration実行
call %batchPath%benchmark_Configuration.bat %1 %2

REM ビルドディレクトリ
set buildDir=%buildBuf%\%vsVersion%\%platformName%\%configType%\%linkType%\Benchmark

REM ビルドディレクトリ表示
echo build directory : %buildDir%

REM ビルドディレクトリへ移動
cd /d "%buildDir%"
%ninjaExe% %buildType% -j %numOfParallel%
call :ErrorCheck

REM インストールディレクトリ
set finalDir=%buildBuf%\Final\v%vcVersion%\Benchmark

REM インストール
if /%buildType%==/install (
	REM インストールディレクトリ表示
	echo install : %finalDir%

	REM includeディレクトリコピー
	%fastcopyExe% %fastcopyMode% /cmd=diff "install\include" /to="%finalDir%\"

	REM libディレクトリコピー
	%fastcopyExe% %fastcopyMode% /cmd=diff /include="*.lib" "install\lib" /to="%finalDir%\lib\%platformName%"

	REM セットヘッダのコピー
	%fastcopyExe% %fastcopyMode% /cmd=diff "%batchPath%\files\benchmarkset.h" /to="%finalDir%\include\"

	REM バージョン番号ファイル追加
	type nul > %finalDir%\Benchmark_%benchmarkVersion%
)

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
