@echo off
setlocal

rem FastCopy
set fastcopyPath=FastCopy330_x64\FastCopy.exe

rem FastCopyモード
set fastcopyMode=/force_close

rem ninja
set ninjaPath=ninja-1.7.2\ninja.exe

rem バージョン設定
set gflagsVersion=2.2.0

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

echo Release
cd /d %batchPath%
call :Main release
echo Debug
cd /d %batchPath%
call :Main debug

goto :EOF

:Main

rem Release/Debug切り替え
if /%1==/debug (
    set configType=Debug
) else (
    set configType=Release
)

rem ビルドディレクトリ
set buildDir=%batchPath%Build_%vsVersion%_%platformName%_%configType%

rem ビルドディレクトリ表示
echo build directory : %buildDir%

rem インストールディレクトリ
set finalDir=%sourceDir%\Final\v%vcVersion%\gflags

rem ビルドディレクトリ確認
rem if not exist "%buildDir%" (
	rem Configuration実行
	call %batchPath%gflags_Configuration.bat %1
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
	rem cmakeディレクトリのコピー
	%fastcopyExe% %fastcopyMode% /cmd=diff "%batchPath%\cmake" /to="%finalDir%\"

	rem binディレクトリコピー
	%fastcopyExe% %fastcopyMode% /cmd=diff /include="gflags*.dll;gflags*.pdb" "bin" /to="%finalDir%\bin\%platformName%"

	rem libディレクトリコピー
	%fastcopyExe% %fastcopyMode% /cmd=diff /include="*gflags*.lib" "lib" /to="%finalDir%\lib\%platformName%"

	rem バージョン番号ファイル追加
	type nul > %finalDir%\gflags_%gflagsVersion%
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
