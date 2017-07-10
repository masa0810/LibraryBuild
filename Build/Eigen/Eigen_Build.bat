@echo off
setlocal

rem FastCopy
set fastcopyPath=FastCopy330_x64\FastCopy.exe

rem FastCopyモード
set fastcopyMode=/force_close

rem ライブラリパス
set eigenDir=eigen-eigen-5a0156e40feb

rem バージョン設定
set eigenVersion=3.3.4

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

rem Eigenパス
set eigenPath=%sourceDir%\%eigenDir%
rem Eigenパス表示
echo Eigen : %eigenPath%

rem インストールディレクトリ
set finalDir=%sourceDir%\Final\Eigen

rem インストールディレクトリ表示
echo install : %finalDir%

rem インストールディレクトリ削除
if exist "%finalDir%" (
	rd /S /Q "%finalDir%"
)

rem Eigenディレクトリコピー
%fastcopyExe% %fastcopyMode% /cmd=diff /exclude="*.txt;*.md" "%eigenPath%\Eigen" /to="%finalDir%\include\"

rem Eigenディレクトリコピー
%fastcopyExe% %fastcopyMode% /cmd=diff /exclude="*.txt;*.md" "%eigenPath%\unsupported\Eigen" /to="%finalDir%\include\unsupported\"

rem バージョン番号ファイル追加
type nul > %finalDir%\Eigen_%eigenVersion%

endlocal
