create or replace  procedure run_linux_sh_text(i_script varchar2) is
/*by DarkAthena 2021-11-01
last modified 2021-11-30*/
  sched_job_name varchar2(30);
begin
  sched_job_name := dbms_scheduler.generate_job_name(prefix => 'SCRIPT_');
  DBMS_SCHEDULER.create_job(job_name            => sched_job_name,
                            job_type            => 'EXECUTABLE',
                            job_action          => '/bin/sh',
                            number_of_arguments => 2,
                            enabled             => false,
                            auto_drop           => true);
  DBMS_SCHEDULER.set_job_argument_value(sched_job_name, 1, '-c');
  DBMS_SCHEDULER.set_job_argument_value(sched_job_name, 2, i_script||CHR(10)||'exit');--add exit 
  DBMS_SCHEDULER.enable(sched_job_name);
  DBMS_SCHEDULER.run_job(job_name => sched_job_name);
end;
/
