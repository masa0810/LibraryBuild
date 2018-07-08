@echo off
setlocal

REM FastCopy
set fastcopyPath="C:\Program Files\FastCopy\FastCopy.exe"

REM FastCopyモード
set fastcopyMode=/force_close

REM ビルドバッファ
set buildBuf=C:\Library\Temp

REM ライブラリパス
set intelLibraryDirOrig="C:\Program Files (x86)\IntelSWTools\compilers_and_libraries\windows"
set intelLibraryDir=%intelLibraryDirOrig:"=%

REM バージョン設定
set ippVersion=2018Update3
set mklVersion=2018Update3

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

REM アドレスモデル切り替え
if /%Platform%==/ (
	set platformName=Win32
	set platformNameIntel=ia32
) else (
	set platformName=x64
	set platformNameIntel=intel64
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
type nul > %ippFinalDir%\IPP_%ippVersion%

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
type nul > %mklFinalDir%\MKL_%mklVersion%

endlocal
