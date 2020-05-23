#!/bin/bash

CHECKFILEPATH=/u02/app_binaries/product/spl/ORMBOCI/bin/splenviron.sh
VAR_FILE=/u01/fsgbu_ormb/SqlExecutor/var_initializer.properties

login_user=$(whoami)

if [[ ${login_user} == "fsgbu_ormb" ]]; then
  if [ -f ${CHECKFILEPATH} ]; then
     export ORACLE_HOME=$(grep -inr -F "ORACLE_HOME" ${VAR_FILE} | awk -F= '{print $2}' | awk '{ gsub("[\" \t]",""); print }')
     export PATH=$ORACLE_HOME/bin:$PATH;
     export ORACLE_SID=$(grep -inr -F "ORACLE_SID" ${VAR_FILE} | awk -F= '{print $2}' | awk '{ gsub("[\" \t]",""); print }')
     export USER_NAME=$(grep -inr -F "USER_NAME" ${VAR_FILE} | awk -F= '{print $2}' | awk '{ gsub("[\" \t]",""); print }')
     export PASS_WORD=$(grep -inr -F "PASS_WORD" ${VAR_FILE} | awk -F= '{print $2}' | awk '{ gsub("[\" \t]",""); print }')
     export HOST_NAME=$(grep -inr -F "HOST_NAME" ${VAR_FILE} | awk -F= '{print $2}' | awk '{ gsub("[\" \t]",""); print }')
     export PORT_NUM=$(grep -inr -F "PORT_NUM" ${VAR_FILE} | awk -F= '{print $2}' | awk '{ gsub("[\" \t]",""); print }')

   else
    export ORACLE_HOME=$(grep -inr -F "ORACLE_HOME" ${VAR_FILE} | awk -F= '{print $2}' | awk '{ gsub("[\" \t]",""); print }')
    export PATH=$ORACLE_HOME/bin:$PATH;
    export ORACLE_SID=$(grep -inr -F "ORACLE_SID" ${VAR_FILE} | awk -F= '{print $2}' | awk '{ gsub("[\" \t]",""); print }')
    export USER_NAME=$(grep -inr -F "USER_NAME" ${VAR_FILE} | awk -F= '{print $2}' | awk '{ gsub("[\" \t]",""); print }')
    export PASS_WORD=$(grep -inr -F "PASS_WORD" ${VAR_FILE} | awk -F= '{print $2}' | awk '{ gsub("[\" \t]",""); print }')
    export HOST_NAME=$(grep -inr -F "HOST_NAME" ${VAR_FILE} | awk -F= '{print $2}' | awk '{ gsub("[\" \t]",""); print }')
    export PORT_NUM=$(grep -inr -F "PORT_NUM" ${VAR_FILE} | awk -F= '{print $2}' | awk '{ gsub("[\" \t]",""); print }')
  fi
else
     echo "script cant execute"
     exit 0;
fi


executesql()
{

#TIMESTAMP=`date +%a_%d%b_%Y`
TIMESTAMP=`date +%d-%b-%Y`
#date  --date="$(date +%M-%m-01) +1 month -1 day" '+%d-%b-%Y'
first_date=$(date -d "`date +%Y%m01`" +%d-%b-%Y)
last_date=$(date -d "`date +%Y%m01` +1 month -1 day" +%d-%b-%Y)
cp /u01/fsgbu_ormb/SqlExecutor/sqlorignal.orignal /u01/fsgbu_ormb/SqlExecutor/sqlquery.sql
sed -i "s/START-DATE/$first_date/g" /u01/fsgbu_ormb/SqlExecutor/sqlquery.sql
sed -i "s/END-DATE/$last_date/g" /u01/fsgbu_ormb/SqlExecutor/sqlquery.sql
SQL_QUERY_FILE=/u01/fsgbu_ormb/SqlExecutor/sqlquery.sql
EMAIL_ID=$(grep -inr -F "EMAIL_ID" ${VAR_FILE} | awk -F= '{print $2}' | awk '{ gsub("[\" \t]",""); print }')
EMAIL_NAME=`echo ${EMAIL_ID} | tr "." "\n" | awk 'NR==1{print $1}'`
CUSTOMER_ENVIRONMENT=$(grep -inr -F "CUSTOMER_ENVIRONMENT" ${VAR_FILE} | awk -F= '{print $2}' | awk '{ gsub("[\" \t]",""); print }')
#sqlplus ${USERNAME}/${PASSWORD}@${ORACLE_SID} as sysdba  <<EOF > sqloutput.log
#sqlplus -s ${USERNAME}/${PASSWORD}@${ORACLE_SID}  <<EOF > Sql_Query_output${TIMESTAMP}.log
#sqlplus -s ${USERNAME}/${PASSWORD}@${HOST_NAME}:${PORT_NUM}/${ORACLE_SID} <<EOF> Sql_Query_output_${TIMESTAMP}.log
#sqlplus -s CISADM/oFjTiC6vLqLh#IzLy@dqjw0zzhc0.iad.icprod.oracleindustry.com:1521/rmb1u004.icprod.oracleindustry.com <<EOF>
sqlplus -s ${USER_NAME}/${PASS_WORD}@${HOST_NAME}:${PORT_NUM}/${ORACLE_SID} <<EOF > /u01/fsgbu_ormb/SqlExecutor/Sql_Query_output_${TIMESTAMP}

#SET LINESIZE 7000
#SET PAGESIZE 50000

@${SQL_QUERY_FILE}

EOF
echo -e "Hi ${EMAIL_NAME} , \n\n\n Please find attached SQL output file. \n\n\n\nThank You\n\n \t\t Note: ** This is an auto-generated email. Please do not reply to this email.** " | mailx -s "${CUSTOMER_ENVIRONMENT} SQL Query output from ${first_date} to ${last_date}" -a /u01/fsgbu_ormb/SqlExecutor/Sql_Query_output_${TIMESTAMP} ${EMAIL_ID}

find . -mtime +20 -print | grep -i /u01/fsgbu_ormb/SqlExecutor/Sql_Query_output | xargs rm -rf
sleep 14
rm -rf /u01/fsgbu_ormb/SqlExecutor/sqlquery.sql
}

executesql

