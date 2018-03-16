
@set MyPath=%~dp0
@set DstPath=C:\\Program Files\\Wireshark

@if not exist "%DstPath%\\LuaPlugins" mkdir "%DstPath%\\LuaPlugins"

copy "%MyPath%\\x64\\lua52.dll" "%DstPath%"

copy "%MyPath%\\ExtendScript\\*.lua" "%DstPath%\\LuaPlugins\\*.luae"

copy "%MyPath%\\CheckExtendLuaForWireshark.lua" "%DstPath%\\LuaPlugins\\CheckExtendLuaForWireshark.luae"

@pause >nul