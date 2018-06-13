@echo off
setlocal

REM FastCopy
set fastcopyPath="C:\Program Files\FastCopy\FastCopy.exe"

REM FastCopy���[�h
set fastcopyMode=/force_close

REM �r���h�o�b�t�@
set buildBuf=C:\Library\Temp

REM ���C�u�����p�X
set cudnnDir=cudnn

REM �o�[�W�����ݒ�
set cudaVersion=9.2patch1
set cudnnVersion=7.1.4

REM ���݂̃p�X�̕ێ�
for /f "delims=" %%f in ( 'cd' ) do set currentPath=%%f

REM �o�b�`�t�@�C���̏ꏊ
set batchPath=%~dp0

REM �\�[�X�u����
cd /d "%batchPath%..\..\"
for /f "delims=" %%f in ( 'cd' ) do set sourceDir=%%f
cd /d "%currentPath%"

REM FastCopy�p�X�쐬
set fastcopyExe=%fastcopyPath%
REM FastCopy�p�X�\��
echo FastCopy : %fastcopyExe%

REM CUDA�p�X
set cudaPath=%sourceDir%\CUDA
REM CUDA�p�X�\��
echo CUDA : %cudaPath%

REM CUDA�p�X�m�F
if not exist %cudaPath% (
	powershell -Command Start-Process -Wait -FilePath cmd.exe -Verb runas -ArgumentList '/c','"mklink /D ""%cudaPath%""" """%CUDA_PATH%"""'
)

REM CUDNN�p�X
set cudnnPath=%sourceDir%\%cudnnDir%
REM CUDNN�p�X�\��
echo CUDNN : %cudnnPath%

REM �C���X�g�[���f�B���N�g��
set finalDir=%buildBuf%\Final\CUDA
REM �C���X�g�[���f�B���N�g���\��
echo install : %finalDir%

REM �C���X�g�[���f�B���N�g���폜
if exist "%finalDir%" (
	rd /S /Q "%finalDir%"
)

REM include�f�B���N�g���R�s�[
%fastcopyExe% %fastcopyMode% /cmd=diff "%cudaPath%\include" /to="%finalDir%\include"
%fastcopyExe% %fastcopyMode% /cmd=diff "%cudnnPath%\include" /to="%finalDir%\include"

REM lib�t�@�C���R�s�[
%fastcopyExe% %fastcopyMode% /cmd=diff /include="*.lib" "%cudaPath%\lib\x64" /to="%finalDir%\lib\x64"
%fastcopyExe% %fastcopyMode% /cmd=diff /include="*.lib" "%cudnnPath%\lib\x64" /to="%finalDir%\lib\x64"

REM dll�Epdb�t�@�C���R�s�[
%fastcopyExe% %fastcopyMode% /cmd=diff /include="*.dll" /exclude="*32*" "%cudaPath%\bin" /to="%finalDir%\bin"
%fastcopyExe% %fastcopyMode% /cmd=diff /include="*.dll" "%cudnnPath%\bin" /to="%finalDir%\bin"

REM �o�[�W�����ԍ��t�@�C���ǉ�
type nul > %finalDir%\CUDA_%cudaVersion%
type nul > %finalDir%\cuDNN_%cudnnVersion%

endlocal
