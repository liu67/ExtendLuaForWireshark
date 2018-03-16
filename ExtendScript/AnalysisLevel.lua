--[=======[
---- ---- ---- ----

## Wireshark解析等级控制

- 解析等级（解析细度逐层提升，解析效率逐层下降）

```
enum analysis_level_enum =    
    {
    simple  = 1,
    more    = 2,
    complex = 3,
    detail  = 4,
    };
```

- 提供简写加速解析

```
const int   alvlS = analysis_level_enum.simple;
const int   alvlM = analysis_level_enum.more;
const int   alvlC = analysis_level_enum.complex;
const int   alvlD = analysis_level_enum.detail;
```

- 全局解析等级控制，默认细度最高

```
int       main_analysis_level = analysis_level_enum.detail;
```
]=======]

analysis_level_enum = setmetatable(
  {
    simple  = 1,
    more    = 2,
    complex = 3,
    detail  = 4,
  },
  {
    __newindex = function()
      return error( "ENUM禁止修改" );
    end;
  }
  );

alvlS = analysis_level_enum.simple;
alvlM = analysis_level_enum.more;
alvlC = analysis_level_enum.complex;
alvlD = analysis_level_enum.detail;

main_analysis_level = analysis_level_enum.detail;