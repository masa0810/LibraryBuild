@echo off
setlocal

REM FastCopy
set fastcopyPath="C:\Program Files\FastCopy\FastCopy.exe"

REM FastCopyモード
set fastcopyMode=/force_close

REM ビルドバッファ
set buildBuf=C:\Library\Temp

REM ライブラリパス
set boostDir=boost
set pythonDir=C:\Library\Python

REM バージョン設定
set boostVersion=1.68
set pythonVersion=3.6

REM 並列ビルド数
set numOfParallel=%NUMBER_OF_PROCESSORS%

REM 引数解析
if /%1==/install (
	set buildType=install
	if /%2==/avx (
		set avxType=Enable
	) else (
		set avxType=Disable
	)
) else if /%1==/avx (
	set avxType=Enable
	if /%2==/install (
		set buildType=install
	) else (
		set buildType=stage
	)
) else (
	set buildType=stage
	set avxType=Disable
)

REM ビルド条件表示
echo build type : %buildType%
echo avx type : %avxType%

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

REM boostパス
set boostPath=%sourceDir%\%boostDir%
REM boostパス表示
echo Boost : %boostPath%

REM アドレスモデル切り替え
if /%Platform%==/ (
	set addmodel=86
	set platformName=Win32
) else (
	set addmodel=64
	set platformName=x64
)

REM Visual Studioバージョン切り替え
if /%VisualStudioVersion%==/11.0 (
	set vsVersion=vs2012
	set vcVersion=110
	set toolsetName=msvc-11.0
	set cppver=
) else if /%VisualStudioVersion%==/12.0 (
	set vsVersion=vs2013
	set vcVersion=120
	set toolsetName=msvc-12.0
	set cppver=
) else if /%VisualStudioVersion%==/14.0 (
	set vsVersion=vs2015
	set vcVersion=140
	set toolsetName=msvc-14.0
	set cppver="/std:c++14"
) else if /%VisualStudioVersion%==/15.0 (
	set vsVersion=vs2017
	set vcVersion=141
	set toolsetName=msvc-14.1
	set cppver="/std:c++17"
) else (
	set vsVersion=vs2010
	set vcVersion=100
	set toolsetName=msvc-10.0
	set cppver
)

REM ビルドディレクトリ
set buildPath=%buildBuf%\%vsVersion%\%platformName%\Boost
set buildDir=%buildPath%\Tmp
set stageDir=%buildPath%\Stage

REM Boostディレクトリに移動
cd /d "%boostPath%"

REM b2ファイル作成
set pythonPath=%pythonDir:\=\\%
if not exist b2.exe (
	REM バッチ実行
	call bootstrap.bat
	REM python設定
	echo using python : %pythonVersion% : %pythonPath% : %pythonPath%\\include : %pythonPath%\\libs ; >> project-config.jam
)

REM 引数作成
if /%avxType%==/Enable (
	REM set instructionOptionOrig="instruction-set=sandy-bridge"
	set instructionOptionOrig=""
	echo Enable AVX
) else (
	set instructionOptionOrig="instruction-set=nehalem"
)
set instructionOption=%instructionOptionOrig:"=%

REM ビルド
b2.exe ^
%buildType% ^
toolset=%toolsetName% ^
address-model=%addmodel% ^
link=static,shared ^
runtime-link=shared ^
threading=multi ^
variant=release,debug ^
embed-manifest=off ^
debug-symbols=on ^
cxxflags=%cppver% ^
-j%numOfParallel% ^
--build-dir="%buildDir%" ^
--prefix="%stageDir%" ^
--stagedir="%stageDir%" ^
--build-type=complete ^
--without-mpi %instructionOption%
call :ErrorCheck

REM インストールディレクトリ
set finalDir=%buildBuf%\Final\v%vcVersion%\Boost

REM インストール
if /%buildType%==/install (
	REM インストールディレクトリ表示
	echo install : %finalDir%

	REM includeディレクトリコピー
	for /f %%d in ( 'dir /a:D /B "%stageDir%\include"' ) do (
		%fastcopyExe% %fastcopyMode% /cmd=diff "%stageDir%\include\%%d" /to="%finalDir%\include"
	)

	REM dllコピー
	%fastcopyExe% %fastcopyMode% /cmd=diff /include="*.dll" "%stageDir%\lib" /to="%finalDir%\bin\%platformName%"

	REM libコピー
	%fastcopyExe% %fastcopyMode% /cmd=diff /include="*.lib" "%stageDir%\lib" /to="%finalDir%\lib\%platformName%"

	REM pdbコピー
	for /f "delims=" %%f in ( 'dir "%buildDir%" /a-D /B /S ^| findstr "boost[^\\]*%vcVersion%[^\\]*pdb$"' ) do (
		copy "%%f" "%finalDir%\bin\%platformName%"
	)

	REM バージョン番号ファイル追加
	type nul > %finalDir%\Boost_%boostVersion%
)

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
