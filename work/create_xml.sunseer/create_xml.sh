#!/bin/bash
# filename: ts_xml.sh
# create_wangxb_20150126
#

#PATH=/u01/app/oracle/product/10.2.0/db_1/bin:/usr/kerberos/bin:/usr/local/bin:/bin:/usr/bin:/opt/dell/srvadmin/bin:/home/p3s_batch/tools:/home/p3s_batch/bin
PATH=/usr/kerberos/bin:/usr/local/bin:/bin:/usr/bin:/home/p3s_batch/bin:/usr/oracle/product/10.2.0/bin
export PATH
# Database account information file
source ~/.p3src

echo "***** 処理が始まる 時間:$(date '+%Y%m%d%H%M%S') *****"
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# set some variable 
# XMLSCRIPT: script url
# MATCHING_RESULT_XML: file name that will be created xml file 
# XML_FUNC_FILE: shell script file
# MATCHING_RESULT_QUERY_DATA: Save temporary data files
# MATCHING_RESULT_QUERY_SQL: Saved queries sql string
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#export XMLSCRIPT=/usr/p3s/batch/jaaa_match/tmp_xa_wangxb
export XMLSCRIPT=/usr/p3s/batch/jaaa_match/CreatXML
XML_DIR="$XMLSCRIPT/xmldata"
XML_FUNC_FILE="xml_func.sh"

MATCHING_RESULT_XML="matching_result_"$(date '+%Y%m%d_%H%M%S')".xml"
MATCHING_RESULT_QUERY_DATA="matching_result_query_data.tmp"
MATCHING_RESULT_QUERY_SQL="matching_result_query.sql"

CLIENT_LIST_XML="client_list_"$(date '+%Y%m%d_%H%M%S')".xml"
CLIENT_LIST_QUERY_DATA="client_list_query_data.tmp"
CLIENT_LIST_QUERY_SQL="client_list_query.sql"

echo "********** 鑑定協会送信処理が始まる **********"
# add_wangxb_20150225
if [ ! -d "$XML_DIR" ];
then
    mkdir $XML_DIR
fi

#+++++++++++++++++++++++++++
# modify_wangxb_20150224
# check for temporary file 
#+++++++++++++++++++++++++++
if [ -e "$XML_DIR/$MATCHING_RESULT_XML" ];
then
    rm -f $XML_DIR/$MATCHING_RESULT_XML
fi

if [ -e "$XMLSCRIPT/$MATCHING_RESULT_QUERY_DATA" ];
then
    MATCHING_RESULT_QUERY_DATA="matching_result_query_data_"$(date '+%Y%m%d%H%M%S')".tmp"
fi
#+++++++++++++++++++++++++++++++++++++++++++++++++
# add_wangxb_20150225
# check system time,  choice query time period
#+++++++++++++++++++++++++++++++++++++++++++++++++
sys_datetime=$(date '+%Y%m%d%H')
first_chk_datetime="$(date '+%Y%m%d')04"
second_chk_datetime="$(date '+%Y%m%d')12"
third_chk_datetime="$(date '+%Y%m%d')20"
case $sys_datetime in
    "$first_chk_datetime"|"$(date '+%Y%m%d')05"|"$(date '+%Y%m%d')06"|"$(date '+%Y%m%d')07")
        chk_start=$(date '+%Y-%m-%d 21:00:00' -d '-1 day')
        chk_end=$(date '+%Y-%m-%d 04:29:59')
    ;;
    "$second_chk_datetime"|"$(date '+%Y%m%d')13"|"$(date '+%Y%m%d')14"|"$(date '+%Y%m%d')15")
        chk_start=$(date '+%Y-%m-%d 04:30:00')
        chk_end=$(date '+%Y-%m-%d 12:29:59')

    ;;
    "$third_chk_datetime"|"$(date '+%Y%m%d')21"|"$(date '+%Y%m%d')22"|"$(date '+%Y%m%d')23")
        chk_start=$(date '+%Y-%m-%d 12:30:00')
        chk_end=$(date '+%Y-%m-%d 20:59:59')

    ;;
    *)
        chk_start=$(date '+%Y-%m-%d 00:00:00')
        chk_end=$(date '+%Y-%m-%d 23:59:59')

    ;;
esac

# modify_wangxb_20150310
# データベースのカレント時間を通じる データベースの接続をテストする
echo "********** データベースの接続をテストする **********"
$ORACLE_HOME/bin/sqlplus -s $ORAUSER_WEB_PASDB << EOF
set echo off
set feedback off
alter session set nls_date_format='YYYY-MM-DD:HH24:MI:SS';
select sysdate from dual;
quit
EOF
if [ $? -ne 0 ]
then 
    echo "********** DBへのリンク失敗した **********"
    exit
else
    echo "********** DBへのリンクＯＫです **********"
fi

$ORACLE_HOME/bin/sqlplus -s $ORAUSER_WEB_PASDB @$XMLSCRIPT/$MATCHING_RESULT_QUERY_SQL "$chk_start" "$chk_end" > $XMLSCRIPT/$MATCHING_RESULT_QUERY_DATA

echo "********** 選択した車両情報でxmlファイルを形成し、ファイルの処理が始まる **********" 

# create matching result's xml file
# add_wangxb_20150227
source "$XMLSCRIPT/$XML_FUNC_FILE" "$XML_DIR/$MATCHING_RESULT_XML"
put_head 'xml version="1.0" encoding="utf-8"'
tag_start 'ROOT'
if [ -s "$XMLSCRIPT/$MATCHING_RESULT_QUERY_DATA" ];
then
    datas=${XMLSCRIPT}/${MATCHING_RESULT_QUERY_DATA}
    #for res in $datas
    while read res;
    do
        stock_id=$(echo $res | awk 'BEGIN {FS="\\^\\*\\^"} {print $1}')
        seirino=$(echo $res | awk 'BEGIN {FS="\\^\\*\\^"} {print $2}')
        match_flg=$(echo $res | awk 'BEGIN {FS="\\^\\*\\^"} {print $3}')
        unmatch_riyuu=$(echo $res | awk 'BEGIN {FS="\\^\\*\\^"} {print $4}')
        up_date_tmp=$(echo $res | awk 'BEGIN {FS="\\^\\*\\^"} {print $5}')
        up_date=$(echo $up_date_tmp | awk 'BEGIN {FS="@"} {print $1 " " $2}')
        tag_start 'MATCHING'
        tag 0 'STOCKID' ${stock_id:-""}
        tag 0 'SEIRINO' ${seirino:-""}
        tag 0 'RESULT' ${match_flg:-""}
        tag 1 'REASON' ${unmatch_riyuu:-""}
        tag 0 'UPDATE_DATE' ${up_date:-""}
        tag_end 'MATCHING'
    done < $datas
fi
tag_end 'ROOT'
rm $XMLSCRIPT/$MATCHING_RESULT_QUERY_DATA

echo "********** 選択した車両情報でxmlファイルを形成し、ファイルの処理が始まる **********"

# create client list's xml file
# add_wangxb_2015027

if [ -e "$XML_DIR/$CLIENT_LIST_XML" ];
then
    rm -f $XML_DIR/$CLIENT_LIST_XML
fi

if [ -e "$XMLSCRIPT/$CLIENT_LIST_QUERY_DATA" ];
then
    CLIENT_LIST_QUERY_DATA="client_list_query_data_"$(date '+%Y%m%d%H%M%S')".tmp"
fi

echo "********** 選択した店舗情報でxmlファイルを生成し、ファイルの処理が始まる **********"

$ORACLE_HOME/bin/sqlplus -s $ORAUSER_MND @$XMLSCRIPT/$CLIENT_LIST_QUERY_SQL > $XMLSCRIPT/$CLIENT_LIST_QUERY_DATA

source "$XMLSCRIPT/$XML_FUNC_FILE" "$XML_DIR/$CLIENT_LIST_XML"
put_head 'xml version="1.0" encoding="utf-8"'
tag_start 'ROOT'
if [ -s "$XMLSCRIPT/$CLIENT_LIST_QUERY_DATA" ];
then
    datas=${XMLSCRIPT}/${CLIENT_LIST_QUERY_DATA}
    #for res in $datas
    while read res;
    do
        corporation_id=$(echo $res | awk 'BEGIN {FS="\\^\\*\\^"} {print $1}')
        corporation_name=$(echo $res | awk 'BEGIN {FS="\\^\\*\\^"} {print $2}')
        client_id=$(echo $res | awk 'BEGIN {FS="\\^\\*\\^"} {print $3}')
        client_print_name=$(echo $res | awk 'BEGIN {FS="\\^\\*\\^"} {print $4}')
        tag_start 'CLIENT'
        tag 0 'CORPORATION_ID' ${corporation_id:-""}
        tag 1 'CORPORATION_NAME' ${corporation_name:-""}
        tag 0 'CLIENT_ID' ${client_id:-""}
        tag 1 'CLIENT_PRINT_NAME' ${client_print_name:-""}
        tag_end 'CLIENT'
    done < $datas
fi
tag_end 'ROOT'
rm $XMLSCRIPT/$CLIENT_LIST_QUERY_DATA

echo "********** 店舗情報でxmlファイルを生成し、ファイルの処理が終わる **********"

# add_wangxb_20150304
# Convert xml file encoding
if [ -e "$XML_DIR/$MATCHING_RESULT_XML" ];
then
    echo "********** matching_result.xmlファイルコードを転換し、**********"
    iconv -f euc-jp -t utf-8 $XML_DIR/$MATCHING_RESULT_XML  -o $XML_DIR/$MATCHING_RESULT_XML.utf-8
    mv $XML_DIR/$MATCHING_RESULT_XML.utf-8 $XML_DIR/$MATCHING_RESULT_XML
fi
if [ -e "$XML_DIR/$CLIENT_LIST_XML" ];
then
    echo "********** client_list.xmlフィルコードを転換し、**********"
    iconv -f euc-jp -t utf-8 $XML_DIR/$CLIENT_LIST_XML  -o $XML_DIR/$CLIENT_LIST_XML.utf-8
    mv $XML_DIR/$CLIENT_LIST_XML.utf-8 $XML_DIR/$CLIENT_LIST_XML
fi

echo -e "********** 遠距離のftpを通して、目的なサーバーを登録し、生成したxmlファイルを目的なサーバーまで発送する **********\n"
# add_wangxb_20150304
# Send the xml file to the destination server by ftp
ftp_host="222.158.220.249"
USER="proto"
PASS="A4bkGawZ7WhEgCrW"
ftp -i -n $ftp_host << EOF
user $USER $PASS
cd /
lcd $XML_DIR/
put $MATCHING_RESULT_XML
put $CLIENT_LIST_XML
quit
EOF

# test ftp
#ftp_host="61.206.38.15"
#USER="dev_owner"
#PASS="devowner"
#dir="/upload"
#ftp -i -n $ftp_host << EOF
#user $USER $PASS
#cd /upload/
#lcd $XML_DIR/
#put $MATCHING_RESULT_XML
#put $CLIENT_LIST_XML
#quit
#EOF

echo "********** shell脚本での実施終わる **********"
echo "***** 実施終わる 時間:$(date '+%Y%m%d%H%M%S') *****"

# Save the program log file
YYMM=$(date +'%Y%m%d%H%M')
#cp /tmp/create_xml.log /usr/p3s/batch/jaaa_match/tmp_xa_wangxb/logs/create_xml.log.$YYMM
cp /tmp/create_xml.log /usr/p3s/batch/jaaa_match/CreatXML/logs/create_xml.log.$YYMM

# Send error log files into the Admin mailbox
info_to_mail_1="chenzh@sunseer.co.jp"
#info_to_mail_1="xa_wangxh@sunseer.co.jp"
info_to_mail_2="xa_wangxb@sunseer.co.jp"
title=$(echo "鑑定協会様へ向けXML作成" | nkf -j)
nkf -j < /tmp/create_xml.log | mail -s $title $info_to_mail_1 $info_to_mail_2


#exit
