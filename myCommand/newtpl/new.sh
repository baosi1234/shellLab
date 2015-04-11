#!/bin/bash

#+++++++++++++++++++++++++++++++++++
# filename: new.sh
# author: wangxb
# date: 2015-04-11 00:08:59
#+++++++++++++++++++++++++++++++++++

tpl_dir="/root/mylinux/myCommand/newtpl/tpl"
case $1 in
	'html')
			tpl_name="html.tpl"
			suffix="html"
	;;
	'html5')
			tpl_name="html5.tpl"
			suffix="html"
	;;
	'php')
			tpl_name="php.tpl"
			suffix="php"

	;;
	'css')
			tpl_name="css.tpl"
			suffix="css"

	;;
	'js')
			tpl_name="jss.tpl"
			suffix="js"

	;;
	'py')
			tpl_name="py.tpl"
			suffix="py"

	;;
	'pl')
			tpl_name="pl.tpl"
			suffix="pl"

	;;
	'rb')
			tpl_name="rb.tpl"
			suffix="rb"

	;;
	'sh')
			tpl_name="sh.tpl"
			suffix="sh"

	;;
	*)
		echo "command type now exist"
		exit
	;;

esac


function createTpl() {
		filename="$1.$2"
        localdir=${3}
        if [ -f $localdir/$filename ]; then
            create_date=$(date +"%Y%m%d%H%M%S")
            read -p "${filename} is exist, Do you want to ${1}_${create_date}.${suffix}.(y/n)" yes_no
            if [ "$yes_no" = 'y' ] || [ "$yes_no" = "Y" ] || [ "$yes_no" = "yes" ] || [ "$yes_no" = "YES" ]; then
                filename=${1}_${create_date}.${suffix}
            elif [ "$yes_no" = 'n' ] || [ "$yes_no" = "N" ] || [ "$yes_no" = "no" ] || [ "$yes_no" = "NO" ]; then
                exit
            fi
        fi
        if [ -e ${tpl_dir}/${tpl_name} ]; then
            touch $localdir/$filename > /dev/null 2>&1
            cat $tpl_dir/$tpl_name > $localdir/$filename 2> /dev/null
			cdate=$(date +"%Y_%m_%d %H:%M:%S")
			sed -i "s/@filename/$filename/g" $localdir/$filename
			sed -i "s/@cdate/$cdate/g" $localdir/$filename
			if [ $# -eq 4 ]; then
				sed -i "s/@author/$4/g" $localdir/$filename
			else
				who=$(whoami)
				sed -i "s/@author/$who/g" $localdir/$filename
			fi
            vim $localdir/$filename
        else
            touch $localdir/$filename > /dev/null 2>&1
            vim $localdir/$filename
        fi		
}

function checkDir() {
	if [ "$1" = "" ]; then
		localdir=$(pwd)
	else
		$(cd $1 > /dev/null 2>&1) && cd $1 > /dev/null 2>&1 || exit
		localdir=$(pwd)
	fi
	echo $localdir
}

function checkSuffix() {
	suffix=''
	if [[ "$1" =~ ^[a-zA-Z0-9]+$ ]]; then
		suffix=$1
	fi
	echo $suffix
}

shift

if [ "$#" -lt 1 ] || [ "$1" = "" ]; then
	echo "Command request file name(not allow empty) as first options"
	exit
fi
case $# in
	1)
		createTpl $1 $suffix $(pwd)
		;;
	2)
		localdir=$(checkDir $2)
		if [ -z "$localdir" ]; then
			echo 'The directory does not exist'
			exit
		fi
		createTpl $1 $suffix $localdir
		;;
	3)
		localdir=$(checkDir $2)
		if [ -z "$localdir" ]; then
			echo 'The directory does not exist'
			exit
		fi
		if [ -z "$(checkSuffix $3)" ]; then
			echo 'suffix format is error'
			exit
		else
			suffix=$(checkSuffix $3)
		fi
		createTpl $1 $suffix $localdir
		;;
	4)
		localdir=$(checkDir $2)
		if [ -z "$localdir" ]; then
			echo 'The directory does not exist'
			exit
		fi
		if [ -z "$(checkSuffix $3)" ]; then
			echo 'suffix format is error'
			exit
		else
			suffix=$(checkSuffix $3)
		fi
		if [[ "$4" =~ ^[a-zA-Z]+$ ]]; then
			author=$4
		else
			author=$(whoami)
		fi
		createTpl $1 $suffix $localdir $author
		;;
	*)
		echo "options nums is error"
		exit
		;;
esac

