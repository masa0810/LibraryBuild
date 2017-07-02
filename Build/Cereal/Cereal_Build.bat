@echo off
setlocal

rem FastCopy
set fastcopyPath=FastCopy330_x64\FastCopy.exe

rem FastCopyモード
set fastcopyMode=/force_close

rem ライブラリパス
set cerealDir=cereal-1.2.2

rem バージョン設定
set cerealVersion=1.2.2

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

rem Cerealパス
set cerealPath=%sourceDir%\%cerealDir%
rem Cerealパス表示
echo Cereal : %cerealPath%

rem インストールディレクトリ
set finalDir=%sourceDir%\Final\Cereal

rem インストールディレクトリ表示
echo install : %finalDir%

rem インストールディレクトリ削除
if exist "%finalDir%" (
	rd /S /Q "%finalDir%"
)

rem Cerealディレクトリコピー
%fastcopyExe% %fastcopyMode% /cmd=diff /exclude="*.txt" "%cerealPath%\include" /to="%finalDir%\"

rem バージョン番号ファイル追加
type nul > %finalDir%\%cerealVersion%

endlocal
