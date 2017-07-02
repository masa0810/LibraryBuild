@echo off
setlocal

rem FastCopy
set fastcopyPath=FastCopy330_x64\FastCopy.exe

rem FastCopyモード
set fastcopyMode=/force_close
rem set fastcopyMode=

rem ライブラリパス
set openBlasDir=OpenBLAS-v0.2.19-Win64-int32
set minGw64Dir=mingw64_dll
set minGw32Dir=mingw32_dll

rem バージョン設定
set openBlasVersion=0.2.19

rem プラットフォーム指定
if /%1==/Win32 (
	set Platform=
) else (
	set Platform=x64
)

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

rem OpenBLASパス
set openBlasPath=%sourceDir%\%openBlasDir%
rem OpenBLASパス表示
echo OpenBLAS : %openBlasPath%

rem アドレスモデル切り替え
if /%Platform%==/ (
	set platformName=Win32
	rem MinGWパス
	set minGwPath=%sourceDir%\%minGw32Dir%
) else (
	set platformName=x64
	rem MinGWパス
	set minGwPath=%sourceDir%\%minGw64Dir%
)

rem MinGWパス表示
echo MinGW : %minGwPath%

rem インストールディレクトリ
set finalDir=%sourceDir%\Final\OpenBLAS

rem インストールディレクトリ表示
echo install : %finalDir%

rem インストールディレクトリ削除
if exist "%finalDir%" (
	rd /S /Q "%finalDir%"
)

rem includeディレクトリコピー
%fastcopyExe% %fastcopyMode% /cmd=diff "%openBlasPath%\include" /to="%finalDir%\"

rem libファイルコピー
%fastcopyExe% %fastcopyMode% /cmd=diff "%openBlasPath%\lib\libopenblas.dll.a" /to="%finalDir%\lib\%platformName%"
ren "%finalDir%\lib\%platformName%\libopenblas.dll.a" libopenblas.lib

rem binファイルコピー
%fastcopyExe% %fastcopyMode% /cmd=diff "%openBlasPath%\bin\libopenblas.dll" /to="%finalDir%\bin\%platformName%"

rem MinGWコピー
%fastcopyExe% %fastcopyMode% /cmd=diff "%minGwPath%" /to="%finalDir%\bin\%platformName%"

rem セットヘッダのコピー
%fastcopyExe% %fastcopyMode% /cmd=diff "%batchPath%\files\openblasset.h" /to="%finalDir%\include\"

rem Copyバッチのコピー
%fastcopyExe% %fastcopyMode% /cmd=diff "%batchPath%\files\OpenBlasCopy.bat" /to="%finalDir%\"

rem cmakeディレクトリのコピー
%fastcopyExe% %fastcopyMode% /cmd=diff "%batchPath%\cmake" /to="%finalDir%\"

rem バージョン番号ファイル追加
type nul > %finalDir%\OpenBLAS_%openBlasVersion%

endlocal
