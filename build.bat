if not exist c:\mnt\ goto nomntdir
@echo c:\mnt found, continuing
cd C:\mnt

set platf=Win32
set builddir=c:\mnt\PCBuild
set outdir=c:\mnt\build-out
set py_version=2.7.18

mkdir %outdir%
if not exist %outdir% exit /b 3

if "%TARGET_ARCH%" == "x64" (
    @echo IN x64 BRANCH
    call %VSTUDIO_ROOT%\VC\Auxiliary\Build\vcvars64.bat
    set platf=x64
    set builddir=%builddir%\amd64
)

if "%TARGET_ARCH%" == "x86" (
    @echo IN x86 BRANCH
    call %VSTUDIO_ROOT%\VC\Auxiliary\Build\vcvars32.bat
)

call ridk enable

REM First, get the required dependencies
call .\PCBuild\get_externals.bat --organization python --no-tkinter --python 3.8
call .\PCBuild\build.bat --no-tkinter -m -e -c Release -p %platf%

REM Copy DLLs directory
mkdir %outdir%\DLLs
copy %builddir%\*.pyd %outdir%\DLLs || exit /b 4

REM Copy include directory
robocopy .\include %outdir%\include /MIR /NFL /NDL /NJH /NJS /nc /ns /np
if %ERRORLEVEL% GEQ 8 exit /b 5
copy PC\pyconfig.h %outdir%\include || exit /b 6

REM Copy Lib directory
robocopy .\Lib %outdir%\Lib /MIR /NFL /NDL /NJH /NJS /nc /ns /np /XF *.pyc /XD plat-aix3 plat-aix4 plat-atheos plat-beos5 plat-darwin plat-freebsd4 plat-freebsd5 plat-freebsd6 plat-freebsd7 plat-freebsd8 plat-generic plat-irix5 plat-irix6 plat-linux2 plat-mac plat-netbsd1 plat-next3 plat-os2emx plat-riscos plat-sunos5 plat-unixware7
if %ERRORLEVEL% GEQ 8 exit /b 7

REM Copy libs directory
mkdir %outdir%\libs
copy %builddir%\*.lib %outdir%\libs || exit /b 8

REM Copy files in root directory
copy %builddir%\python27.dll %outdir% || exit /b 9
copy %builddir%\python.exe %outdir% || exit /b 10
copy %builddir%\pythonw.exe %outdir% || exit /b 11

REM Generate import library
cd %builddir%
gendef python27.dll
if "%TARGET_ARCH%" == "x64" (
    dlltool -m i386:x86-64 --dllname python27.dll --def python27.def --output-lib libpython27.a
)
if "%TARGET_ARCH%" == "x86" (
    dlltool -m i386 --as-flags=--32 --dllname python27.dll --def python27.def --output-lib libpython27.a
)
copy libpython27.a %outdir%\libs || exit /b 12

REM Generate python zip
7z a -r %outdir%\python-windows-%py_version%-%TARGET_ARCH%.zip %outdir%\*

goto :EOF

:nomntdir
@echo directory not mounted, parameters incorrect
exit /b 1
goto :EOF