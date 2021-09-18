CREATE OR REPLACE PROCEDURE TEXT_TO_CMD_P(I_db_Path       IN VARCHAR2,
                                       l_cmd_text      IN VARCHAR2,
                                       I_file_name     IN VARCHAR2,
                                       I_run           in varchar2)
 /*功能：使用数据库存储过程来执行windows操作系统命令
   作者：DarkAthena
   EMAIL:darkathena@qq.com
   github : http://github.com/Dark-Athena 
   */                                      
AUTHID CURRENT_USER
 IS

  l_sn   varchar2(4000);
  l_dir  varchar2(4000);
  V_File Utl_File.File_Type;
  l_cmd_text2 varchar2(4000);
begin
  null;

  select TO_CHAR(to_number(to_char(systimestamp, 'yyyymmddhh24missff')))
    into l_sn
    from dual;
  select h.DIRECTORY_PATH
    into l_dir
    from ALL_DIRECTORIES h
   where h.DIRECTORY_NAME = I_db_Path
     and rownum = 1;
  l_cmd_text2 :='PUSHD '||l_dir||CHR(10)|| l_cmd_text;

  V_File := Utl_File.Fopen(I_db_Path,
                           I_file_name || '_' || l_sn || '.bat',
                           'W');
  Utl_File.Put_Line(V_File, l_cmd_text2);
  Utl_File.Fclose(V_File);
  if I_run = 'Y' THEN

    BEGIN
      SYS.DBMS_SCHEDULER.CREATE_JOB(job_name        => I_file_name || l_sn,
                                    start_date      => sysdate - 3,
                                    repeat_interval => 'Freq=Minutely;Interval=5',
                                    end_date        => NULL,
                                    job_class       => 'DEFAULT_JOB_CLASS',
                                    job_type        => 'EXECUTABLE',
                                    job_action      => 'c:\windows\system32\cmd.exe /c ' ||
                                                       l_dir || '\' ||
                                                       I_file_name || '_' || l_sn ||
                                                       '.bat',
                                    comments        => NULL);
      SYS.DBMS_SCHEDULER.SET_ATTRIBUTE(name      => I_file_name || L_sn,
                                       attribute => 'RESTARTABLE',
                                       value     => FALSE);
      SYS.DBMS_SCHEDULER.SET_ATTRIBUTE(name      => I_file_name || L_sn,
                                       attribute => 'LOGGING_LEVEL',
                                       value     => SYS.DBMS_SCHEDULER.LOGGING_OFF);
      SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL(name      => I_file_name || L_sn,
                                            attribute => 'MAX_FAILURES');
      SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL(name      => I_file_name || L_sn,
                                            attribute => 'MAX_RUNS');
      BEGIN
        SYS.DBMS_SCHEDULER.SET_ATTRIBUTE(name      => I_file_name || L_sn,
                                         attribute => 'STOP_ON_WINDOW_CLOSE',
                                         value     => FALSE);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      SYS.DBMS_SCHEDULER.SET_ATTRIBUTE(name      => I_file_name || L_sn,
                                       attribute => 'JOB_PRIORITY',
                                       value     => 3);
      SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL(name      => I_file_name || L_sn,
                                            attribute => 'SCHEDULE_LIMIT');
      SYS.DBMS_SCHEDULER.SET_ATTRIBUTE(name      => I_file_name || L_sn,
                                       attribute => 'AUTO_DROP',
                                       value     => FALSE);

      SYS.DBMS_SCHEDULER.DISABLE(name => I_file_name || L_sn);
    END;
    begin
      dbms_scheduler.run_job(I_file_name || L_sn);
    exception
      WHEN OTHERS then
        null;
    end;
    dbms_output.put_line(to_char(sysdate, 'hh24:mi:ss'));
    begin
      UTL_FILE.FREMOVE(I_db_Path, I_file_name || '_' || l_sn || '.bat');
    exception
      WHEN OTHERS then
        null;
    end;
    begin
      dbms_scheduler.drop_job(I_file_name || L_sn);
    exception
      WHEN OTHERS then
        null;
    end;
    ---  O_file_name := I_file_name || '_' || l_sn;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
   raise;
END;
/
