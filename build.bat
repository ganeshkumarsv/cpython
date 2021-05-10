if not exist c:\mnt\ goto nomntdir
@echo c:\mnt found, continuing

set platf=Win32
set builddir=
set outdir=c:\mnt\build-out

cd c:\mnt\PCBuild  || exit /b 2
mkdir %outdir%
if not exist %outdir% exit /b 3

if "%TARGET_ARCH%" == "x64" (
    @echo IN x64 BRANCH
    call %VSTUDIO_ROOT%\VC\Auxiliary\Build\vcvars64.bat
    set platf=x64
    set builddir=amd64
)

if "%TARGET_ARCH%" == "x86" (
    @echo IN x86 BRANCH
    call %VSTUDIO_ROOT%\VC\Auxiliary\Build\vcvars32.bat
)

msbuild pcbuild.sln /p:Configuration=Release /p:Platform=%platf%

mkdir %outdir%\DLLs
copy .\PCbuild\%builddir%\*.pyd %outdir%\DLLs || exit /b 4
robocopy .\include %outdir%\include /s /e || exit /b 5
robocopy .\Lib %outdir%\Lib /s /e || exit /b 6
copy .\PCbuild\%builddir%\*.lib %outdir%\libs || exit /b 7
copy .\PCbuild\%builddir%\python27.dll %outdir% || exit /b 8
copy .\PCbuild\%builddir%\python.exe %outdir% || exit /b 9
copy .\PCbuild\%builddir%\pythonw.exe %outdir% || exit /b 10
cd %outdir%\libs
gendef %outdir%\python27.dll
dlltool --dllname python27.dll --def python27.def --output-lib libpython27.a
goto :EOF

:nomntdir
@echo directory not mounted, parameters incorrect
exit /b 1
goto :EOF