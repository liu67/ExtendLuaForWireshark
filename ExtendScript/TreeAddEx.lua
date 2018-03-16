--[=======[
---- ---- ---- ----

## Wireshark TreeAddEx函数

函数用于根据要求自动添加解析元素，定义如下：
```
int       TreeAddEx                 (
                                    table     protofieldsex,
                                    TreeItem  root,
                                    Tvb       tvb,
                                    int       off,
                                    ...
                                    );
```

- protofieldsex为ProtoFieldEx返回的第一个表
- 不定参以 short_abbr, [size|format_function,] short_abbr, ... 形式提供
    - short_abbr的第一个字符允许为'<'或'>'，用于标示field的大小端，默认大端
    - short_abbr允许以空格分隔注释。空格以后的所有数据被认为是注释而无视之
    - 当提供format_function时，函数调用如示：`format_function( buf, off, nil, tree_add_func, root, field, proto );`
        - 如果调用内部使用了tree_add_func，应返回off + size
        - 否则应返回formatted_string, size
        - 处理将在其后自动调用`tree_add_func( root, field, buf( off, size ), formatted_string );`
    - 当不提供size或format_function时，使用默认长度
    - 当指定field未有默认长度时，使用剩余的所有数据
    - 允许指定short_abbr在protofieldsex中无匹配，此时有如下规则
          - 当提供format_function时，函数调用如示：`format_function( buf, off, nil, tree_add_func, root, field, proto );`
              - 如果调用内部使用了tree_add_func，应返回off + size
              - 否则应返回formatted_string, size。
              - 处理将在其后自动调用`tree_add_func( root, proto, buf( off, size), prefix_string .. formatted_string );`
    - 否则必须在空格后指定类型，支持类型参考FormatEx

- 函数返回处理结束后的off

默认长度列表如下：   
```       
{
uint8     = 1,
uint16    = 2,
uint24    = 3,
uint32    = 4,
uint64    = 8,
int8      = 1,
int16     = 2,
int24     = 3,
int32     = 4,
int64     = 8,

framenum  = 4,
bool      = 1,
absolute_time = 4,
relative_time = 4,

ipv4      = 4,
ipv6      = 16,
ether     = 6,
float     = 4,
double    = 8,
};
```
示例1：
```
off = TreeAddEx( fieldsex, root, tvb, off,
  "xxoo_b",                   --可识别的short_abbr，且可识别长度
  "xxoo_a", 2,                --强制长度
  "xxoo_s", format_xxx        --可识别的short_abbr，但不可识别长度，需要自定义格式化
  );
--生成效果大致如下：
  Byte                : 0x00(0)
  Bytes               : 0000
  String              : xxxxxxxx
```
示例2：
```
TreeAddEx( fieldsex, root, tvb, off,
  "unknow_b uint8",            --指定可识别的支持类型，不用后续指定大小
  "unknow_s string", 6,        --支持类型可识别，但强制指定大小
  );
--生成效果大致如下：
  String              : xxxxxxxx
  * unknow_b          : 0x00(0)
  * unknow_s          : xxxxxx
```
]=======]

local TypeDefaultSize =
  {
  uint8     = 1,
  uint16    = 2,
  uint24    = 3,
  uint32    = 4,
  uint64    = 8,
  int8      = 1,
  int16     = 2,
  int24     = 3,
  int32     = 4,
  int64     = 8,

  framenum  = 4,
  bool      = 1,
  absolute_time = 4,
  relative_time = 4,

  ipv4      = 4,
  ipv6      = 16,
  ether     = 6,
  float     = 4,
  double    = 8,
  };

local FieldShort =
  {
  b   = "uint8",
  w   = "uint16",
  d   = "uint32",
  q   = "uint64",
  a   = "bytes",
  s   = "string",

  B   = "uint8",
  W   = "uint16",
  D   = "uint32",
  Q   = "uint64",
  A   = "bytes",
  S   = "string",
  };

local function TreeAddEx_FormatIt( format_func,
                                   tvb,
                                   off,
                                   size,
                                   tree_add_func,
                                   root,
                                   field,
                                   proto )
  local msg, size = format_func( tvb, off, size,
    tree_add_func, root, field, proto );
  --如果格式化函数内部处理完毕，则不再继续
  if not size then
    return msg;   --msg即为size
  end
  --size不对，抛出错误
  local maxlimit = tvb:len() - off;
  if size < 0 or size > ( tvb:len() - off ) then
    return error( "TreeAddEx_FormatIt return @%d %d > %d",
      off, size, maxlimit );
  end
  --否则进行默认添加
  if "string" == type( field ) then
    if proto then
      tree_add_func( root, proto, tvb( off, size ), field .. msg );
    else
      tree_add_func( root, tvb( off, size ), field .. msg );
    end
  else
    tree_add_func( root, field, tvb( off, size ), msg );
  end
  return off + size;
end

local function TreeAddEx_AddOne( argv, k, protofieldsex, root, tvb, off )
  --获取数据描述
  local abbr = argv[ k ];      k = k + 1;
  
  --判定大小端
  local tree_add_func = root.add;
  local isnet = abbr:sub(1, 1);
  if isnet == '<' then
    tree_add_func = root.add_le;
    abbr = abbr:sub( 2 );
  elseif isnet == '>' then
    abbr = abbr:sub( 2 );
  end

  --分离abbr与类型描述
  local abbr, format_func = abbr:match( "([^ ]+) *([^ ]*)" );

  --空串忽略
  if not abbr or abbr == "" then
    return off, k;
  end

  local next_abbr = argv[ k ];
  local next_abbr_type = type( next_abbr );
  local maxlimit = tvb:len() - off;

  --识别abbr，当abbr不可识别时，field为伪前缀
  local tb = protofieldsex[ abbr ] or get_default_fieldsex()[ abbr ];
  local field;
  if tb then
    field = tb.field;
  else
    field = string.format( ShowFieldFormat .. ": ", "*" .. utf82s( abbr ) );
    field = s2utf8( field );
  end

  if next_abbr_type == "function" then --如果有指定格式化函数，则使用之
    return TreeAddEx_FormatIt( next_abbr, tvb, off, nil, tree_add_func, root, field, protofieldsex.__proto ), k + 1;
  end

  if not tb then
    if format_func == "" then
      format_func = nil;
    else
      --尝试类型简写转换
      format_func = FieldShort[ format_func ] or format_func;
      --尝试识别为自定义格式化
      format_func = FormatEx[ format_func ];
    end

    if not format_func then
      return error( string.format( "[%s]need FormatEx", abbr ) );
    end
  end

  local size = maxlimit;
  if next_abbr_type == "number" then --指定长度，区别处理
    size = next_abbr;
    k = k + 1;
  elseif tb then
    size = TypeDefaultSize[ tb.types ] or maxlimit;
  end

  if size < 0 or size > maxlimit then
    return error( "TreeAddEx size error @%d %d > %d",
      off, size, maxlimit );
  end

  if tb then
    --存在exfunc的话，格式化之
    if tb.exfunc then
      return TreeAddEx_FormatIt( tb.exfunc,
        tvb, off, size, tree_add_func, root, field, protofieldsex.__proto ), k;
    end
    tree_add_func( root, field, tvb( off, size ) );
    return off + size, k;
  end

  return TreeAddEx_FormatIt( format_func,
  tvb, off, size, tree_add_func, root, field, protofieldsex.__proto ), k;
end

function TreeAddEx( protofieldsex, root, tvb, off, ... )
  local off = off or 0;
  local argv = { ... };

  local k = 1;
  while k <= #argv do
    off, k = TreeAddEx_AddOne( argv, k, protofieldsex, root, tvb, off );
  end
  return off;
end