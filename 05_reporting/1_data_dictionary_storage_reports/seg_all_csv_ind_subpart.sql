/*

 Name:          seg_all_csv_ind_subpart.sql

 Purpose:       Segment details as a csv file for loading to spreadsheet

 Usage:          Be a little careful with this script - can run for a moderate period of time on large systems

 Date            Who             Description
                               
  4th Feb 2016   Aidan Lawrence  Sanity check/clean up and col definitions from login.sql 

*/

-- Set up environment
-- See login.sql for basic formatting
      
set heading off
set termout off

define script_name = 'seg_all_csv_ind_subpart'
--
-- Set the Spool output name as combination of script, database and time
--

column spool_name new_value spool_name noprint;

select '&script_name'
       || '_'
       || lower(d.name)
       || '_'
       || 'D'
       || to_char(sysdate,'YYYYMMDD_HH24MI')
       || '.lst' spool_name
  from v$database d;

select 'Output report name is '
       || '&spool_name'
  from dual;

spool &spool_name

set heading off
set verify off
set pages 0
set feedback off
set trimspool on
set linesize 1000
set termout off

/*
Ignore certain schemas
*/

-- NB - Careful adding any more to this - max string size is 240 characters :-o
-- (Should be picking up from login.sql) 
--define ignore_schemas = ('SYS','SYSTEM','CTXSYS','DBSNMP','MDSYS','ODM','ODM_MTR','OE','OLAPSYS','ORDSYS','OUTLN','ORDPLUGINS','PUBLIC','QS','QS_ADM','QS_CBADM','QS_CS','QS_ES','QS_OS','QS_WS','SH','SYSMAN','WKSYS','WMSYS','XDB','APPQOSSYS','EXFSYS','ORDDATA')

select 'owner, index_name, partition_name, subpartition_name, tablespace_name' 
from dual
/

SELECT 
substr(tab.index_owner,1,10) --owner
|| ',' ||  substr(tab.index_name,1,25) --table_name
|| ',' ||  substr(tab.partition_name,1,25) --partition_name
|| ',' ||  substr(tab.subpartition_name,1,25) --subpartition_name
|| ',' ||  substr(tab.tablespace_name,1,25) --tablespace_name
as seg_csv 
from dba_ind_subpartitions tab
--and   rownum < 40 -- test purposes
order by
  tab.index_owner
, tab.index_name
, tab.partition_name
/

-- end of report

spool off

-- Can turn the edit on if running script manually - saves a couple of key strokes :-)
-- Leave edit commented out if running from batch

edit &spool_name
exit

