@echo off

if exist "%VSPATH%" goto :EOF

if not exist "%VSPATH%" (
	SET "VSPATH=C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\"
	if exist "%VSPATH%" echo Found Visual Studio 2019
)
if not exist "%VSPATH%" (
    SET "VSPATH=C:\Program Files (x86)\Microsoft Visual Studio\2019\Preview\VC\Auxiliary\Build\"
    if exist "%VSPATH%" echo Found Visual Studio 2019 Preview
)
if not exist "%VSPATH%" (
    SET "VSPATH=C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\"
    if exist "%VSPATH%" echo Found Visual Studio 2017
)
if not exist "%VSPATH%" (
    SET "VSPATH=C:\Program Files (x86)\Microsoft Visual Studio\2015\Community\VC\Auxiliary\Build\"
    if exist "%VSPATH%" echo Found Visual Studio 2015
)

if exist "%VSPATH%" (
    call "%VSPATH%\vcvarsall.bat" x64
) else (
    echo Could not find Visual Studio installation
)