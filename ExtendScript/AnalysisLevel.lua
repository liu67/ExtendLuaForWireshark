--[=======[
-------- -------- -------- --------
         �����ȼ�����
-------- -------- -------- --------
]=======]

--[=======[
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
]=======]

main_analysis_level = "detail";

analysis_level_tables =
  {
  simple  = 1,        s = 1,
  more    = 2,        m = 2,
  complex = 3,        c = 3,
  detail  = 4,        d = 4,
  };

alvlS = analysis_level_tables.simple;
alvlM = analysis_level_tables.more;
alvlC = analysis_level_tables.complex;
alvlD = analysis_level_tables.detail;