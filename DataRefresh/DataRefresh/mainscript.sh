#!/bin/bash



EnvVariableInitalization()
{
   chmod u+x ${DIRPATH}/EnvVariableInitialization.sh
   chmod u+x ${DIRPATH}/tablename
. ./EnvVariableInitialization.sh
source ./EnvVariableInitialization.sh
source ${DIRPATH}/EnvVariableInitialization.sh
echo "Oracle DB home Directory-->" $ORACLE_HOME
echo "Oracle Path -->"$PATH
echo "Oracle SID--->"$ORACLE_SID
echo "Path where the import export files generated-->"$DIRPATH
echo "Sql file path-->"${SQL_FILE_PATH}
echo "*******Environment variable initialization script executed scuccessfully for this session**********"
}


makedirectoryforExportImport()
{
SQL_FILE=${SQL_FILE_PATH}/sqldir.sql

    cd ${DIRPATH}
    echo ${DIRPATH}
    if [ ! -d  ${DIRPATH} ]; then
    mkdir -p ${DIRPATH}
    chmod -R 755 ${DIRPATH}	 
    fi 
cd ~

sqlplus ${CREATE_DROP_USER}/${CREATE_DROP_PASSWORD}@${ORACLE_SID} as sysdba  <<EOF >${LOGFILE}
@${SQL_FILE}
EOF
echo "*****Make Directory for Import Export Completed you can check log" ${LOGFILE}

}


export_tables()
{

for tablename in `cat ${DIRPATH}/tablename`
do
alltable+=$tablename','
done
alltable=`echo $alltable | rev | cut -c 2- | rev`
echo $alltable
echo =======
echo Export command started
echo ======
expdp ${USERNAME}/${PASSWORD}@${ORACLE_SID}  directory=${IMP_EXP_SCHEMA_NAME} dumpfile=${exportabledump}  logfile=expdp_log_${TIMESTAMP}.log tables=$alltable
if [ $? == 0 ]; then
 echo "********** Export successfully completed*************"
else
 echo "***********Export table operation failed**************"
fi
}


Drop_CISADM_Schema()
{
SQL_FILE=${SQL_FILE_PATH}/drop_CISADM_Schema.sql


sqlplus ${CREATE_DROP_USER}/${CREATE_DROP_PASSWORD}@${ORACLE_SID} as sysdba  <<EOF >>${LOGFILE}
 @${SQL_FILE}
EOF

RSTATUS=$?
if [ "${RSTATUS}" != "0" ]
then
  echo -e "*******Drop Schema Operation Failed**********"
else
  echo -e  "******Drop Schema operation success*********"
fi
}

Create_CISADM_Schema()
{
SQL_FILE=${SQL_FILE_PATH}/create_CISADM_Schema.sql


 sqlplus ${CREATE_DROP_USER}/${CREATE_DROP_PASSWORD}@${ORACLE_SID} as sysdba  <<EOF >>${LOGFILE}
@${SQL_FILE}
EOF

RSTATUS=$?
if [ "${RSTATUS}" != "0" ]
then
  echo -e "*******Drop Schema Operation Failed**********"
 else
  echo -e  "******Drop Schema operation success*********"
fi
}

ImportBlankDump()
{

echo -n "Enter the URL from where you copy dump:"
echo -e "\nFor e.g  wget http://ocipd-file01.us.oracle.com/software/automation/oci/devops/deployment/fsgbu/ormb/software/RMB27010_RBE_VBE_dump.dmp \n \n"
echo -e "*********Copy paste URL in below line start with wget command *********************" 
read url
$url

#COPY dump file into location where we create dump for export table.

ImportBlankDump=`echo $url | rev | cut -d '/' -f 1 | rev`
echo $ImportBlankDump


cp $ImportBlankDump ${DIRPATH}

impdp ${USERNAME}/${PASSWORD}@${ORACLE_SID} directory=${IMP_EXP_SCHEMA_NAME} dumpfile=${ImportBlankDump} logfile=impdp_log_${TIMESTAMP}.log schemas=CISADM
#impdp ${USERNAME}/${PASSWORD}@${ORACLE_SID} directory=${IMP_EXP_SCHEMA_NAME} dumpfile=RMB27010_RBE_VBE_dump.dmp  logfile=impdp_log_${TIMESTAMP}.log schemas=CISADM

}

Drop_11_User_Table()
{

SQL_FILE=${SQL_FILE_PATH}/Table_Drop.sql
sqlplus ${CREATE_DROP_USER}/${CREATE_DROP_PASSWORD}@${ORACLE_SID} as sysdba  <<EOF >>${LOGFILE}
@${SQL_FILE}
EOF
RSTATUS=$?
if [ "${RSTATUS}" != "0" ]
then
echo -e "*******Drop Schema Operation Failed**********"
else
echo  -e  "******Drop Schema operation success*********"
fi

}

ImportUserTableDump()
{

for tablename in `cat ${DIRPATH}/tablename`
do
alltable+=$tablename','
done
alltable=`echo $alltable | rev | cut -c 2- | rev`
echo $alltable
echo 
impdp ${USERNAME}/${PASSWORD}@${ORACLE_SID} directory=${IMP_EXP_SCHEMA_NAME} dumpfile=${exportabledump} logfile=impdp_log_${TIMESTAMP}.log  tables=${alltable}


}

while true
do 
echo 
echo -e "================================================="
echo -e "ENTER CHOICE IN 1 TO 9 (PRESS 9 TO EXIT SESSION)"
echo -e "1 -> Initialize all environment variables"
echo -e "2 -> Create dump directories on DB side"
echo -e "3 -> Export all user tables (if required)"
echo -e "4 -> Drop CISADM schema"
echo -e "5 -> Create CISADM schema using sql script"
echo -e "6 -> Import blank or source DB dump"
echo -e "7 -> Drop all user tables (required)"
echo -e "8 -> Import all user tables (exported in option 3)"
echo -e "9 -> Exit this session"
echo -e "================================================="
read OPERATION

case $OPERATION in
    1)
      EnvVariableInitalization       
      ;; 

   2)
    echo -n "make directory"
    echo 
     makedirectoryforExportImport
	 
     ;;
   3) 
      echo -n "exporting  below table"
      echo 
	export_tables
     ;;

   4)
     echo -e "Drop_CISADM_SCEMA"
     echo -e  "Please wait......."
       Drop_CISADM_Schema
    ;;

   5)
    echo -e "Create_CISADM_SCHEMA"
     echo -e  "Please wait......."	
     Create_CISADM_Schema

    ;;
  
   6)
      
     ImportBlankDump
    ;;

   7)
     echo -e "Dropping 11 Table"
     echo -e  "Please wait......."
      Drop_11_User_Table
     ;;	
   8) 

    echo -e "Importing User Table"
     echo -e  "Please wait......."
    ImportUserTableDump
    ;;
   9)
     exit
     ;;
  
  *)
    echo -n "unknown"
    ;;
esac
done
echo 
