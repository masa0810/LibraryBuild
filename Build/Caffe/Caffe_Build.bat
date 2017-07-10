@echo off
setlocal

rem FastCopy
set fastcopyPath=FastCopy330_x64\FastCopy.exe

rem FastCopyモード
set fastcopyMode=/force_close

rem ninja
set ninjaPath=ninja-1.7.2\ninja.exe

rem Anacondaパス
set anacondaDir=D:\Anaconda3

rem バージョン設定
set caffeVersion=1.0.0

rem 並列ビルド数
set numOfParallel=%NUMBER_OF_PROCESSORS%

rem 引数解析
if /%1==/install (
	set buildType=install
) else (
	set buildType=
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
set finalDir=%sourceDir%\Final\v%vcVersion%\Caffe

rem ビルドディレクトリ確認
rem if not exist "%buildDir%" (
	rem Configuration実行
	call %batchPath%Caffe_Configuration.bat %1 %2
rem )

rem ビルドディレクトリへ移動
cd /d "%buildDir%"
%ninjaExe% %buildType% -j %numOfParallel%
call :ErrorCheck

rem インストール
if /%buildType%==/install (
	rem インストールディレクトリ表示
	echo install : %finalDir%

	rem includeディレクトリコピー
	%fastcopyExe% %fastcopyMode% /cmd=diff "install\include" /to="%finalDir%\"

	rem bin&libファイルコピー
	if /%linkType%==/Shared (
		call :Shared
	) else (
		call :Static
	)

	rem セットヘッダのコピー
	%fastcopyExe% %fastcopyMode% /cmd=diff "%batchPath%\files\caffeset.h" /to="%finalDir%\include\"

	rem Copyバッチのコピー
	%fastcopyExe% %fastcopyMode% /cmd=diff "%batchPath%\files\CaffeCopy.bat" /to="%finalDir%\"

	rem バージョン番号ファイル追加
	type nul > %finalDir%\Caffe_%caffeVersion%
)

exit /b

goto :EOF

:Shared

rem binディレクトリコピー
%fastcopyExe% %fastcopyMode% /cmd=diff /include="caffe*.dll;python*.dll" "install\bin" /to="%finalDir%\bin\%platformName%"

rem libディレクトリコピー
%fastcopyExe% %fastcopyMode% /cmd=diff /include="*.lib" /exclude="caffeproto*.lib" "install\lib" /to="%finalDir%\lib\%platformName%"

exit /b

goto :EOF

:Static

rem libディレクトリコピー
%fastcopyExe% %fastcopyMode% /cmd=diff /include="*.lib" "install\lib" /to="%finalDir%\lib\%platformName%\static"

rem PythonLibのコピー
%fastcopyExe% %fastcopyMode% /cmd=diff /include="python*.lib" /exclude="python3.lib"  "%anacondaDir%\libs" /to="%finalDir%\lib\%platformName%"

if /%configType%==/Release (
	rem Caffe.exeコピー
	%fastcopyExe% %fastcopyMode% /cmd=diff /include="*.exe;python*.dll" "install\bin" /to="%finalDir%\etc"
	rem Pythonコピー
	%fastcopyExe% %fastcopyMode% /cmd=diff /exclude="*.dll" "install\python" /to="%finalDir%\python"
	rem 依存DLLのコピー
	%fastcopyExe% %fastcopyMode% /cmd=diff "%finalDir%\..\..\CUDA\bin\cublas64_*.dll" /to="%finalDir%\etc"
	%fastcopyExe% %fastcopyMode% /cmd=diff "%finalDir%\..\..\CUDA\bin\cublas64_*.dll" /to="%finalDir%\python\caffe"
	%fastcopyExe% %fastcopyMode% /cmd=diff "%finalDir%\..\..\CUDA\bin\cudart64_*.dll" /to="%finalDir%\etc"
	%fastcopyExe% %fastcopyMode% /cmd=diff "%finalDir%\..\..\CUDA\bin\cudart64_*.dll" /to="%finalDir%\python\caffe"
	%fastcopyExe% %fastcopyMode% /cmd=diff "%finalDir%\..\..\CUDA\bin\curand64_*.dll" /to="%finalDir%\etc"
	%fastcopyExe% %fastcopyMode% /cmd=diff "%finalDir%\..\..\CUDA\bin\curand64_*.dll" /to="%finalDir%\python\caffe"
	%fastcopyExe% %fastcopyMode% /cmd=diff "%finalDir%\..\..\CUDA\bin\cudnn64_*.dll" /to="%finalDir%\etc"
	%fastcopyExe% %fastcopyMode% /cmd=diff "%finalDir%\..\..\CUDA\bin\cudnn64_*.dll" /to="%finalDir%\python\caffe"
	%fastcopyExe% %fastcopyMode% /cmd=diff "%finalDir%\..\..\OpenBLAS\bin\%platformName%\lib*.dll" /to="%finalDir%\etc"
	%fastcopyExe% %fastcopyMode% /cmd=diff "%finalDir%\..\..\OpenBLAS\bin\%platformName%\lib*.dll" /to="%finalDir%\python\caffe"
	%fastcopyExe% %fastcopyMode% /cmd=diff "%finalDir%\..\OpenCV\bin\%platformName%\opencv_ffmpeg*.dll" /to="%finalDir%\etc"
	%fastcopyExe% %fastcopyMode% /cmd=diff "%finalDir%\..\OpenCV\bin\%platformName%\opencv_ffmpeg*.dll" /to="%finalDir%\python\caffe"
	%fastcopyExe% %fastcopyMode% /cmd=diff "%finalDir%\..\TBB\bin\%platformName%\tbb.dll" /to="%finalDir%\etc"
	%fastcopyExe% %fastcopyMode% /cmd=diff "%finalDir%\..\TBB\bin\%platformName%\tbb.dll" /to="%finalDir%\python\caffe"
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
