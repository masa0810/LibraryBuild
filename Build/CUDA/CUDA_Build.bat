@echo off
setlocal

rem FastCopy
set fastcopyPath=FastCopy330_x64\FastCopy.exe

rem FastCopyモード
set fastcopyMode=/force_close

rem ライブラリパス
set cudnnDir=cudnn-8.0-windows10-x64-v6.0

rem バージョン設定
set cudnnVersion=6.0

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

rem CUDAパス
set cudaPath=%CUDA_PATH_V8_0%
rem CUDAパス表示
echo CUDA : %cudaPath%

rem CUDNNパス
set cudnnPath=%sourceDir%\%cudnnDir%
rem CUDNNパス表示
echo CUDNN : %cudnnPath%

rem インストールディレクトリ
set finalDir=%sourceDir%\Final\CUDA

rem インストールディレクトリ表示
echo install : %finalDir%

rem インストールディレクトリ削除
if exist "%finalDir%" (
	rd /S /Q "%finalDir%"
)

rem includeディレクトリコピー
%fastcopyExe% %fastcopyMode% /cmd=diff "%cudaPath%\include" /to="%finalDir%\"
%fastcopyExe% %fastcopyMode% /cmd=diff "%cudnnPath%\cuda\include" /to="%finalDir%\"

rem libファイルコピー
%fastcopyExe% %fastcopyMode% /cmd=diff /include="*.lib" "%cudaPath%\lib\x64" /to="%finalDir%\lib\x64"
%fastcopyExe% %fastcopyMode% /cmd=diff /include="*.lib" "%cudnnPath%\cuda\lib\x64" /to="%finalDir%\lib\x64"

rem dll・pdbファイルコピー
%fastcopyExe% %fastcopyMode% /cmd=diff /include="*.dll" /exclude="*32*" "%cudaPath%\bin" /to="%finalDir%\bin"
%fastcopyExe% %fastcopyMode% /cmd=diff /include="*.dll" "%cudnnPath%\cuda\bin" /to="%finalDir%\bin"

rem Copyバッチのコピー
%fastcopyExe% %fastcopyMode% /cmd=diff "%batchPath%\files\CudaCopy.bat" /to="%finalDir%\"

rem バージョン番号ファイル追加
for /f "tokens=3" %%l in ( 'type "%cudaPath%\version.txt"' ) do set cudaVersion=%%l
type nul > %finalDir%\%cudaVersion%_%cudnnVersion%

endlocal
