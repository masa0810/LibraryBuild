@echo off
setlocal

rem FastCopy
set fastcopyPath=FastCopy330_x64\FastCopy.exe

rem FastCopyモード
set fastcopyMode=/force_close

rem ライブラリパス
set fmtDir=fmt-4.0.0

rem バージョン設定
set fmtVersion=4.0.0

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

rem Fmtパス
set fmtPath=%sourceDir%\%fmtDir%
rem Fmtパス表示
echo FMT : %fmtPath%

rem インストールディレクトリ
set finalDir=%sourceDir%\Final\Fmt

rem インストールディレクトリ表示
echo install : %finalDir%

rem インストールディレクトリ削除
if exist "%finalDir%" (
	rd /S /Q "%finalDir%"
)

rem Fmtディレクトリコピー
%fastcopyExe% %fastcopyMode% /cmd=diff /exclude="*.txt" "%fmtPath%\fmt" /to="%finalDir%\include\"

rem セットヘッダのコピー
%fastcopyExe% %fastcopyMode% /cmd=diff "%batchPath%\files\fmtset.h" /to="%finalDir%\include\"

rem バージョン番号ファイル追加
type nul > %finalDir%\%fmtVersion%

endlocal
