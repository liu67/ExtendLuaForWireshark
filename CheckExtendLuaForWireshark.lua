local proto = Proto( "CheckLua", "CheckExtendLuaForWireshark" );

local Magic = "CheckExtendLuaForWireshark";

local fields =
  {
    { "int8",         "ci",   nil,          base.DEC },
    { "D",            "cu",   "<无符号数",  base.HEX_DEC },
    { "uint16",       "Cmd",  ">指令测试",  base.HEX_DEC, { [0x1122] = "●Send" } },
    { "uint64",       "u64",  "<uint64",    base.HEX_DEC },
    { "dxline_string","dxs",  ">带长度的串"  },
    { "bytes",        "ub",   "<指定长度的串" },
  };
  
local fieldsex, fields = ProtoFieldEx( "checklua.", fields );
proto.fields = fields;
fieldsex.__proto = proto;

local function dissector_heuristic( buf, pkg, root )
  if buf:len() < #Magic or
     buf:raw( 0, #Magic ) ~= Magic then
    return false;
  end

  pkg.cols.protocol:set( proto.name );

  pkg.cols.info:set( proto.description );

  local t = root:add( proto, buf(), proto.description );
  
  local off = #Magic;

  while off < buf:len() do
    local cmdsize = buf( off, 1 ):uint();
    off = off + 1;
    local cmd = buf:raw( off, cmdsize )
    off = off + cmdsize;
    local extype = buf( off, 1 ):uint()
    off = off + 1;
    if extype == 0 then
      off = TreeAddEx( fieldsex, t, buf, off, cmd );
    elseif extype == 1 then
      local size = buf( off, 2 ):uint();
      off = TreeAddEx( fieldsex, t, buf, off + 2, cmd, size );
    elseif extype == 2 then
      local size = buf( off, 2 ):uint();
      local func, err = load( buf:raw( off + 2, size ) );
      if not func then
        return error( "fail load function : " .. err );
      end
      off = TreeAddEx( fieldsex, t, buf, off + 2 + size, cmd, func );
    else
      return error( string.format( "unknow extype : %d", extype ) );
    end
  end

  return true;
end

function proto.dissector( buf, pkg, root )
  if dissector_heuristic( buf, pkg, root ) then
    return buf:len();
  end
end
  
proto:register_heuristic( "udp", dissector_heuristic );

---- ---- ---- ---- ---- ---- ---- ---- 
---- ---- ---- ---- ---- ---- ---- ---- 
---- ---- ---- ---- ---- ---- ---- ---- 

function CheckExtendLuaForWireshark()
  set_filter( "checklua" );
  apply_filter();
  local fakedns = hex2bin( "72d085800001000100000000037777770666616b65697403636f6d0000010001c00c0001000100000000000411223344" );
  local wsip = 0x11223344;

  local udp = udp_new( "8.8.8.8", "4210" );
  udp:send( fakedns, "8.8.8.8", "53" );

  local data = Magic;

  local strs = "0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF";
  local byts = hex2bin( strs );
  local mstrs = strs:sub( 1, 4 );
  local mbyts = byts:sub( 1, 4 );

  local function addit( fmt, cmd, extype, ... )
    data = data .. string.pack( ">s1 B" .. fmt, cmd, extype, ... );
  end

  addit( ">b",    ">ci  int8",  0, -11 );
  addit( "<I4",   "<cu  D",     0, 0x11223344 );
  addit( ">I2",   ">Cmd W",     0, 0x1122 );
  addit( "<I8",   "<u64 Q",     0, 0x1122334455667788 );
  addit( ">s4",   ">dxs dxline_string", 0, mstrs );
  addit( ">H c" .. #mbyts, "<ub A", 1, #mbyts, mbyts );


  addit( ">H",    "- string",   1, 0 );    -- 空串分隔
  addit( ">I1",   ">xxoo_b",    0, 0x11 );
  addit( "<I2",   "<xxoo_w",    0, 0x1122 );
  addit( ">I4",   ">xxoo_d",    0, 0x11223344 );
  addit( "<I8",   "<xxoo_q",    0, 0x1122334455667788 );
  addit( ">H c" .. #mbyts, "<xxoo_a", 1, #mbyts, mbyts );
  addit( ">H c" .. #mstrs, "<xxoo_s", 1, #mstrs, mstrs );
  addit( ">H c" .. #mbyts, "<xxoo_x", 1, #mbyts, mbyts );

  local function addv( fmt, cmd, ... )
    local endian = cmd:sub( 1, 1 );
    local cmd = cmd:sub( 2 );
    addit( fmt, endian .. endian .. cmd .. " " .. cmd, 0, ... );
  end


  addit( ">H",    "- string",   1, 0 );
  addv( ">I1",    ">uint8",     0x11 );
  addv( "<I2",    "<uint16",    0x1122 );
  addv( ">I3",    ">uint24",    0x112233 );
  addv( "<I4",    "<uint32",    0x11223344 );
  addv( ">I8",    ">uint64",    0x1122334455667788 );

  addv( "<i1",    "<int8",      -11 );
  addv( ">i2",    ">int16",     -1122 );
  addv( "<i3",    "<int24",     -112233 );
  addv( ">i4",    ">int32",     -11223344 );
  addv( "<i8",    "<int64",     -1122334455667788 );


  addit( ">H",    "- string",   1, 0 );
  addv( ">B",     ">bool",      1 );
  local func = string.dump( FormatEx.bool, true );
  addit( ">s2 B", "<bool",      2, func, 0 );     --测试带函数


  addit( ">H",    "- string",   1, 0 );
  addv( ">I4",    ">ipv4",      wsip );
  addv( "<>I4",   "<ipv4",      wsip );
  addv( ">I4>I2", ">ipv4_port", wsip, 1122 );
  addv( ">I4<I2", "<xipv4_port", wsip, 1122 );


  addit( ">H",    "- string",   1, 0 );
  addv( ">f",     ">float",     1.1 );

  local function adds( fmt, cmd, size, ... )
    local endian = cmd:sub( 1, 1 );
    local cmd = cmd:sub( 2 );
    addit( ">H" .. fmt, endian .. endian .. cmd .. " " .. cmd, 1, size, ... );
  end

  addit( ">H",    "- string",   1, 0 );
  adds( ">c" .. #strs, ">string", #strs, strs );
  adds( ">c" .. #byts, ">bytes", #byts, byts );
  addv( ">c" .. ( #strs + 1 ), ">stringz", strs .. "\x00" );

  addit( ">H",    "- string",   1, 0 );
  addv( ">s1",    ">bxline_string", strs );
  addv( "<s2",    "<wxline_string", mstrs );
  addv( ">s4",    ">dxline_string", mstrs );

  addv( ">I1 c" .. #mstrs, ">bline_string", #mstrs + 1, mstrs );
  addv( "<I2 c" .. #mstrs, "<wline_string", #mstrs + 2, mstrs );
  addv( ">I4 c" .. #mstrs, ">dline_string", #mstrs + 4, mstrs );

  addit( ">H",    "- string",   1, 0 );
  addv( ">s1",    ">bxline_bytes", byts );
  addv( "<s2",    "<wxline_bytes", mbyts );
  addv( ">s4",    ">dxline_bytes", mbyts );

  addv( ">I1 c" .. #mbyts, ">bline_bytes", #mbyts + 1, mbyts );
  addv( "<I2 c" .. #mbyts, "<wline_bytes", #mbyts + 2, mbyts );
  addv( ">I4 c" .. #mbyts, ">dline_bytes", #mbyts + 4, mbyts );

  addit( ">H",    "- string",   1, 0 );
  addv( ">I4",    ">xdate",     1320981071 );
  addv( "<I4",    "<xtime",     990671 );

  addit( ">H",    "- string",   1, 0 );
  adds( ">I1",    ">xcapacity", 1, 11 );
  adds( "<I2",    "<xcapacity", 2, 11376 );
  adds( ">I4",    ">xcapacity", 4, 11649679 );
  adds( "<I8",    "<xcapacity", 8, 11929271664 );
  adds( ">I8",    ">xcapacity", 8, 12215574184591 );

  udp:send( data );
  udp:close();
end

chkit = CheckExtendLuaForWireshark;