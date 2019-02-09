@echo off

SET "DEPS_ROOT=%~dp0"

cd /D %DEPS_ROOT%libpng

rmdir /S /Q build64 > nul
mkdir build64
cd build64

cmake -G"Visual Studio 15 2017 Win64" -DPNG_TESTS=0 -DPNG_BUILD_ZLIB=1 -DZLIB_INCLUDE_DIR="%INCLUDE_PATH%" -DZLIB_LIBRARY_DEBUG="%LIB64_PATH%\zlibstaticd.lib" -DZLIB_LIBRARY_RELEASE="%LIB64_PATH%\zlibstatic.lib" ../

::msbuild png_static.vcxproj /p:Configuration=Debug /p:Platform=x64
msbuild png_static.vcxproj /p:Configuration=Release /p:Platform=x64

:: install

cd /D %DEPS_ROOT%

copy /Y libpng\*.h include\
copy /Y libpng\build64\*.h include\

::copy /Y libpng\build64\Debug\*.lib lib64\
copy /Y libpng\build64\Release\*.lib lib64\