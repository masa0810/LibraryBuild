@echo off
setlocal

rem ライブラリパス
set boostDir=boost_1_64_0
set bzipDir=bzip2-1.0.6
set zlibDir=zlib-1.2.11
set anacondaDir=D:\Anaconda3

rem バージョン設定
set boostVersion=1.64
set pythonVersion=3.5

rem 並列ビルド数
set numOfParallel=%NUMBER_OF_PROCESSORS%

rem 引数解析
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

rem ビルド条件表示
echo build type : %buildType%
echo avx type : %avxType%

rem 現在のパスの保持
for /f "delims=" %%f in ( 'cd' ) do set currentPath=%%f

rem バッチファイルの場所
set batchPath=%~dp0

rem ソース置き場
cd /d "%batchPath%..\..\"
for /f "delims=" %%f in ( 'cd' ) do set sourceDir=%%f
cd /d "%currentPath%"

rem boostパス
set boostPath=%sourceDir%\%boostDir%
rem boostパス表示
echo Boost : %boostPath%

rem bzipパス
set bzipPath=%sourceDir%\%bzipDir%
rem bzipパス表示
echo bzip : %bzipPath%

rem zlibパス
set zlibPath=%sourceDir%\%zlibDir%
rem zlibパス表示
echo zlib : %zlibPath%

rem アドレスモデル切り替え
if /%Platform%==/ (
	set addmodel=86
	set platformName=Win32
) else (
	set addmodel=64
	set platformName=x64
)

rem Visual Studioバージョン切り替え
if /%VisualStudioVersion%==/11.0 (
	set vsVersion=vs2012
	set vcVersion=110
	set toolsetName=msvc-11.0
) else if /%VisualStudioVersion%==/12.0 (
	set vsVersion=vs2013
	set vcVersion=120
	set toolsetName=msvc-12.0
) else if /%VisualStudioVersion%==/14.0 (
	set vsVersion=vs2015
	set vcVersion=140
	set toolsetName=msvc-14.0
) else if /%VisualStudioVersion%==/15.0 (
	set vsVersion=vs2017
	set vcVersion=141
	set toolsetName=msvc-14.1
) else (
	set vsVersion=vs2010
	set vcVersion=100
	set toolsetName=msvc-10.0
)

rem ビルドディレクトリ
set buildDir=%batchPath%Build_%vsVersion%_%platformName%

rem インストールディレクトリ
set finalDir=%sourceDir%\Final\v%vcVersion%\Boost
rem インストールディレクトリ表示
echo install : %finalDir%

rem Boostディレクトリに移動
cd /d "%boostPath%"

rem b2ファイル作成
set anacondaPath=%anacondaDir:\=\\%
if not exist b2.exe (
	rem バッチ実行
	call bootstrap.bat
	rem python設定
	echo using python : %pythonVersion% : %anacondaPath% : %anacondaPath%\\include : %anacondaPath%\\libs ; >> project-config.jam
)

rem 引数作成
if /%avxType%==/Enable (
	set instructionOptionOrig=""
) else (
	set instructionOptionOrig="instruction-set=nehalem"
)
set instructionOption=%instructionOptionOrig:"=%

rem ビルド
b2.exe ^
%buildType% ^
toolset=%toolsetName% ^
address-model=%addmodel% ^
link=static,shared ^
runtime-link=shared ^
threading=multi ^
variant=release,debug ^
debug-symbols=on ^
-j%numOfParallel% ^
-sBZIP2_SOURCE="%bzippath%" ^
-sZLIB_SOURCE="%zlibpath%" ^
--build-dir="%buildDir%"
--prefix="%finalDir%" ^
--stagedir="%finalDir%" ^
--build-type=complete ^
--without-mpi %instructionOption%
call :ErrorCheck

rem インストール
if /%buildType%==/install (
	rem includeフォルダ確認
	if exist "%finalDir%\include\boost" (
		rd /S /Q "%finalDir%\include\boost"
	)

	rem includeフォルダ整形
	for /f %%d in ( 'dir /a:D /B "%finalDir%\include"' ) do (
		move "%finalDir%\include\%%d\boost" "%finalDir%\include\boost"
		rd "%finalDir%\include\%%d"
	)

	rem binフォルダ作成
	if exist "%finalDir%\bin\%platformName%" (
		rd /S /Q "%finalDir%\bin\%platformName%"
	)
	mkdir "%finalDir%\bin\%platformName%"

	rem dll移動
	for /f "delims=" %%f in ( 'dir "%finalDir%\lib" /a-D /B /S ^| findstr "boost[^\\]*%vcVersion%[^\\]*dll$"' ) do (
		move "%%f" "%finalDir%\bin\%platformName%"
	)

	rem libフォルダ作成
	if exist "%finalDir%\lib\%platformName%" (
		rd /S /Q "%finalDir%\lib\%platformName%"
	)
	mkdir "%finalDir%\lib\%platformName%"

	rem lib移動
	for /f "delims=" %%f in ( 'dir "%finalDir%\lib" /a-D /B /S ^| findstr ".*%vcVersion%[^\\]*lib$"' ) do (
		move "%%f" "%finalDir%\lib\%platformName%"
	)

	rem pdbコピー
	for /f "delims=" %%f in ( 'dir "%boostPath%" /a-D /B /S ^| findstr "boost[^\\]*%vcVersion%[^\\]*pdb$"' ) do (
		copy "%%f" "%finalDir%\bin\%platformName%"
	)

	rem バージョン番号ファイル追加
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
