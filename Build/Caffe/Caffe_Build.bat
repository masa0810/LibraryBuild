@echo off
setlocal enabledelayedexpansion

REM FastCopy
set fastcopyPath=FastCopy341_x64\FastCopy.exe

REM FastCopyモード
set fastcopyMode=/force_close

REM ninja
set ninjaPath=Ninja\ninja.exe

REM ビルドバッファ
set buildBuf=C:\Library\Temp

REM Pythonパス
set pythonDir=C:\Library\Python

REM バージョン設定
set caffeVersion=1.0.0

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

REM echo Static Release
REM cd /d %batchPath%
REM call :Main static release
echo Shared Release
cd /d %batchPath%
call :Main shared release
REM echo Static Debug
REM cd /d %batchPath%
REM call :Main static debug
echo Shared Debug
cd /d %batchPath%
call :Main shared debug

goto :EOF

:Main

REM Staticビルド/Dynamicビルド切り替え
if /%1==/shared (
	set linkType=Shared
	set numOfParallel=%NUMBER_OF_PROCESSORS%
) else (
	set linkType=Static
	set numOfParallel=1
)

REM Release/Debug切り替え
if /%2==/debug (
	set configType=Debug
) else (
	set configType=Release
)

REM Configuration実行
call %batchPath%Caffe_Configuration.bat %1 %2

REM ビルドディレクトリ
set buildDir=%buildBuf%\%vsVersion%\%platformName%\%configType%\%linkType%\Caffe

REM ビルドディレクトリ表示
echo build directory : %buildDir%

REM ビルドディレクトリへ移動
cd /d "%buildDir%"
%ninjaExe% %buildType% -j %numOfParallel%
call :ErrorCheck

REM インストールディレクトリ
set finalDir=%buildBuf%\Final\v%vcVersion%\Caffe

REM インストール
if /%buildType%==/install (
	REM インストールディレクトリ表示
	echo install : %finalDir%

	REM includeディレクトリコピー
	%fastcopyExe% %fastcopyMode% /cmd=diff "install\include" /to="%finalDir%\"

	REM bin&libファイルコピー
	if /%linkType%==/Shared (
		call :Shared
	) else (
		call :Static
	)

	REM セットヘッダのコピー
	%fastcopyExe% %fastcopyMode% /cmd=diff "%batchPath%\files\caffeset.h" /to="%finalDir%\include\"

	REM Copyバッチのコピー
	%fastcopyExe% %fastcopyMode% /cmd=diff "%batchPath%\files\CaffeCopy.bat" /to="%finalDir%\"

	REM バージョン番号ファイル追加
	type nul > %finalDir%\Caffe_%caffeVersion%
)

exit /b

goto :EOF

:Shared

REM binディレクトリコピー
%fastcopyExe% %fastcopyMode% /cmd=diff /include="caffe*.dll;caffe*.pdb" "bin" /to="%finalDir%\bin\%platformName%"

REM PythonDLLのコピー
if exist "%pythonDir%\python35.dll" (
	%fastcopyExe% %fastcopyMode% /cmd=diff "%pythonDir%\python35.dll" /to="%finalDir%\bin\%platformName%"
) else if exist "%pythonDir%\python36.dll" (
	%fastcopyExe% %fastcopyMode% /cmd=diff "%pythonDir%\python36.dll" /to="%finalDir%\bin\%platformName%"
)

REM libディレクトリコピー
%fastcopyExe% %fastcopyMode% /cmd=diff /include="*.lib" /exclude="caffeproto*.lib" "install\lib" /to="%finalDir%\lib\%platformName%"

exit /b

goto :EOF

:Static

REM libディレクトリコピー
%fastcopyExe% %fastcopyMode% /cmd=diff /include="*.lib" "install\lib" /to="%finalDir%\lib\%platformName%"

REM PythonLibのコピー
%fastcopyExe% %fastcopyMode% /cmd=diff /include="python*.lib" /exclude="python3.lib" "%pythonDir%\libs" /to="%finalDir%\lib\%platformName%"

if /%configType%==/Release (
	REM Caffe.exeコピー
	%fastcopyExe% %fastcopyMode% /cmd=diff /include="*.exe" "install\bin" /to="%finalDir%\etc"
	REM PythonDLLのコピー
	if exist "%pythonDir%\python35.dll" (
		%fastcopyExe% %fastcopyMode% /cmd=diff "%pythonDir%\python35.dll" /to="%finalDir%\etc"
	) else if exist "%pythonDir%\python36.dll" (
		%fastcopyExe% %fastcopyMode% /cmd=diff "%pythonDir%\python36.dll" /to="%finalDir%\etc"
	)
	REM Pythonコピー
	%fastcopyExe% %fastcopyMode% /cmd=diff /exclude="*.dll" "install\python" /to="%finalDir%\python"
	for /f "delims=" %%f in ( 'dir "%finalDir%\python\caffe" /a-D /B ^| findstr ".*pyd$"' ) do set origFile=%%f
	set newFile=!origFile:caffe_static=caffe!
	ren "%finalDir%\python\caffe\!origFile!" "!newFile!"
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
