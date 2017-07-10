@echo off
setlocal

rem FastCopy
set fastcopyPath=FastCopy330_x64\FastCopy.exe

rem FastCopyモード
set fastcopyMode=/force_close

rem ninja
set ninjaPath=ninja-1.7.2\ninja.exe

rem バージョン設定
set openCvVersion=3.2.0

rem 並列ビルド数
set numOfParallel=%NUMBER_OF_PROCESSORS%

rem 引数解析
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

rem ビルド条件表示
echo build type : %buildType%

rem 現在のパスの保持
for /f "delims=" %%f in ( 'cd' ) do set currentPath=%%f

rem バッチファイルの場所
set batchPath=%~dp0

rem ソース置き場
cd /d "%batchPath%..\..\"
for /f "delims=" %%f in ( 'cd' ) do set sourceDir=%%f
cd /d "%currentPath%"

rem FastCopyパス作成
set fastcopyExe="%sourceDir%\Build\Tools\%fastcopyPath%"
rem FastCopyパス表示
echo FastCopy : %fastcopyExe%

rem Ninja
set ninjaExe="%sourceDir%\%ninjaPath%"
rem Ninjaパス表示
echo Ninja : %ninjaExe%

rem Ninjaファイルチェック
call "%sourceDir%\Build\Ninja\Ninja_Build.bat"

rem CUDAパス
set cudaPath=%sourceDir%\CUDA
rem CUDAパス表示
echo CUDA : %cudaPath%

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

echo Static Release
cd /d %batchPath%
call :Main static release
echo Shared Release
cd /d %batchPath%
call :Main shared release
echo Static Debug
cd /d %batchPath%
call :Main static debug
echo Shared Debug
cd /d %batchPath%
call :Main shared debug

goto :EOF

:Main

rem Staticビルド/Dynamicビルド切り替え
if /%1==/shared (
    set linkType=Shared
) else (
    set linkType=Static
)

rem Release/Debug切り替え
if /%2==/debug (
    set configType=Debug
) else (
    set configType=Release
)

rem ビルドディレクトリ
set buildDir=%batchPath%Build_%vsVersion%_%platformName%_%linkType%_%configType%

rem ビルドディレクトリ表示
echo build directory : %buildDir%

rem インストールディレクトリ
set finalDir=%sourceDir%\Final\v%vcVersion%\OpenCV

rem ビルドディレクトリ確認
rem if not exist "%buildDir%" (
	rem Configuration実行
	call %batchPath%OpenCV_Configuration.bat %1 %2 %flagAvx%
rem )

rem CUDAパス再設定(※ Configurationよりも後でやる)
if not /"%cudaPath%"==/"%CUDA_PATH%" (
	set CUDA_PATH=%cudaPath%
)

rem ビルドディレクトリへ移動
cd /d "%buildDir%"
%ninjaExe% %buildType% -j %numOfParallel%
call :ErrorCheck

rem インストール
if /%buildType%==/install (
	rem インストールディレクトリ表示
	echo install : %finalDir%

	rem includeディレクトリコピー
	%fastcopyExe% %fastcopyMode% /cmd=diff /exclude="cvconfig.h" "install\include" /to="%finalDir%\"
	rem cmakeディレクトリのコピー
	%fastcopyExe% %fastcopyMode% /cmd=diff "%batchPath%\cmake" /to="%finalDir%\"

	rem 個別ファイルコピー
	%fastcopyExe% %fastcopyMode% /cmd=diff "install\include\opencv2\cvconfig.h" /to="%finalDir%\include"

	rem 個別ファイルリネーム
	if exist "%finalDir%\include\cvconfig_%platformName%_%linkType%_%configType%.h" (
		del "%finalDir%\include\cvconfig_%platformName%_%linkType%_%configType%.h"
	)
	ren "%finalDir%\include\cvconfig.h" cvconfig_%platformName%_%linkType%_%configType%.h

	rem bin&libファイルコピー
	if /%linkType%==/Shared (
		call :Shared
	) else (
		call :Static
	)

	rem セットヘッダのコピー
	%fastcopyExe% %fastcopyMode% /cmd=diff "%batchPath%\files\opencvset.h" /to="%finalDir%\include\"

	rem Copyバッチのコピー
	%fastcopyExe% %fastcopyMode% /cmd=diff "%batchPath%\files\OpenCvCopy.bat" /to="%finalDir%\"

	rem バージョン番号ファイル追加
	type nul > %finalDir%\OpenCV_%openCvVersion%
)

exit /b

goto :EOF

:Shared

rem binディレクトリコピー
%fastcopyExe% %fastcopyMode% /cmd=diff /include="*.dll;*.pdb" /exclude="opencv_waldboost_detector*" "bin" /to="%finalDir%\bin\%platformName%"

rem libディレクトリコピー
%fastcopyExe% %fastcopyMode% /cmd=diff /include="opencv_*.lib" "lib" /to="%finalDir%\lib\%platformName%"

exit /b

goto :EOF

:Static

rem binディレクトリコピー
%fastcopyExe% %fastcopyMode% /cmd=diff /include="*.dll" "bin" /to="%finalDir%\bin\%platformName%"

rem libディレクトリコピー
%fastcopyExe% %fastcopyMode% /cmd=diff /include="opencv_*.lib;opencv_*.pdb" /exclude="opencv_python3*" "lib" /to="%finalDir%\lib\%platformName%\static"

rem 3rdpartyライブラリコピー
%fastcopyExe% %fastcopyMode% /cmd=diff /include="*.lib;*.pdb" "3rdparty\lib" /to="%finalDir%\lib\%platformName%\static"
%fastcopyExe% %fastcopyMode% /cmd=diff "3rdparty\ippicv\ippicv_win\lib\intel64\ippicvmt.lib" /to="%finalDir%\lib\%platformName%\static"

rem Python3コピー
if /%configType%==/Release (
	%fastcopyExe% %fastcopyMode% /cmd=diff "lib\python3" /to="%finalDir%\Python3"
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
