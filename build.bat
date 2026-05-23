@echo off
echo ===================================================
echo  Megu Pack Optimizer Local Build Script
echo ===================================================

echo [1/4] Setting up MSVC x64 compiler environment...
call "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvarsall.bat" x64

if %ERRORLEVEL% neq 0 (
    echo [ERROR] Failed to set up MSVC environment!
    exit /b %ERRORLEVEL%
)

echo [2/5] Compiling translations with lrelease...
"D:\Aps\Qt\6.11.1\msvc2022_64\bin\lrelease.exe" translations\megu_pack_optimizer_uk.ts -qm translations\megu_pack_optimizer_uk.qm

if %ERRORLEVEL% neq 0 (
    echo [WARNING] lrelease failed to compile translations! Proceeding anyway...
)

echo [3/5] Configuring CMake with Qt6 & Ninja...
"D:\Aps\Qt\Tools\CMake_64\bin\cmake.exe" -G "Ninja" -DCMAKE_MAKE_PROGRAM="D:\Aps\Qt\Tools\Ninja\ninja.exe" -DCMAKE_PREFIX_PATH="D:\Aps\Qt\6.11.1\msvc2022_64" -DCMAKE_BUILD_TYPE=Release -B build -S .

if %ERRORLEVEL% neq 0 (
    echo [ERROR] CMake configuration failed!
    exit /b %ERRORLEVEL%
)

echo [4/5] Compiling C++ application...
"D:\Aps\Qt\Tools\CMake_64\bin\cmake.exe" --build build

if %ERRORLEVEL% neq 0 (
    echo [ERROR] Build compilation failed!
    exit /b %ERRORLEVEL%
)

echo [5/5] Deploying Qt6 QML dependencies (windeployqt) and copying to New...
"D:\Aps\Qt\6.11.1\msvc2022_64\bin\windeployqt.exe" --verbose 1 --no-translations --compiler-runtime --qmldir src/qml build/megu_pack_optimizer.exe

if %ERRORLEVEL% neq 0 (
    echo [ERROR] windeployqt failed to deploy dependencies!
    exit /b %ERRORLEVEL%
)

if not exist "C:\Users\alexa\Desktop\New" mkdir "C:\Users\alexa\Desktop\New"
copy /Y "build\megu_pack_optimizer.exe" "C:\Users\alexa\Desktop\New\megu_pack_optimizer.exe"

if %ERRORLEVEL% neq 0 (
    echo [ERROR] Failed to copy executable to C:\Users\alexa\Desktop\New!
    exit /b %ERRORLEVEL%
)

echo ===================================================
echo  [SUCCESS] Megu Pack Optimizer built and deployed!
echo  Executable: C:\Users\alexa\Desktop\New\megu_pack_optimizer.exe
echo ===================================================
