﻿# xlua

---- ---- ---- ----

由于Lua没有强制类型，扩展函数以伪代码形式展示

注意到所有简化函数定义为

```
functionXX            = function( ... ) return functionX                   ( ... ); end 
```
而不定义为

```
functionXX            = functionX;
```
是考虑当`functionX`被修改时，`functionXX`能随之改变。此为记

---- ---- ---- ----

## AES

- AES数据块大小 16 byte 。不对齐部分不处理，忽略之
- 提供的KEY长度不足 16/24/32 byte时，以\x00补足（保证set key不出错）
- 提供的向量长度不足 16 byte时，以\x00补足

### AES/ECB/PKCS7Padding

```
string    aes_ecb_pkcs7padding_encrypt
                                    (
                                    string data,
                                    string key
                                    );
string    aes.ecb.p7enc             ( ... );
string    string:aes_ecb_p7_enc     ( ... );

string    aes_ecb_pkcs7padding_decrypt
                                    (
                                    string data,
                                    string key
                                    );
string    aes.ecb.p7dec             ( ... );
string    string:aes_ecb_p7_dec     ( ... );
```

### AES/CBC/PKCS7Padding

```
string    aes_cbc_pkcs7padding_encrypt
                                    (
                                    string data,
                                    string key,
                                    string ivec = "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
                                    );
string    aes.cbc.p7enc             ( ... );
string    string:aes_cbc_p7_enc     ( ... );

string    aes_cbc_pkcs7padding_decrypt
                                    (
                                    string data,
                                    string key,
                                    string ivec = "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
                                    );
string    aes.cbc.p7dec             ( ... );
string    string:aes_cbc_p7_dec     ( ... );
```

### AES/ECB/NoPadding

```
string    aes_ecb_encrypt           ( string data, string key );
string    aes.ecb.enc               ( ... );
string    aes.ecb.enc               ( ... );

string    aes_ecb_decrypt           ( string data, string key );
string    string:aes_ecb_enc        ( ... );
string    string:aes_ecb_dec        ( ... );
```

### AES/CBC/NoPadding

```
string    aes_cbc_encrypt           (
                                    string data,
                                    string key,
                                    string ivec = "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
                                    );
string    aes.cbc.enc               ( ... );
string    string:aes_cbc_enc        ( ... );

string    aes_cbc_decrypt           (
                                    string data,
                                    string key,
                                    string ivec = "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
                                    );
string    aes.cbc.dec               ( ... );
string    string:aes_cbc_dec        ( ... );
```

---- ---- ---- ----

## xrand

```
number    xrand           ( number mod = 0 );
```

---- ---- ---- ----

## strxor

- xor因子可以为字符串原始值如"\x12\x34"
- 当xor因子为数值时，将转换成小端序的字符串原始值，并去除高位00。如0x00001234等价于"\x34\x12"
- 请不要提供0值，因为没有意义，函数会视xor因子为空串
- xor因子为空串时，函数直接返回data

```
string    strxor          ( string data, number|string xor );
string    string:xor      ( ... );
```

---- ---- ---- ----

## MD5

```
string    md5             ( string data );
string    string:md5      ( );
```

---- ---- ---- ----

## CRC

```
number    crc16           ( string data );
number    crc32           ( string data );
number    crc64           ( string data );
number    crcccitt        ( string data );

number    string:crc16    ( );
number    string:crc32    ( );
number    string:crc64    ( );
number    string:crcccitt ( );
```

---- ---- ---- ----

## varint

```
string    tovarint        ( number value, bool signed = false );

// 当返回 usebytes == 0时，表示操作失败
number value, number usebytes
          getvarint       ( string data, bool signed = false );
number value, number usebytes
          string:getvarint( ... );
```

---- ---- ---- ----

## TEA

```
string    TeanEncrypt     ( string data, string key );
string    TeanDecrypt     ( string data, string key );
string    TeaEncrypt      (
                          string  data,
                          string  key,
                          number  delta,
                          number  round
                          );
string    TeaDecrypt      (
                          string  data,
                          string  key,
                          number  delta,
                          number  round
                          );
string    TeanEncipher    ( string data, string key );
string    TeanDecipher    ( string data, string key );
string    XTeanEncrypt    ( string data, string key );
string    XTeanDecrypt    ( string data, string key );
string    XxTeaEncrypt    ( string data, string key );
string    XxTeaDecrypt    ( string data, string key );

string    string:tean_enc ( ... );
string    string:tean_dec ( ... );
string    string:tea_enc  ( ... );
string    string:tea_dec  ( ... );
string    string:tean_enr ( ... );
string    string:tean_der ( ... );
string    string:xtean_enc( ... );
string    string:xtean_dec( ... );
string    string:xxtea_enc( ... );
string    string:xxtea_dec( ... );
```

---- ---- ---- ----

## AES RAW

```
string    aes_encrypt     ( string data, string key );
string    aes_decrypt     ( string data, string key );

string    string:aes_enc  ( ... );
string    string:aes_dec  ( ... );
```

---- ---- ---- ----

## DES RAW

```
string    des_encrypt     ( string data, string key );
string    des_decrypt     ( string data, string key );

string    string:des_enc  ( string key );
string    string:des_dec  ( string key );
```

---- ---- ---- ----

## HEX & BIN

### hex2bin

```
string    hex2bin         (
                          string   hex,
                          bool     errexit       = false,
                          bool     errbreak      = false
                          );
string    string:hex2bin  ( ... );
string    string.bins     ( ... );
```

### bin2hex

```
string    bin2hex         ( string data, bool isup = false );
string    string:bin2hex  ( ... );
```

### showbin

为了简化参数，设计flag

- flag & 1 表示ASCII
- flag & 2 表示Unicode
- flag & 8 表示UTF8
- flag & 4 表示isup == false
- flag >= 0x10的部分被当作prews参数

```
string    showbin         ( string data, number flag = 1 );
string    string:showbin  ( ... );
string    string:show     ( ... );
```

---- ---- ---- ----

## ASCII & UCS2

```
string    ws2s            ( string s );
string    string:ws2s     ( );

string    s2ws            ( string ws );
string    string:s2ws     ( );
```

---- ---- ---- ----

## UTF8

```
string    utf82ws         ( string utf8 );
string    string:utf82ws  ( );

string    ws2utf8         ( string ws );
string    string:ws2utf8  ( );

string    utf82s          ( string utf8 );
string    string:utf82s   ( );

string    s2utf8          ( string s );
string    string:s2utf8   ( );
```

---- ---- ---- ----

## FILE

### readfile

- 读文件失败时，返回nil, 错误信息

```
string    readfile        ( string filename, string mode = "rb" );
string    string:read     ( ... );
```

### writefile

- 写文件失败时，返回错误信息

```
void      writefile       ( string data, string filename, string mode = "wb" );
void      string:write    ( ... );
```

---- ---- ---- ----

## BLOWFISH

- BLOWFISH数据块大小 8 byte 。不对齐部分不处理，忽略之
- 提供的向量长度不足 8 byte时，以\x00补足
- 注意不补充KEY

### BF/ECB/PKCS7Padding

```
string    blowfish_ecb_pkcs7padding_encrypt
                                    (
                                    string data,
                                    string key
                                    );
string    blowfish.ecb.p7enc        ( ... );
string    string:bf_ecb_p7_enc      ( ... );

string    blowfish_ecb_pkcs7padding_decrypt
                                    (
                                    string data,
                                    string key
                                    );
string    blowfish.ecb.p7dec        ( ... );
string    string:bf_ecb_p7_dec      ( ... );
```

### BF/CBC/PKCS7Padding

```
string    blowfish_cbc_pkcs7padding_encrypt
                                    (
                                    string data,
                                    string key,
                                    string ivec = "\0\0\0\0\0\0\0\0"
                                    );
string    blowfish.cbc.p7enc        ( ... );
string    string:bf_cbc_p7_enc      ( ... );

string    blowfish_cbc_pkcs7padding_decrypt
                                    (
                                    string data,
                                    string key,
                                    string ivec = "\0\0\0\0\0\0\0\0"
                                    );
string    blowfish.cbc.p7dec        ( ... );
string    string:bf_cbc_p7_dec      ( ... );
```

### BF/ECB/NoPadding

```
string    blowfish_ecb_encrypt      ( string data, string key );
string    blowfish.ecb.enc          ( ... );
string    string:bf_ecb_enc         ( ... );

string    blowfish_ecb_decrypt      ( string data, string key );
string    blowfish.ecb.enc          ( ... );
string    string:bf_ecb_dec         ( ... );
```

### BF/CBC/NoPadding

```
string    blowfish_cbc_encrypt      (
                                    string data,
                                    string key,
                                    string ivec = "\0\0\0\0\0\0\0\0"
                                    );
string    blowfish.cbc.enc          ( ... );
string    string:bf_cbc_enc         ( ... );

string    blowfish_cbc_decrypt      (
                                    string data,
                                    string key,
                                    string ivec = "\0\0\0\0\0\0\0\0"
                                    );
string    blowfish.cbc.dec          ( ... );
string    string:bf_cbc_dec         ( ... );
```

---- ---- ---- ----

## DES

- DES数据块大小 8 byte 。不对齐部分不处理，忽略之
- 提供的KEY长度不足 8 byte时，以\x00补足
- 提供的向量长度不足 8 byte时，以\x00补足

### DES/ECB/PKCS7Padding

```
string    des_ecb_pkcs7padding_encrypt
                                    (
                                    string data,
                                    string key
                                    );
string    des.ecb.p7enc             ( ... );
string    string:des_ecb_p7_enc     ( ... );

string    des_ecb_pkcs7padding_decrypt
                                    (
                                    string data,
                                    string key
                                    );
string    des.ecb.p7dec             ( ... );
string    string:des_ecb_p7_dec     ( ... );
```

### DES/CBC/PKCS7Padding

```
string    des_cbc_pkcs7padding_encrypt
                                    (
                                    string data,
                                    string key,
                                    string ivec = "\0\0\0\0\0\0\0\0"
                                    );
string    des.cbc.p7enc             ( ... );
string    string:des_cbc_p7_enc     ( ... );

string    des_cbc_pkcs7padding_decrypt
                                    (
                                    string data,
                                    string key,
                                    string ivec = "\0\0\0\0\0\0\0\0"
                                    );
string    des.cbc.p7dec             ( ... );
string    string:des_cbc_p7_dec     ( ... );
```

### DES/NCBC/PKCS7Padding

```
string    des_ncbc_pkcs7padding_encrypt
                                    (
                                    string data,
                                    string key
                                    string ivec = "\0\0\0\0\0\0\0\0"
                                    );
string    des.ncbc.p7enc            ( ... );
string    string:des_ncbc_p7_enc    ( ... );

string    des_ncbc_pkcs7padding_decrypt
                                    (
                                    string data,
                                    string key
                                    string ivec = "\0\0\0\0\0\0\0\0"
                                    );
string    des.ncbc.p7dec            ( ... );
string    string:des_ncbc_p7_dec    ( ... );
```

### 3DES/ECB/PKCS7Padding

- 3DES的KEY输入要求：KEY == K1 .. K2 .. K3
- K1不存在或不足时，以\x00补齐
- K2不存在时，K2 == K1。不足时，以\x00补齐
- K3不存在时，K3 == K1。不足时，以\x00补齐

```
string    des_ecb3_pkcs7padding_encrypt
                                    (
                                    string data,
                                    string key
                                    );
string    des.ecb3.p7enc            ( ... );
string    string:des_ecb3_p7_enc    ( ... );

string    des_ecb3_pkcs7padding_decrypt
                                    (
                                    string data,
                                    string key
                                    );
string    des.ecb3.p7dec            ( ... );
string    string:des_ecb3_p7_dec    ( ... );
```

### DES/ECB/NoPadding

```
string    des_ecb_encrypt           ( string data, string key );
string    des.ecb.enc               ( ... );
string    des.ecb.enc               ( ... );

string    des_ecb_decrypt           ( string data, string key );
string    string:des_ecb_enc        ( ... );
string    string:des_ecb_dec        ( ... );
```

### DES/CBC/NoPadding

```
string    des_cbc_encrypt           (
                                    string data,
                                    string key,
                                    string ivec = "\0\0\0\0\0\0\0\0"
                                    );
string    des.cbc.enc               ( ... );
string    string:des_cbc_enc        ( ... );

string    des_cbc_decrypt           (
                                    string data,
                                    string key,
                                    string ivec = "\0\0\0\0\0\0\0\0"
                                    );
string    des.cbc.dec               ( ... );
string    string:des_cbc_dec        ( ... );
```

### DES/NCBC/NoPadding

``` 
string    des_ncbc_encrypt          (
                                    string data,
                                    string key,
                                    string ivec = "\0\0\0\0\0\0\0\0"
                                    );
string    des.ncbc.enc            ( ... );
string    string:des_ncbc_enc     ( ... );

string    des_ncbc_decrypt          (
                                    string data,
                                    string key,
                                    string ivec = "\0\0\0\0\0\0\0\0"
                                    );
string    des.ncbc.dec            ( ... );
string    string:des_ncbc_dec     ( ... );
```

### 3DES/ECB/NoPadding

```
string    des_ecb3_encrypt          ( string data, string key );
string    des.ecb3.enc            ( ... );
string    string:des_ecb3_enc     ( ... );

string    des_ecb3_decrypt          ( string data, string key );
string    des.ecb3.enc            ( ... );
string    string:des_ecb3_dec     ( ... );
```

---- ---- ---- ----

## MEM

- 所有指针以interger形式传输，而不是采用light userdata形式，是考虑指针运算，格式化输出等便利
- 操作失败，抛出错误

```
string    readmem         ( void* lpmem, number size = 1 );

void      writemem        ( void* lpmem, string writebytes );

void*     newmem          ( number size );  // 以byte计

bool      deletemem       ( void* lpmem );  // 释放由newmem申请的内存

/*
  参数value不存在时，视为读内存操作，成功则返回相应值，失败则抛出错误
  参数value存在时，视为读内存操作，成功则无返回值，失败则抛出错误
*/
          mkb             ( void* lpmem [, number value] ); // 读/写无符号byte值，小端
          mkB             ( void* lpmem [, number value] ); // 读/写无符号byte值，大端
          mkbs            ( void* lpmem [, number value] ); // 读/写有符号byte值，小端
          mkBs            ( void* lpmem [, number value] ); // 读/写有符号byte值，大端

          mkw             ( void* lpmem [, number value] ); // 读/写无符号word值，小端
          mkW             ( void* lpmem [, number value] ); // 读/写无符号word值，大端
          mkws            ( void* lpmem [, number value] ); // 读/写有符号word值，小端
          mkWs            ( void* lpmem [, number value] ); // 读/写有符号word值，大端

          mkd             ( void* lpmem [, number value] ); // 读/写无符号dword值，小端
          mkD             ( void* lpmem [, number value] ); // 读/写无符号dword值，大端
          mkds            ( void* lpmem [, number value] ); // 读/写有符号dword值，小端
          mkDs            ( void* lpmem [, number value] ); // 读/写有符号dword值，大端

          mkq             ( void* lpmem [, number value] ); // 读/写无符号qword值，小端
          mkQ             ( void* lpmem [, number value] ); // 读/写无符号qword值，大端
          mkqs            ( void* lpmem [, number value] ); // 读/写有符号qword值，小端
          mkQs            ( void* lpmem [, number value] ); // 读/写有符号qword值，大端

          mkf             ( void* lpmem [, number value] ); // 读/写float值，小端
          mkF             ( void* lpmem [, number value] ); // 读/写float值，大端

          mkdb            ( void* lpmem [, number value] ); // 读/写double值，小端
          mkDBs           ( void* lpmem [, number value] ); // 读/写double值，大端

number    bswap           ( number value, number size = 4|8 ); // 指定翻转数据
number    bswap_byte      ( number value );
number    bswap_word      ( number value );
number    bswap_dword     ( number value );
number    bswap_qword     ( number value );
```

---- ---- ---- ----

## HOOK

- 操作失败，抛出错误

```
void*     hook            (
                          void*     hookmem,
                          number    hooksize,
                          string    data_descibe,
                          string    len_descibe,
                          bool      logfirst
                          );
void*     hook            (
                          void*     hookmem,
                          string    data_descibe,
                          string    len_descibe,
                          bool      calltable_offset,
                          bool      logfirst
                          );
void      unhook          ( void*   node ); // 当unhook不给node参数时，卸载全部hook
```

---- ---- ---- ----

## RSA

- RsaKey操作失败，抛出错误。加解密失败，仅返回空串
- 填充模式：PKCS1Padding

```
private:  RsaKey;

void      RsaKey:__gc               ( );
string    RsaKey:__tostring         ( );  // 返回"RsaKey*:####"

RsaKey    rsa_open_public_key       ( string filename );
RsaKey    rsa.pub.open              ( ... );

RsaKey    rsa_set_public_key        ( string rsakey );
RsaKey    rsa.pub.set               ( ... );

RsaKey    rsa_open_private_key      ( string filename );
RsaKey    rsa.prv.open              ( ... );

RsaKey    rsa_set_private_key       ( string rsakey );
RsaKey    rsa.prv.set               ( ... );

string    rsa_public_encrypt        ( string data, RsaKey key );
string    rsa.pub.enc               ( ... );
string    string:rsa_pub_enc        ( ... );

string    rsa_public_decrypt        ( string data, RsaKey key );
string    rsa.pub.dec               ( ... );
string    string:rsa_pub_dec        ( ... );


string    rsa_private_encrypt       ( string data, RsaKey key );
string    rsa.prv.enc               ( ... );
string    string:rsa_prv_enc        ( ... );

string    rsa_private_decrypt       ( string data, RsaKey key );
string    rsa.prv.dec               ( ... );
string    string:rsa_prv_dec        ( ... );
```

---- ---- ---- ----

## Base64

- 加解密失败，返回空串

```
string    base64_encode             ( string data );
string    base64_decode             ( string data );
string    string:b64_enc            ( );
string    string:b64_dec            ( );
```

---- ---- ---- ----

## HMAC

- hmac支持的algo有"sha512/sha256/sha1/md5/sha224/sha384"
- algo无视大小写，无法支持或识别时，抛出错误

```
string    hmac                      (
                                    string    data,
                                    string    key,
                                    string    algo
                                    );
string    string:hmac               ( ... );
```

---- ---- ---- ----

## SHA

- SHA支持的algo有：256 / 512 / 1 / 0 / 224 / 384
- algo无法支持或识别时，抛出错误

```
string    sha                       ( string data, number alog = 256 );
string    string:sha                ( ... );

//以下是SHA便捷函数组
string    sha1                      ( string data );
string    sha224                    ( string data );
string    sha256                    ( string data );
string    sha384                    ( string data );
string    sha512                    ( string data );

string    string:sha1               ( );
string    string:sha224             ( );
string    string:sha256             ( );
string    string:sha384             ( );
string    string:sha512             ( );
```

---- ---- ---- ----

## PE

- Lua5.3以下无法正确使用此函数

```
table     PE              ( number hmod = nullptr );
table     PE              ( string mod_name );

/*
  返回值解析如下：
  {
  HMODULE                 hmod,
  const IMAGE_DOS_HEADER* dos_head,
  bool                    ispe,
  const IMAGE_NT_HEADERS* pe_head,
  void*                   entry,
  table                   image,
    {
    void*                 start,
    void*                 end,
    size_t                size,
    }
  table                   code,
    {
    void*                 start,
    void*                 end,
    size_t                size,
    }
  }
*/
```

---- ---- ---- ----

## UDP

- UDP操作失败将抛出异常，同时!!释放对象!!

```
Private:  UDP;
```

- bind_port不为0时，无视ip、port，直接绑定本地端口
- 当ip == "0.0.0.0"且port != "0"时，视为bind_port = port，也绑定指定端口
- 当ip != "0.0.0.0"时，将与指定IP通讯
- 当不绑定本地端口时，默认接收延时5s
- ip为数值时，视为大端序，即0x0100007F表示"127.0.0.1"
```
UDP       udp_new         (
                          string|number   ip    = "0.0.0.0",
                          string|number   port  = "0",
                          string|number   bind_port = "0"
                          );
```

- 获取本地/对端SOCK信息
- 返回IP数值大端序，即0x0100007F表示"127.0.0.1"
- 注意：对象未发送任何数据前，返回的数据可能不正确
```
string ip, string port, number ip, number port
          UDP:getsockname ( );

string ip, string port, number ip, number port
          UDP:getpeername ( );
```

```
stirng    UDP:type        ( );  // 返回对象类型，即"UDP"
void      UDP:close       ( );
void      UDP:__gc        ( );
```

- 返回如示：UDP{server/client}:########    local_ip:port >> remote_ip:port
```
string    UDP:__tostring  ( );
```

- 接收延时，毫秒计（默认取消延时）
```
UDP       UDP:settimeout  ( number timeout = -1 );
```

```
UDP       UDP:broadcast   ( bool set = false );
```

- 当不提供ip、port时，默认连接初始化时指定的IP
```
UDP       UDP:send        (
                          string          data,
                          string|number   ip    = "0.0.0.0",
                          string|number   port  = "0"
                          );
```

- 当不提供size时，默认提供0x800的接收缓冲区
- 超时返回nil, "timeout"
- 接收缓冲区不足返回nil, "msgsize"
- 目标不可达返回nil, "unreachable"
```
string data, string ip, string port, number ip, number port
          UDP:recv        ( number size = 0x800 );
```

---- ---- ---- ----

## TCP

- TCP操作失败将抛出异常，同时!!释放对象!!

```
Private:  TCP;
```

- bind_port不为0时，无视ip、port，直接绑定本地端口
- 当ip == "0.0.0.0"且port != "0"时，视为bind_port = port，也绑定指定端口
- 当ip != "0.0.0.0"时，将与指定IP通讯
- 当不绑定本地端口时，默认接收延时5s
- ip为数值时，视为大端序，即0x0100007F表示"127.0.0.1"
- NonBlockConnect设置连接无阻塞模式（默认连接阻塞）
```
TCP       tcp_new         (
                          string|number ip    = "0.0.0.0"
                          string|number port  = "0",
                          string|number bind_port = "0",
                          bool          NonBlockConnect = false
                          );
```

- 获取本地/对端SOCK信息
- 返回IP数值大端序，即0x0100007F表示"127.0.0.1"
```
string ip, string port, number ip, number port
          TCP:getsockname ( );

string ip, string port, number ip, number port
          TCP:getpeername ( );
```

```
stirng    TCP:type        ( );  // 返回对象类型，即"TCP"
void      TCP:close       ( );
void      TCP:__gc        ( );
```

- 返回如示：UDP{server/client}:########    local_ip:port >> remote_ip:port
```
string    TCP:__tostring  ( );
```

- 以下函数，Server不支持
- 接收延时，毫秒计（默认取消延时）
```
TCP       TCP:settimeout  ( int timeout = -1 );
TCP       TCP:broadcast   ( bool set = false );
TCP       TCP:send        ( string data );
```

- 当不提供size时，默认提供0x800的接收缓冲区
- 超时返回nil, "timeout"
```
string    TCP:recv        ( number size = 0x800 );
```

- 检测NonBlockConnect的TCP是否连接成功（成功后，自动设置阻塞）
```
bool      TCP:check       ( );
```

- 以下函数，Client不支持

- 当不提供timeout时，默认超时值-1，即阻塞直到连接发生
- 当提供timeout(毫秒计)时，阻塞指定时间，直到连接发生或超时返回
- 连接发生时，返回新连接的TCP对象
- 超时返回nil, "timeout"
```
TCP       TCP:accept      ( number timeout == -1 );
```

---- ---- ---- ----

## transip

```
string    transip         ( number ip, bool bigendian = false ); // 显示示例：127.0.0.1
string    transip         ( string ip, bool bigendian = false ); // 显示示例：0x7F000001
```
---- ---- ---- ----

## dns

- 返回第一个table是ip字符串列表
- 返回第二个table是ip值列表，大端序
- 失败则抛出错误

```
table, table
          dns             ( string host );
```

---- ---- ---- ----

## Windows API

```
void      Sleep           ( number ms = 0 );    // 暂停线程ms毫秒，ms允许为空
number    GetTickCount    ( );                  // 获取系统启动时间毫秒数
        
// Lua5.3以下无法正确使用以下函数
HMODULE   GetModuleHandle ( string mod_name = "" );
HMODULE   LoadLibrary     ( string lib_name );  // 失败返回nil, errorcode
void      FreeLibrary     ( HMODULE mode );     // 失败返回errorcode
void*     GetProcAddress  ( HMODULE mode, string name );
```

---- ---- ---- ----

## xhttp

- 访问错误时，抛出错误

```
/*
options表可以设置如下参数(注意小写名称)：
  {
  ["connect_time_out"]  = number;   // 连接超时，毫秒计，默认20000，即20s
  ["time_out"]          = string;   // 访问超时，毫秒计，默认10000，即10s
  ["proxy"]             = string;   // 代理地址，如："127.0.0.1:8888"
                                    // 此项存在且不为空时，设置代理
  ["data"]              = string;   // post数据
                                    // 此项存在时，http访问为post。否则默认为get
  ["verbose"]           = bool;     // 细节展示，默认false不展示
  ["header"]            = table;    // http head。以  [键名] = 值  形式组表
  }

示例代码：

  local c, h, b = xhttp("http://www.qq.com");
  for k, v in pairs( h ) do
    xlog( "key:" .. k, "value:" .. v );
  end

  local c, h, b = xhttp("http://www.qq.com",
                        {
                        connect_time_out = 10000,
                        time_out = 500,
                        proxy = "127.0.0.1:8080",
                        data = "post data",
                        header =
                          {
                          xxx = "xxxx";
                          }
                        }
                       );
*/
number response_code, table response_headers, string response_body
          xhttp                     ( string url, table options = {} );
```

---- ---- ---- ----

## xlog

- 无条件输出debugview
- 注意，如果在加载前此函数被预定义，则使用预定义
```
void      xlog            ( ... );
```

- 此函数用于在xlog被替换的情况下，还可选择输出到debugview
```
void      dbgview         ( ... );
```

xlog_level用于控制输出

- "off"       // 屏蔽输出
- "fatal"     // 致命错误，程序无法继续执行
- "error"     // 反映错误，例如一些API的调用失败
- "warn"      // 反映某些需要注意的可能有潜在危险的情况，可能会造成崩溃或逻辑错误之类
- "info"      // 表示程序进程的信息
- "debug"     // 普通的调试信息，这类信息发布时一般不输出
- "trace"     // 最精细的调试信息，多用于定位错误，查看某些变量的值
- "on"        // 全输出（默认）
```
string    xlog_level;
```

- 根据xlog_level的动态调试等级，决定是否输出信息
- 函数组底层调用xlog输出信息，修改xlog函数能实现信息转向
```
void      xfail           ( ... );
void      xerr            ( ... );
void      xwarn           ( ... );
void      xinfo           ( ... );
void      xdbg            ( ... );
void      xtrace          ( ... );
```
- 将信息输出函数组加入string表
```
void      stirng:xlog     ( ... );
void      stirng:xfail    ( ... );
void      string:xerr     ( ... );
void      string:xwarn    ( ... );
void      string:xinfo    ( ... );
void      string:xdbg     ( ... );
void      string:xtrace   ( ... );
```

---- ---- ---- ----

## zlib

- 压缩/解压失败，返回nil & 错误码

```
string    zlib_compress   ( string data );
string    zlib_uncompress ( string data );
string    string:zcp      ( );
string    string:zup      ( );
```

---- ---- ---- ----

## gzip

- 压缩/解压失败，返回nil & 错误信息
- gzip解压时，尝试带head/不带head的gzip解压，以及deflate解压

```
string    gzip_compress   ( string data );
string    gzip_uncompress ( string data );
string    string:gzcp     ( );
string    string:gzup     ( );
```

-------- -------- -------- --------
         �����ȼ�����
-------- -------- -------- --------

��
  string      main_analysis_level = "detail"; --ȫ�ֽ����ȼ����ƣ�Ĭ��ϸ�����

    --�����ȼ���"simple"|"more"|"complex"|"detail"������ϸ���������������Ч������½�
    --�����ȼ������д��"s|m|c|d|S|M|C|D"
    
��
  table       analysis_level_tables =    
    {
    simple  = 1,        s = 1,
    more    = 2,        m = 2,
    complex = 3,        c = 3,
    detail  = 4,        d = 4,
    };                                  --�ȼ�ֵת��

  --�ṩ��д���ٽ���    
  const int   alvlS = analysis_level_tables.simple;
  const int   alvlM = analysis_level_tables.more;
  const int   alvlC = analysis_level_tables.complex;
  const int   alvlD = analysis_level_tables.detail;

-------- -------- -------- --------
         �Զ����ʽ��
-------- -------- -------- --------
--FormatEx�ṩͨ�õ��Զ����ʽ����������TreeAddExʹ��

��
  uint8;              --0x00(0)                     1 byte
  uint16;             --0x0000(0)                   2 byte
  uint24;             --0x000000(0)                 3 byte
  uint32;             --0x00000000(0)               4 byte
  uint64;             --0x0000000000000000(0)       8 byte
  int8;               --0x00(0)                     1 byte
  int16;              --0x0000(0)                   2 byte
  int24;              --0x000000(0)                 3 byte
  int32;              --0x00000000(0)               4 byte
  int64;              --0x0000000000000000(0)       8 byte

  bool;               --true|false                  1 byte
  ipv4;               --hostname(0.0.0.0)           4 byte
                        0.0.0.0         //��hostname�޷�ȷ��ʱ����ʾ
  ipv4_port;          --hostname:port(0.0.0.0:0)    6 byte
                        0.0.0.0:0       //��hostname�޷�ȷ��ʱ����ʾ
                        
  xipv4_port;         --hostname:port(0.0.0.0:0)    6 byte
                        0.0.0.0:0       //��hostname�޷�ȷ��ʱ����ʾ
                                        //�ֽ�˳�����ڱ�ʾport��ע��ip���ֽ���port�෴
  float;              --0.0             //���Ӵ�С��
  string;             --00000           //size == -1ʱ��ȡʣ����������
                                        //ע�����-1�����ฺֵ������
                                        //ע����ֵ����tvb��ΧҲ����
                                        //ע��size==0�����Թ������һ��tree
  bytes;              --000000          //size == -1ʱ��ȡʣ����������

  stringz;                              //������ָ��size����\0�ض�(����\0)������ȡʣ����������

  //xline��ʾhead�����������С
  bxline_string;      bline_string;                 1 + N byte
  wxline_string;      wline_string;                 2 + N byte
  dxline_string;      dline_string;                 4 + N byte

  bxline_bytes;       bline_bytes;                  1 + N byte
  wxline_bytes;       wline_bytes;                  2 + N byte
  dxline_bytes;       dline_bytes;                  4 + N byte

  xdate               --0000/00/00 00:00:00         4 byte
  xtime               --00day 00:00:00              4 byte
  xcapacity           --0.00T|0.00G|0.00M|0.00K|0.00B       N byte��ָ��

  ע�⣬��string��bytes�������ݹ���ʱ���᷵�ص��������ݽضϽ������0000...

-------- -------- -------- --------
         ProtoFieldEx����
-------- -------- -------- --------

��
    table protofieldsex, table protofields
              ProtoFieldEx              (
                                        [ string proto_pre_fix, ]
                                        table fields
                                        );                                [-1|2, +2, v]
        --�����Զ������ʽ����Field��
        --���ص�һ����������TreeAddEx���ʹ�ã���Ԫ�����
          {
          ["__fmt"] = fmt;
          [short_addr] = { type, field, exfunc },
          ...
          }
        --���صڶ���������proto.fields�ĸ�ֵ
          {
          [short_addr] = field,
          ...
          }
        --����proto_pre_fix�������abbrǰ׺��ǿ�ҽ������֮��
        --fields�Ĺ������£�
          {
            { func,         short_abbr,     name,         ... },
            ...
          };
          name����Ϊnil����ʱ��nameĬ��ʹ��short_abbr������
        --����Ԥ��ɨ��ȫ����ȡshort_abbr��name������󳤶ȣ��趨�����ʽ����������fix_name
          "%-##s    %-##s    "
        --���ڱ���ÿ��Ԫ�أ�������Ϊ֮����
            field = ProtoField[ func ]( proto_pre_fix .. short_abbr, fix_name, ... );
          ��funcδ��ʶ��ʱ��Ĭ��ʹ��string
          ����funcΪFormatEx���Ӻ�����������������Ӻ�����ʱ��Ĭ����Ϊstring
          ����TreeAddExʱ������ͬ
          �磺
          { "wxline_string", "wxline_msg", "MSG" }  --wxline_msg�������string
        --func���Ӵ�д��һ��ת����Сд��ʽ
        --�����Զ��ڱ�ǰ�������Ĭ��Ԫ��
          {
            { "uint8",      "xxoo_b",     "Byte",    base.HEX_DEC },
            { 'uint16',     "xxoo_w",     "Word",    base.HEX_DEC },
            { 'uint32',     "xxoo_d",     "Dword",   base.HEX_DEC },
            { 'uint64',     "xxoo_q",     "Qword",   base.HEX_DEC },
            { 'bytes',      "xxoo_a",     "Array"                 },
            { "string",     "xxoo_s",     "String"                },
          };
        --��Ԫ��====������֮===
        --!!!!��������fix_nameʱ����UTF8��ʽ�����ַ�����Ҫ��short_abbr��name����ΪUTF8!!!!
        --fields��func�����д��          
          {
          b   = "uint8",
          w   = "uint16",
          d   = "uint32",
          q   = "uint64",
          a   = "bytes",
          s   = "string",
          }

-------- -------- -------- --------
         TreeAddEx����
-------- -------- -------- --------

��
    int       TreeAddEx                 (
                                        table     protofieldsex,
                                        TreeItem  root,
                                        Tvb       tvb,
                                        int       off,
                                        ...
                                        );                                 [-4+, +1, v]
        --����Ҫ���Զ�������Ԫ��
        --protofieldsexΪProtoFieldEx���صĵ�һ����
        --�������� short_abbr, [size|format_function,] short_abbr, ... ��ʽ�ṩ
          �����ṩsize��format_functionʱ��ʹ��Ĭ�ϳ���
          ��ָ��fieldδ��Ĭ�ϳ���ʱ��ʹ��ʣ�����������
          ��ָ��size <= 0ʱ������������
          Ĭ�ϳ����б����£�          
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
        --abbr_name�ĵ�һ���ַ�����Ϊ'<'��'>'�����ڱ�ʾfield�Ĵ�С�ˣ�Ĭ�ϴ��
        --abbr_name�����Կո�ָ�ע�͡��ո��Ժ���������ݱ���Ϊ��ע�Ͷ�����֮
        --�������ش���������off
        --���ṩformat_functionʱ��������������ʽ����
          format_function( buf, off, nil, tree_add_func, root, field );
          ��������ڲ�ʹ����tree_add_func��Ӧ����off + size
          ����Ӧ����formatted_string, size��
          ����������Զ�����tree_add_func( root, field, buf( off, size ), formatted_string );

        --����ָ��abbr_name��protofieldsex����ƥ�䣬��ʱ�����¹���
          --���ṩformat_functionʱ��������������ʽ����
            format_function( buf, off, nil, tree_add_func, root, field );
            ��������ڲ�ʹ����tree_add_func��Ӧ����off + size
            ����Ӧ����formatted_string, size��
            ����������Զ�����tree_add_func( root, buf( off, size), prefix_string .. formatted_string );
          --��������ڿո��ָ�����ͣ�֧�����Ͳο�FormatEx

        ex:
          off = TreeAddEx( fieldsex, root, tvb, off,
            "xxoo_b",                   --��ʶ���short_abbr���ҿ�ʶ�𳤶�
            "xx", 2,                    --ǿ�Ƴ���
            "xxoo_s", format_xxx        --��ʶ���short_abbr��������ʶ�𳤶ȣ���Ҫ�Զ����ʽ��
            );
          --����Ч���������£�
          xxoo_b        Byte      :0x00
          xx            xx        :0x0000(0)
          xxoo_s        String    :xxxxxxxx

        ex:
          TreeAddEx( fieldsex, root, tvb, off,
            "*xxoo_b uint8",            --ָ����ʶ���֧�����ͣ����ú���ָ����С
            "*xxoo_s string", 6,        --֧�����Ϳ�ʶ�𣬵�ǿ��ָ����С
            "*xxoo_a", 5                --��ָ�����ͣ�Ĭ��bytes
            );
          --����Ч���������£�
          -             *xxoo_b   :0x00(0)
          -             *xxoo_s   :xxxxxx
          -             *xxoo_a   :##########
