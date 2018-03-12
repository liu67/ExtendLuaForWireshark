# ExtendLuaForWireshark

---- ---- ---- ----

## 基本使用方法

1. 将相应的lua52.dll覆盖Wireshark目录下的lua52.dll
2. 在Wireshark目录下新建目录LuaPlugins
3. Wireshark运行时，自动加载LuaPlugins目录下所有以"luae"为后缀的解析脚本

---- ---- ---- ----

## 基本原理

借助wireshark主动加载init.lua时，在加载consloe.lua时，嵌入加载机会

---- ---- ---- ----

## 不采用wireshark自动加载机制的理由

wireshark会自动加载plugins/ver/目录下所有的lua，但这种加载不认utf-8 with BOM文件

wireshark会枚举所有子目录下的lua并一一加载，这样就无法实现多层次的disscetor了
