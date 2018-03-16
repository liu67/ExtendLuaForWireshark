--[=======[
---- ---- ---- ----

## Wireshark自定义格式化

- FormatEx提供通用的自定义格式化操作，被TreeAddEx使用

function    | show exsample                | usebyte | notes
------------|------------------------------|---------|------
uint8       | 0x00(0)                      | 1
uint16      | 0x0000(0)                    | 2
uint24      | 0x000000(0)                  | 3
uint32      | 0x00000000(0)                | 4
uint64      | 0x0000000000000000(0)        | 8
int8        | 0x00(0)                      | 1
int16       | 0x0000(0)                    | 2
int24       | 0x000000(0)                  | 3
int32       | 0x00000000(0)                | 4
int64       | 0x0000000000000000(0)        | 8
bool        | true\|false                  | 1
ipv4        | hostname(0.0.0.0)            | 4
ipv4_port   | hostname:port(0.0.0.0:0)     | 6
xipv4_port  | hostname:port(0.0.0.0:0)     | 6       | 字节序标示port，ip与之反序
float       | 0.0                          | 4
string      | 0000000                      | N
bytes       | 000000                       | N
stringz     | 000000                       | N
bxline_string|(00)0000                     | 1 + N   | x表示head不包含自身大小
wxline_string|(0000)0000                   | 2 + N
dxline_string|(00000000)0000               | 4 + N
bline_string| [00]0000                     | 1 + N
wline_string| [0000]0000                   | 2 + N
dline_string| [00000000]0000               | 4 + N
bxline_bytes| (00)0000                     | 1 + N
wxline_bytes| (0000)0000                   | 2 + N
dxline_bytes| (00000000)0000               | 4 + N
bline_bytes | [00]0000                     | 1 + N
wline_bytes | [0000]0000                   | 2 + N
dline_bytes | [00000000]0000               | 4 + N
xdate       | 0000/00/00 00:00:00          | 4
xtime       | 00day 00:00:00               | 4
xcapacity   | 0.00T\|0.00G\|0.00M\|0.00K\|0.00B| N   | size需指定

- ipv4、ipv4_port、xipv4_port额外说明：
    - 显示hostname，需要打开`编辑>>首选项>>Name Resolution>>Resolve network(IP) addresses`
    - hostname无法确定时，不显示hostname，直接显示ip数值
- string、bytes额外说明：
    - size == 0时，返回空串
    - size < 0 或 size > 剩余数据大小，抛出错误
    - 返回数据限长，超过限长时，返回截断结果，如`0000...`

]=======]

-- 数据限长，不做全局配置，为记
local LimitAdd = "...";
local StringLimitMax = 0x2C;  -- 数据超过此长度将采用限长加后缀（限长应>0x10）

FormatEx = { };
function FormatEx.uint8( tvb, off, size, func, root )
  local v = tvb( off, 1 ):uint();
  return string.format( "0x%02X(%u)", v, v ), 1;
end
function FormatEx.uint16( tvb, off, size, func, root )
  local v;
  if func and func ~= root.add then
    v = tvb( off, 2 ):le_uint();
  else
    v = tvb( off, 2 ):uint();
  end
  return string.format( "0x%04X(%u)", v, v ), 2;
end
function FormatEx.uint24( tvb, off, size, func, root )
  local v;
  if func and func ~= root.add then
    v = tvb( off, 3 ):le_uint();
  else
    v = tvb( off, 3 ):uint();
  end
  return string.format( "0x%06X(%u)", v, v ), 3;
end
function FormatEx.uint32( tvb, off, size, func, root )
  local v;
  if func and func ~= root.add then
    v = tvb( off, 4 ):le_uint();
  else
    v = tvb( off, 4 ):uint();
  end
  return string.format( "0x%08X(%u)", v, v ), 4;
end
function FormatEx.uint64( tvb, off, size, func, root )
  local v;
  if func and func ~= root.add then
    v = tvb( off, 8 ):le_uint64();
  else
    v = tvb( off, 8 ):uint64();
  end
  return "0x" .. v:tohex() .. '(' .. v .. ')', 8;
end

function FormatEx.int8( tvb, off, size, func, root )
  local v = tvb( off, 1 ):int();
  return string.format( "0x%02X(%d)", v % 0x100, v ), 1;
end
function FormatEx.int16( tvb, off, size, func, root )
  local v;
  if func and func ~= root.add then
    v = tvb( off, 2 ):le_int();
  else
    v = tvb( off, 2 ):int();
  end
  return string.format( "0x%04X(%d)", v % 0x10000, v ), 2;
end
function FormatEx.int24( tvb, off, size, func, root )
  local v;
  if func and func ~= root.add then
    v = tvb( off, 3 ):le_int();
  else
    v = tvb( off, 3 ):int();
  end
  if v & 0x800000 ~= 0 and v > 0 then   --修正负数无法正确显示的BUG
    v = v | 0xFFFFFFFFFF000000;
  end
  return string.format( "0x%06X(%d)", v % 0x1000000, v ), 3;
end
function FormatEx.int32( tvb, off, size, func, root )
  local v;
  if func and func ~= root.add then
    v = tvb( off, 4 ):le_int();
  else
    v = tvb( off, 4 ):int();
  end
  return string.format( "0x%08X(%d)", v % 0x100000000, v ), 4;
end
function FormatEx.int64( tvb, off, size, func, root )
  local v;
  if func and func ~= root.add then
    v = tvb( off, 8 ):le_int64();
  else
    v = tvb( off, 8 ):int64();
  end
  return "0x" .. v:tohex( -16 ) .. '(' .. v .. ')', 8;
end

function FormatEx.bool( tvb, off, size, func, root )
  local v = tvb( off, 1 ):int();
  if v == 0 then
    return "false", 1;
  end
  return "true", 1;
end

function FormatEx.ipv4( tvb, off, size, func, root )
  local ss, sss;
  if func and func ~= root.add then
    ss = tostring( tvb( off, 4 ):le_ipv4() );
    sss = string.format( "%d.%d.%d.%d", 
          tvb( off + 3, 1 ):uint(),
          tvb( off + 2, 1 ):uint(),
          tvb( off + 1, 1 ):uint(),
          tvb( off + 0, 1 ):uint());
  else
    ss = tostring( tvb( off, 4 ):ipv4() );
    sss = string.format( "%d.%d.%d.%d", 
          tvb( off + 0, 1 ):uint(),
          tvb( off + 1, 1 ):uint(),
          tvb( off + 2, 1 ):uint(),
          tvb( off + 3, 1 ):uint());
  end
  if ss:gsub( "[%.%d]", "" ) ~= "" then
    ss = ss .. '(' .. sss .. ')';
  end
  return ss, 4;
end

function FormatEx.ipv4_port( tvb, off, size, func, root )
  local ss, sss, pp;
  if func and func ~= root.add then
    ss = tostring( tvb( off, 4 ):le_ipv4() );
    sss = string.format( "%d.%d.%d.%d", 
          tvb( off + 3, 1 ):uint(),
          tvb( off + 2, 1 ):uint(),
          tvb( off + 1, 1 ):uint(),
          tvb( off + 0, 1 ):uint());
    pp = tvb( off + 4, 2 ):le_uint();
  else
    ss = tostring( tvb( off, 4 ):ipv4() );
    sss = string.format( "%d.%d.%d.%d", 
          tvb( off + 0, 1 ):uint(),
          tvb( off + 1, 1 ):uint(),
          tvb( off + 2, 1 ):uint(),
          tvb( off + 3, 1 ):uint());
    pp = tvb( off + 4, 2 ):uint();
  end
  ss = string.format( "%s:%d", ss, pp );
  if ss:gsub( "[%.%d%:]", "" ) ~= "" then
    ss = string.format( "%s(%s:%d)", ss, sss, pp );
  end
  return ss, 4 + 2;
end

function FormatEx.xipv4_port( tvb, off, size, func, root )
  local ss, sss, pp;
  if func and func ~= root.add then
    ss = tostring( tvb( off, 4 ):ipv4() );
    sss = string.format( "%d.%d.%d.%d", 
          tvb( off + 0, 1 ):uint(),
          tvb( off + 1, 1 ):uint(),
          tvb( off + 2, 1 ):uint(),
          tvb( off + 3, 1 ):uint());
    pp = tvb( off + 4, 2 ):le_uint();
  else
    ss = tostring( tvb( off, 4 ):le_ipv4() );
    sss = string.format( "%d.%d.%d.%d", 
          tvb( off + 3, 1 ):uint(),
          tvb( off + 2, 1 ):uint(),
          tvb( off + 1, 1 ):uint(),
          tvb( off + 0, 1 ):uint());
    pp = tvb( off + 4, 2 ):uint();
  end
  ss = string.format( "%s:%d", ss, pp );
  if ss:gsub( "[%.%d%:]", "" ) ~= "" then
    ss = string.format( "%s(%s:%d)", ss, sss, pp );
  end
  return ss, 4 + 2;
end

function FormatEx.float( tvb, off, size, func, root )
  if func and func ~= root.add then
    return tvb( off, 4 ):le_float(), 4;
  else
    return tvb( off, 4 ):float(), 4;
  end
end

function FormatEx.string( tvb, off, size, func, root )
  local maxlimit = tvb:len() - off;
  size = size or maxlimit;

  if size > maxlimit or size < 0 then
    return error( string.format( "FormatEx size error : @%d %d > %d",
      off, size, maxlimit ) );
  end
  
  local realsize = size;
  local add = "";
  if size > StringLimitMax then
    add = LimitAdd;
    size = StringLimitMax - #add;
  end

  return tvb:raw( off, size ) .. add, realsize;
end

function FormatEx.bytes( tvb, off, size, func, root )
  local maxlimit = tvb:len() - off;
  size = size or maxlimit;

  if size > maxlimit or size < 0 then
    return error( string.format( "FormatEx size error : @%d %d > %d",
      off, size, maxlimit ) );
  end
  
  local realsize = size;
  local add = "";
  if size > ( StringLimitMax // 2 ) then
    add = LimitAdd;
    size = ( StringLimitMax - #add ) // 2;
  end

  return bin2hex( tvb:raw( off, size ) ) .. add, realsize;
end

function FormatEx.stringz( tvb, off, size, func, root )
  local maxlimit = tvb:len() - off;
  local size = tvb:raw( off ):find( "\x00", 1, true ) or maxlimit;

  local realsize = size;
  local add = "";
  if size > StringLimitMax then
    add = LimitAdd;
    size = StringLimitMax - #add;
  end

  return tvb:raw( off, size ) .. add, realsize;
end

local function get_line_string( ls, x, tvb, off, size, func, root )
  local fmt;
  if x then
    x = 0;
    fmt = string.format( "(%%0%dx)", ls * 2 );
  else
    x = ls;
    fmt = string.format( "[%%0%dx]", ls * 2 );
  end
  local size;
  if func and func ~= root.add then
    size = tvb( off, ls ):le_uint();
  else
    size = tvb( off, ls ):uint();
  end

  local maxlimit = tvb:len() - off;
  local realsize = size + ls - x;
  if realsize > maxlimit then
    return error( string.format( "FormatEx size overload : @%d %d > %d",
      off, realsize, maxlimit ) );
  end

  size = size - x;
  local preadd = string.format( fmt, size );
  local add = "";
  if size > StringLimitMax - #preadd then
    add = LimitAdd;
    size = StringLimitMax - #preadd - #add;
  end

  return preadd .. tvb:raw( off + ls, size ) .. add, realsize;
end

function FormatEx.bxline_string( tvb, off, size, func, root )
  return get_line_string( 1, true, tvb, off, size, func, root );
end
function FormatEx.bline_string( tvb, off, size, func, root )
  return get_line_string( 1, false, tvb, off, size, func, root );
end
function FormatEx.wxline_string( tvb, off, size, func, root )
  return get_line_string( 2, true, tvb, off, size, func, root );
end
function FormatEx.wline_string( tvb, off, size, func, root )
  return get_line_string( 2, false, tvb, off, size, func, root );
end
function FormatEx.dxline_string( tvb, off, size, func, root )
  return get_line_string( 4, true, tvb, off, size, func, root );
end
function FormatEx.dline_string( tvb, off, size, func, root )
  return get_line_string( 4, false, tvb, off, size, func, root );
end

local function get_line_bytes( ls, x, tvb, off, size, func, root )
  local fmt;
  if x then
    x = 0;
    fmt = string.format( "(%%0%dx)", ls * 2 );
  else
    x = ls;
    fmt = string.format( "[%%0%dx]", ls * 2 );
  end
  local size;
  if func and func ~= root.add then
    size = tvb( off, ls ):le_uint();
  else
    size = tvb( off, ls ):uint();
  end

  local maxlimit = tvb:len() - off;
  local realsize = size + ls - x;
  if realsize > maxlimit then
    return error( string.format( "FormatEx size overload : @%d %d > %d",
      off, realsize, maxlimit ) );
  end

  size = size - x;
  local preadd = string.format( fmt, size );
  local add = "";
  if size > ( ( StringLimitMax - #preadd ) // 2 ) then
    add = LimitAdd;
    size = ( StringLimitMax - #preadd - #add ) // 2;
  end

  return preadd .. bin2hex( tvb:raw( off + ls, size ) ) .. add, realsize;
end

function FormatEx.bxline_bytes( tvb, off, size, func, root )
  return get_line_bytes( 1, true, tvb, off, size, func, root );
end
function FormatEx.bline_bytes( tvb, off, size, func, root )
  return get_line_bytes( 1, false, tvb, off, size, func, root );
end
function FormatEx.wxline_bytes( tvb, off, size, func, root )
  return get_line_bytes( 2, true, tvb, off, size, func, root );
end
function FormatEx.wline_bytes( tvb, off, size, func, root )
  return get_line_bytes( 2, false, tvb, off, size, func, root );
end
function FormatEx.dxline_bytes( tvb, off, size, func, root )
  return get_line_bytes( 4, true, tvb, off, size, func, root );
end
function FormatEx.dline_bytes( tvb, off, size, func, root )
  return get_line_bytes( 4, false, tvb, off, size, func, root );
end

function FormatEx.xdate( tvb, off, size, func, root )
  local t;
  if func and func ~= root.add then
    t = tvb( off, 4 ):le_uint();
  else
    t = tvb( off, 4 ):uint();
  end
  return os.date( "%Y/%m/%d %H:%M:%S", t ), 4;
end

function FormatEx.xtime( tvb, off, size, func, root )
  local t;
  if func and func ~= root.add then
    t = tvb( off, 4 ):le_uint();
  else
    t = tvb( off, 4 ):uint();
  end

  local s = t % 60;   t = t // 60;
  local m = t % 60;   t = t // 60;
  local h = t % 24;   t = t // 24;

  return string.format( "%dday %d:%d:%d", t, h, m, s), 4;
end

function FormatEx.xcapacity( tvb, off, size, func, root )
  local x;
  -- 由于低版本wireshark在操作64时，只会读8byte，故采用一个笨办法
  local x = UInt64.new( 0 );
  local step = UInt64.new( 0x100 );
  local mul = UInt64.new( 1 );
  for k = 1, size do
    local f = tvb( off + k - 1, 1 ):uint();
    f = UInt64.new( f );
    if func and func ~= root.add then
      x = f * mul + x;
      mul = mul * step;
    else
      x = x * step + f;
    end
  end

  local t = x:higher() / 0x100;
  if t >= 1 then
    return string.format( "%.2f", t ) .. " TB", size; 
  end

  local g = ( x:higher() * 0x10 / 4 ) + ( x:lower() / 0x40000000 );
  if g > 1 then
    return  string.format( "%.2f", g ) .. " GB", size; 
  end

  local m = x:lower() / 0x100000;
  if m > 1 then
    return  string.format( "%.2f", m ) .. " MB", size; 
  end

  local k = x:lower() / 0x400;
  if k > 1 then
    return  string.format( "%.2f", k ) .. " KB", size; 
  end
  return  string.format( "%d", x:lower() ) .. " B", size; 
end