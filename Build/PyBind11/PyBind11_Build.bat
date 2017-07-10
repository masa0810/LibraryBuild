@echo off
setlocal

rem FastCopy
set fastcopyPath=FastCopy330_x64\FastCopy.exe

rem FastCopyモード
set fastcopyMode=/force_close

rem ライブラリパス
set pybind11Dir=pybind11-2.1.1

rem バージョン設定
set pybind11Version=2.1.1

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

rem PyBind11パス
set pybind11Path=%sourceDir%\%pybind11Dir%
rem PyBind11パス表示
echo PyBind11 : %pybind11Path%

rem インストールディレクトリ
set finalDir=%sourceDir%\Final\PyBind11

rem インストールディレクトリ表示
echo install : %finalDir%

rem インストールディレクトリ削除
if exist "%finalDir%" (
	rd /S /Q "%finalDir%"
)

rem PyBind11ディレクトリコピー
%fastcopyExe% %fastcopyMode% /cmd=diff "%pybind11Path%\include" /to="%finalDir%\"

rem バージョン番号ファイル追加
type nul > %finalDir%\PyBind11_%pybind11Version%

endlocal
