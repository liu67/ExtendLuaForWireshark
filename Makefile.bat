@echo off

:begin
    setlocal
    set MyPath=%~dp0

:config
    if "%1" == "" (
      set PLAT=x64
    ) else (
      set PLAT=x86
    )

    set VCPATH=C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build
    set VPATH=%MyPath%
    set GPATH=%MyPath%\\%PLAT%

    set CC=cl
    set AR=lib
    set LNK=link

    set LuaBasePath=%MyPath%..\\Lua
    set DestLua=xlua.lua
    set DestCmt=xlua.txt
    set LuaExe=%LuaBasePath%\\%PLAT%\\lua
    set xluaBasePath=%MyPath%\\..\\xlualib

:compileflags
    set CFLAGS= /c /MP /GS- /Qpar /GL /analyze- /W4 /Gy /Zc:wchar_t /Zi /Gm- /Ox /Zc:inline /fp:precise /D "WIN32" /D "NDEBUG" /D "_UNICODE" /D "UNICODE" /fp:except- /errorReport:none /GF /WX /Zc:forScope /GR- /Gd /Oy /Oi /MT /EHa /nologo /Fo"%GPATH%\\"

    set MyCFLAGS=  /wd"4244" /wd"4310" /wd"4324" /wd"4702" /wd"4210" /wd"4267" /wd"4456" /wd"4996" /D "LUA_COMPAT_ALL" /D"LUA_COMPAT_5_2" /D"LUA_COMPAT_5_1" /D "XLUALIB_INSIDE" /I"..\\curl\\include" /I"..\\openssl\\include" /I"..\\zlib\\include" /I"..\\xlib" /I".\\src" /I"%xluaBasePath%"

    set DllCFLAGS= /D "_USRDLL" /D "LUA_BUILD_AS_DLL" /D "_WINDLL"

    if not "%1" == "" set MyCFLAGS=%MyCFLAGS% /D "_USING_V110_SDK71_"

:linkflags
    if "%1" == "" (
        set LFLAGS_PLAT_CONSOLE= /SUBSYSTEM:CONSOLE
        set LFLAGS_PLAT_WINDOWS= /SUBSYSTEM:WINDOWS
    ) else (
        set LFLAGS_PLAT_CONSOLE= /SAFESEH /SUBSYSTEM:CONSOLE",5.01"
        set LFLAGS_PLAT_WINDOWS= /SAFESEH /SUBSYSTEM:WINDOWS",5.01"
    )

    set LFLAGS= /MANIFEST:NO /LTCG /NXCOMPAT /DYNAMICBASE "kernel32.lib" "user32.lib" "gdi32.lib" "winspool.lib" "comdlg32.lib" "advapi32.lib" "shell32.lib" "ole32.lib" "oleaut32.lib" "uuid.lib" "odbc32.lib" "odbccp32.lib" /MACHINE:%PLAT% /OPT:REF /INCREMENTAL:NO /OPT:ICF /ERRORREPORT:NONE /NOLOGO

    set LFLAGS=%LFLAGS% /LIBPATH:"..\\curl\\%PLAT%" /LIBPATH:"..\\openssl\\%PLAT%" /LIBPATH:"..\\zlib\\%PLAT%" /LIBPATH:"..\\xlib\\%PLAT%"

:start
    echo ==== ==== ==== ==== Start compiling %PLAT%...

    echo ==== ==== ==== ==== Prepare environment(%PLAT%)...
    cd /d %VCPATH%
    if "%1" == "" (
        call vcvarsall.bat amd64 >nul
    ) else (
        call vcvarsall.bat x86 >nul
    )

    echo ==== ==== ==== ==== Prepare dest folder(%PLAT%)...
    if not exist "%GPATH%" mkdir %GPATH%
    del /q "%GPATH%\\*.*"

    cd /d %VPATH%

:packlua
    echo ==== ==== ==== ==== Packing lua(%PLAT%)...
    "%LuaExe%" "%xluaBasePath%\\Pack.lua" "%xluaBasePath%\\Lua" "%VPATH%\\ExtendScript" "%VPATH%\\xlua.lua" "%VPATH%\\xlua.md" >nul
    if not %errorlevel%==0 goto compile_error

:res
    echo ==== ==== ==== ==== Building Resource(%PLAT%)...
    rc /D "_UNICODE" /D "UNICODE" /l 0x0409 /nologo /fo"%GPATH%\\xlualib.res" "%xluaBasePath%\\xlualib.rc" >nul
    if not %errorlevel%==0 goto compile_error

:dll
    echo ==== ==== ==== ==== Building DLL(%PLAT%)...
    %CC% %CFLAGS% %MyCFLAGS% %DllCFLAGS% /Fd"%GPATH%\\lua52.pdb" "%VPATH%\\src\\*.c" "%xluaBasePath%\\*.cc" "%VPATH%\\*.cc" >nul
    if not %errorlevel%==0 goto compile_error

    del "%GPATH%\\lua.obj" "%GPATH%\\luac.obj"
    
    %LNK% /OUT:"%GPATH%\\lua52.dll" %LFLAGS% %LFLAGS_PLAT_WINDOWS% /DLL "%GPATH%\\*.obj" "%GPATH%\\xlualib.res" >nul
    if not %errorlevel%==0 goto link_error

:exe
    echo ==== ==== ==== ==== Building EXE(%PLAT%)...

    %CC% %CFLAGS% %MyCFLAGS% /Fd"%GPATH%\\lua.pdb" "%VPATH%\\src\\lua.c" >nul
    if not %errorlevel%==0 goto compile_error

    %LNK% /OUT:"%GPATH%\\lua.exe" %LFLAGS% %LFLAGS_PLAT_CONSOLE% "%GPATH%\\lua52.lib" "%GPATH%\\lua.obj" >nul
    if not %errorlevel%==0 goto link_error

    del "%GPATH%\\*.obj"
    del "%GPATH%\\*.res"
    del "%VPATH%\\xlua.lua"

:test
    echo ==== ==== ==== ==== Testing(%PLAT%)...
    cd "%GPATH%"
    lua -e "print( ([[AABBCC]]):show() )" >nul
    if not %errorlevel%==0 goto link_error

:done
    echo.

    endlocal

    if "%1" == "" (
        cmd /C %~f0 x86
    ) else (
        exit /B 0
    )

    echo done.

    goto end

:compile_error
    echo !!!!!!!!Compile error!!!!!!!!
    goto end

:link_error
    echo !!!!!!!!Link error!!!!!!!!
    goto end

:end
    pause >nul