#!/bin/bash


export ORACLE_HOME=/u01/app/oracle/product/12.1.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH;
export ORACLE_SID=PDBALT
export USERNAME=system
export PASSWORD=Oracle123

# Username & password is for Create schema, drop schema & create dump direcory 
export CREATE_DROP_USER=sys
export CREATE_DROP_PASSWORD=Oracle123


export DIRPATH=~/DataRefresh
#IMP_EXP_SCHEMA_NAME is for database directories where we import export dump file.
export IMP_EXP_SCHEMA_NAME=IMP_EXP

export TIMESTAMP=`date +%a%d%b%Y`
export exportabledump=Export_Table_${TIMESTAMP}.dmp
export LOGFILE=${DIRPATH}/sql_log_${TIMESTAMP}.log
export SQL_FILE_PATH=~/DataRefresh/SqlFiles
