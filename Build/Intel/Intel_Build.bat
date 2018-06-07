@echo off
setlocal

REM FastCopy
set fastcopyPath=FastCopy341_x64\FastCopy.exe

REM FastCopyモード
set fastcopyMode=/force_close

REM ビルドバッファ
set buildBuf=C:\Library\Temp

REM ライブラリパス
set intelLibraryDirOrig="C:\Program Files (x86)\IntelSWTools\compilers_and_libraries\windows"
set intelLibraryDir=%intelLibraryDirOrig:"=%

REM バージョン設定
set intelVersion=2018Update3

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

REM アドレスモデル切り替え
if /%Platform%==/ (
	set platformName=Win32
	set platformNameIntel=ia32
) else (
	set platformName=x64
	set platformNameIntel=intel64
)

REM Visual Studioバージョン切り替え
if /%VisualStudioVersion%==/11.0 (
	set vcVersion=110
	set vcVersionIntel=vc11
) else if /%VisualStudioVersion%==/12.0 (
	set vcVersion=120
	set vcVersionIntel=vc12
) else if /%VisualStudioVersion%==/14.0 (
	set vcVersion=140
	set vcVersionIntel=vc14
) else if /%VisualStudioVersion%==/15.0 (
	set vcVersion=141
	REM set vcVersionIntel=vc141
	set vcVersionIntel=vc14
) else (
	set vcVersion=100
	set vcVersionIntel=vc10
)

REM インストールディレクトリ
set ippFinalDir=%buildBuf%\Final\IPP
REM インストールディレクトリ表示
echo install : %ippFinalDir%

REM インストールディレクトリ削除
if exist "%ippFinalDir%" (
	rd /S /Q "%ippFinalDir%"
)

REM includeコピー
%fastcopyExe% %fastcopyMode% /cmd=diff "%intelLibraryDir%\ipp\include" /to="%ippFinalDir%\"

REM libコピー
%fastcopyExe% %fastcopyMode% /cmd=diff "%intelLibraryDir%\ipp\lib\%platformNameIntel%\*" /to="%ippFinalDir%\lib\%platformName%\"

REM binコピー
%fastcopyExe% %fastcopyMode% /cmd=diff "%intelLibraryDir%\redist\%platformNameIntel%\ipp\*" /to="%ippFinalDir%\bin\%platformName%\"

REM バージョン番号ファイル追加
type nul > %ippFinalDir%\IPP_%intelVersion%

REM インストールディレクトリ
set mklFinalDir=%buildBuf%\Final\MKL
REM インストールディレクトリ表示
echo install : %mklFinalDir%

REM インストールディレクトリ削除
if exist "%mklFinalDir%" (
	rd /S /Q "%mklFinalDir%"
)

REM includeコピー
%fastcopyExe% %fastcopyMode% /cmd=diff "%intelLibraryDir%\mkl\include" /to="%mklFinalDir%\"

REM libコピー
%fastcopyExe% %fastcopyMode% /cmd=diff "%intelLibraryDir%\mkl\lib\%platformNameIntel%\*" /to="%mklFinalDir%\lib\%platformName%\"

REM binコピー
%fastcopyExe% %fastcopyMode% /cmd=diff "%intelLibraryDir%\redist\%platformNameIntel%\mkl\*" /to="%mklFinalDir%\bin\%platformName%\"

REM バージョン番号ファイル追加
type nul > %mklFinalDir%\MKL_%intelVersion%

REM インストールディレクトリ
set tbbFinalDir=%buildBuf%\Final\v%vcVersion%\TBB
REM インストールディレクトリ表示
echo install : %tbbFinalDir%

REM インストールディレクトリ削除
if exist "%tbbFinalDir%" (
	rd /S /Q "%tbbFinalDir%"
)

REM includeコピー
%fastcopyExe% %fastcopyMode% /cmd=diff /exclude="*.html" "%intelLibraryDir%\tbb\include" /to="%tbbFinalDir%\"

REM libコピー
%fastcopyExe% %fastcopyMode% /cmd=diff /exclude="*.def;*.pdb" "%intelLibraryDir%\tbb\lib\%platformNameIntel%\%vcVersionIntel%" /to="%tbbFinalDir%\lib\%platformName%"

REM binコピー
%fastcopyExe% %fastcopyMode% /cmd=diff "%intelLibraryDir%\redist\%platformNameIntel%\tbb\%vcVersionIntel%" /to="%tbbFinalDir%\bin\%platformName%"

REM セットヘッダのコピー
%fastcopyExe% %fastcopyMode% /cmd=diff "%batchPath%\files\tbbset.h" /to="%tbbFinalDir%\include\"

REM Copyバッチのコピー
%fastcopyExe% %fastcopyMode% /cmd=diff "%batchPath%\files\TbbCopy.bat" /to="%tbbFinalDir%\"

REM バージョン番号ファイル追加
type nul > %tbbFinalDir%\TBB_%intelVersion%

endlocal
