@echo off
setlocal enabledelayedexpansion

REM FastCopy
set fastcopyPath="C:\Program Files\FastCopy\FastCopy.exe"

REM FastCopyモード
set fastcopyMode=/force_close

REM ninja
set ninjaPath="E:\Shared\Software\Ninja\ninja.exe"

REM ビルドバッファ
set buildBuf=C:\Library\Temp

REM バージョン設定
set openCvVersion=3.4.2

REM 並列ビルド数
set numOfParallel=%NUMBER_OF_PROCESSORS%

REM 引数解析
if /%1==/install (
	set buildType=install
	if /%2==/avx (
		set flagAvx=avx
	) else (
		set flagAvx=
	)
) else if /%1==/avx (
	set flagAvx=avx
	if /%2==/install (
		set buildType=install
	) else (
		set buildType=
	)
) else (
	set buildType=
	set flagAvx=
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

REM CUDAパス
set cudaPath=%sourceDir%\CUDA
REM CUDAパス表示
echo CUDA : %cudaPath%

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
call %batchPath%OpenCV_Configuration.bat %1 %2 %flagAvx%

REM ビルドディレクトリ
set buildDir=%buildBuf%\%vsVersion%\%platformName%\%configType%\%linkType%\OpenCV

REM ビルドディレクトリ表示
echo build directory : %buildDir%

REM CUDAパス再設定(※ Configurationよりも後でやる)
if not /"%cudaPath%"==/"%CUDA_PATH%" (
	set CUDA_PATH=%cudaPath%
)

REM ビルドディレクトリへ移動
cd /d "%buildDir%"
%ninjaExe% %buildType% -j %numOfParallel%
call :ErrorCheck

REM インストールディレクトリ
set finalDir=%buildBuf%\Final\v%vcVersion%\OpenCV

REM インストール
if /%buildType%==/install (
	REM インストールディレクトリ表示
	echo install : %finalDir%

	REM includeディレクトリコピー
	%fastcopyExe% %fastcopyMode% /cmd=diff /exclude="cvconfig.h" "install\include" /to="%finalDir%\"

	REM 個別ファイルコピー
	%fastcopyExe% %fastcopyMode% /cmd=diff "install\include\opencv2\cvconfig.h" /to="%finalDir%\include"

	REM 個別ファイルリネーム
	if exist "%finalDir%\include\cvconfig_%platformName%_%linkType%_%configType%.h" (
		del "%finalDir%\include\cvconfig_%platformName%_%linkType%_%configType%.h"
	)
	ren "%finalDir%\include\cvconfig.h" cvconfig_%platformName%_%linkType%_%configType%.h

	REM bin&libファイルコピー
	if /%linkType%==/Shared (
		call :Shared
	) else (
		call :Static
	)

	REM セットヘッダのコピー
	%fastcopyExe% %fastcopyMode% /cmd=diff "%batchPath%\files\opencvset.h" /to="%finalDir%\include\"

	REM Copyバッチのコピー
	%fastcopyExe% %fastcopyMode% /cmd=diff "%batchPath%\files\OpenCvCopy.bat" /to="%finalDir%\"

	REM バージョン番号ファイル追加
	type nul > %finalDir%\OpenCV_%openCvVersion%
)

exit /b

goto :EOF

:Shared

REM binディレクトリコピー
%fastcopyExe% %fastcopyMode% /cmd=diff /include="*.dll;*.pdb" /exclude="opencv_waldboost_detector*" "bin" /to="%finalDir%\bin\%platformName%"

REM libディレクトリコピー
%fastcopyExe% %fastcopyMode% /cmd=diff /include="opencv_*.lib" "lib" /to="%finalDir%\lib\%platformName%"

exit /b

goto :EOF

:Static

REM binディレクトリコピー
%fastcopyExe% %fastcopyMode% /cmd=diff /include="*.dll" "bin" /to="%finalDir%\bin\%platformName%"

REM libディレクトリコピー
%fastcopyExe% %fastcopyMode% /cmd=diff /include="opencv_*.lib;opencv_*.pdb" /exclude="opencv_python3*" "lib" /to="%finalDir%\lib\%platformName%"

REM 3rdpartyライブラリコピー
%fastcopyExe% %fastcopyMode% /cmd=diff /include="*.lib;*.pdb" "3rdparty\lib" /to="%finalDir%\lib\%platformName%"
%fastcopyExe% %fastcopyMode% /cmd=diff "3rdparty\ippicv\ippicv_win\lib\intel64\ippicvmt.lib" /to="%finalDir%\lib\%platformName%\"

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
