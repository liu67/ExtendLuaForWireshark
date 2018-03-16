--[=======[
---- ---- ---- ----

## Wireshark ProtoFieldEx函数

函数用于建立自动对齐格式化的Field表，定义如下：
```
table protofieldsex, table protofields
          ProtoFieldEx              (
                                    [ string abbr_pre_fix, ]
                                    table fields
                                    );
```

- 参数abbr_pre_fix用于添加abbr前缀（强烈建议添加之）
- fields格式如下：
```
  {
    { func,         short_abbr,     name,         ... },
    ...
  };
```
- fields的规则如下：
    - name允许为nil，此时，nam = short_abbr
    - func优先识别为ProtoField支持的类型名
    - func允许为FormatEx的子函数名，用于自定义格式化，但此时field一律被定义为string
    - func无视大写，一律转换成小写格式
    - func未能识别时，抛出错误
    - short_abbr与name必须为UTF8
    - func支持如下简写：
```
  {
  b   = "uint8",
  w   = "uint16",
  d   = "uint32",
  q   = "uint64",
  a   = "bytes",
  s   = "string",
  }
```
- 存在全局格式化设定，此设定将影响数据显示格式
- 注意：临时修改此设定将无法影响预定义的Field格式
```
ShowFieldFormat = "%-20s  ";
```
- 对于表中每个元素，函数将为之生成
```
  field = ProtoField[ func ]( abbr_pre_fix .. short_abbr,
      string.format( ShowFieldFormat, short_abbr, name ), ... );
```
- 返回第一个表`protofieldsex`，用于与TreeAddEx配合使用，简化元素添加
```
  {
  [short_addr] =
    {
      types,  --一般用于确认默认大小
      field,
      exfunc,--此项存在时，表示需要调用自定义格式化
    },
  ...
  }
```
- 返回第二个表用于proto.fields的赋值
```
  {
  [short_addr] = field,
  ...
  }
```
- 存在如下**全局Field**：（使用全局函数`get_default_fieldsex()`获取此表）
```
  {
    { "uint8",      "xxoo_b",     "Byte",    base.HEX_DEC },
    { 'uint16',     "xxoo_w",     "Word",    base.HEX_DEC },
    { 'uint32',     "xxoo_d",     "Dword",   base.HEX_DEC },
    { 'uint64',     "xxoo_q",     "Qword",   base.HEX_DEC },
    { 'bytes',      "xxoo_a",     "Bytes"                 },
    { "string",     "xxoo_s",     "String"                },
    { 'bytes',      "xxoo_x",     "unsolved"              },
  };
```
]=======]
--此表用于处理简写
local ProtoFieldShort =
  {
  b   = "uint8",
  w   = "uint16",
  d   = "uint32",
  q   = "uint64",
  a   = "bytes",
  s   = "string",
  };

local default_fieldsex;
function get_default_fieldsex()
  if default_fieldsex then
    return default_fieldsex;
  end

  local FieldDefault =
    {
      { "uint8",      "xxoo_b",     "Byte",       base.HEX_DEC },
      { 'uint16',     "xxoo_w",     "Word",       base.HEX_DEC },
      { 'uint32',     "xxoo_d",     "Dword",      base.HEX_DEC },
      { 'uint64',     "xxoo_q",     "Qword",      base.HEX_DEC },
      { 'bytes',      "xxoo_a",     "Bytes"                    },
      { "string",     "xxoo_s",     "String"                   },
      { 'bytes',      "xxoo_x",     "unsolved"                 },
    };
  default_fieldsex = {};
  local fields = {};
  for _, tb in pairs( FieldDefault ) do
    local func, abbr, name = table.unpack( tb );
    local types = func;

    func = rawget( ProtoField, func );
    name = string.format( ShowFieldFormat, name );

    local field;
    if #tb > 3 then
      field = func( abbr, name, select( 4, table.unpack( tb ) ) );
    else
      field = func( abbr, name );
    end

    fields[ abbr ] = field;
    default_fieldsex[ abbr ] = { types = types, field = field };
  end

  --需要注册，否则不可用
  local proto = Proto( "ExtendLuaForWireshark", "ExtendLuaForWireshark" );
  proto.fields = fields;

  return setmetatable( default_fieldsex,
    {
    __newindex = function() return error( "default_fieldsex禁止修改" ); end
    }
    );
end

ShowFieldFormat = "%-20s  ";

function ProtoFieldEx( arg1, arg2 )
  --参数识别
  local pre_fix, fields;
  if type( arg2 ) == "table" then
    pre_fix = arg1 or "";
    fields = arg2;
  else
    pre_fix = arg2 or "";
    fields = arg1;
  end

  local protofieldsex = { };
  local protofields = {};
  
  local fs = {};
  for abbr in pairs( get_default_fieldsex() ) do
    fs[ abbr ] = true;
  end

  for k, tb in pairs( fields ) do
    local func = tb[ 1 ];
    if not func then
      return error( string.format( "No.%d func missing", k ) );
    end
    func = func:lower();
    func = ProtoFieldShort[ func ] or func; --简写转换

    --优先识别为ProtoField子函数
    local types = func;
    local exfunc;
    func = rawget( ProtoField, types );
    if not func then
      --尝试识别为FormatEx
      func = FormatEx[ types ];
      if not func then
        return error( string.format( "No.%d func %s unknown", k, types ) );
      end
      exfunc = func;
      func = ProtoField.string;
      types = "string";
    end

    --检查abbr是否存在、是否重复
    local abbr = tb[ 2 ];
    if not abbr then
      return error( string.format( "No.%d abbr missing", k ) );
    end
    if fs[ abbr ] then
      return error( string.format( "No.%d %s repeat", k, abbr ) );
    end
    fs[ abbr ] = true;
    
    local name = tb[ 3 ] or abbr;
    name = string.format( ShowFieldFormat, utf82s( name ) );
    name = s2utf8( name );
    
    local field;
    if #tb > 3 then
      field = func( pre_fix .. abbr, name, select( 4, table.unpack( tb ) ) );
    else
      field = func( pre_fix .. abbr, name );
    end

    protofields[ abbr ] = field;
    protofieldsex[ abbr ] = { types = types,  field = field, exfunc = exfunc };
  end
  
  return protofieldsex, protofields;
end
