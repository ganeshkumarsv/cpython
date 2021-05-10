if not exist c:\mnt\ goto nomntdir
@echo c:\mnt found, continuing
cd C:\mnt

set platf=Win32
set builddir=c:\mnt\PCBuild
set outdir=c:\mnt\build-out

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
robocopy .\include %outdir%\include /MIR
if %ERRORLEVEL% GEQ 8 exit /b 5

REM Copy Lib directory
robocopy .\Lib %outdir%\Lib /MIR /XF *.pyc /XD plat-aix3 plat-aix4 plat-atheos .\Lib\plat-beos5 .\Lib\plat-darwin .\Lib\plat-freebsd4 .\Lib\plat-freebsd5 .\Lib\plat-freebsd6 .\Lib\plat-freebsd7 .\Lib\plat-freebsd8 .\Lib\plat-generic .\Lib\plat-irix5 .\Lib\plat-irix6 .\Lib\plat-linux2 .\Lib\plat-mac .\Lib\plat-netbsd1 .\Lib\plat-next3 .\Lib\plat-os2emx .\Lib\plat-riscos .\Lib\plat-sunos5 .\Lib\plat-unixware7
if %ERRORLEVEL% GEQ 8 exit /b 6

REM Copy libs directory
mkdir %outdir%\libs
copy %builddir%\*.lib %outdir%\libs || exit /b 7

REM Copy files in root directory
copy %builddir%\python27.dll %outdir% || exit /b 8
copy %builddir%\python.exe %outdir% || exit /b 9
copy %builddir%\pythonw.exe %outdir% || exit /b 10

REM Generate import library
gendef %builddir%\python27.dll
dlltool --dllname python27.dll --def python27.def --output-lib libpython27.a
copy libpython27.a %outdir%\libs

goto :EOF

:nomntdir
@echo directory not mounted, parameters incorrect
exit /b 1
goto :EOF