@echo off
setlocal

REM FastCopy
set fastcopyPath=FastCopy341_x64\FastCopy.exe

REM FastCopyモード
set fastcopyMode=/force_close

REM ビルドバッファ
set buildBuf=C:\Library\Temp

REM ライブラリパス
set cudnnDir=cudnn

REM バージョン設定
set cudaVersion=9.2patch1
set cudnnVersion=7.1.4

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

REM CUDAパス
set cudaPath=%sourceDir%\CUDA
REM CUDAパス表示
echo CUDA : %cudaPath%

REM CUDAパス確認
if not exist %cudaPath% (
	powershell -Command Start-Process -Wait -FilePath cmd.exe -Verb runas -ArgumentList '/c','"mklink /D ""%cudaPath%""" """%CUDA_PATH%"""'
)

REM CUDNNパス
set cudnnPath=%sourceDir%\%cudnnDir%
REM CUDNNパス表示
echo CUDNN : %cudnnPath%

REM インストールディレクトリ
set finalDir=%buildBuf%\Final\CUDA
REM インストールディレクトリ表示
echo install : %finalDir%

REM インストールディレクトリ削除
if exist "%finalDir%" (
	rd /S /Q "%finalDir%"
)

REM includeディレクトリコピー
%fastcopyExe% %fastcopyMode% /cmd=diff "%cudaPath%\include" /to="%finalDir%\include"
%fastcopyExe% %fastcopyMode% /cmd=diff "%cudnnPath%\include" /to="%finalDir%\include"

REM libファイルコピー
%fastcopyExe% %fastcopyMode% /cmd=diff /include="*.lib" "%cudaPath%\lib\x64" /to="%finalDir%\lib\x64"
%fastcopyExe% %fastcopyMode% /cmd=diff /include="*.lib" "%cudnnPath%\lib\x64" /to="%finalDir%\lib\x64"

REM dll・pdbファイルコピー
%fastcopyExe% %fastcopyMode% /cmd=diff /include="*.dll" /exclude="*32*" "%cudaPath%\bin" /to="%finalDir%\bin"
%fastcopyExe% %fastcopyMode% /cmd=diff /include="*.dll" "%cudnnPath%\bin" /to="%finalDir%\bin"

REM バージョン番号ファイル追加
type nul > %finalDir%\CUDA_%cudaVersion%
type nul > %finalDir%\cuDNN_%cudnnVersion%

endlocal
