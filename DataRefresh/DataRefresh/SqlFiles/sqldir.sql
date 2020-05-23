CREATE OR REPLACE DIRECTORY IMP_EXP AS '/home/oracle/DataRefresh/';
SELECT directory_name, directory_path FROM dba_directories WHERE directory_name='IMP_EXP';
EXIT

