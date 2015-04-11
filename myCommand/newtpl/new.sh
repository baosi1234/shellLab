#!/bin/bash

#+++++++++++++++++++++++++++++++++++
# filename: new.sh
# author: wangxb
# date: 2015-04-11 00:08:59
#+++++++++++++++++++++++++++++++++++

#------------------------------------------------------------------------------------------------------------------------------------------
# 由于在linux下开发时经常需要在新建文件后，输入一下信息，类似于这样：
# <?php
# 	filename：*****
# 	author  ：*****
# 或者这样：
# shell文件中： #!/bin/bash
# Perl文件中：  #!/usr/bin/perl
# Python文件中：#!/usr/bin/python
# 每次都写这么无聊的东西 实在是浪费时间，我也相信那就话：不懒的程序员不是一个好的程序员，
# 所以让我们自己动手写一个数据自己的命令，我们的思路还是那样，利用linux启动加载的机制：
# 利用login
# login shell：取得 bash 时需要完整的登陆流程的，就称为 login shell
# /etc/profile -> ~/.bash_profile(~/.bash_login、~/.profile，bash 的 login shell 配置只会读取上面三个文件的其中一个,顺序从左到右)
# 由于我们想让我们写的这些命令可以被系统中所有用户使用，那我们就要对 /etc/profile 这个文件下手了！！！
# 	看看 /etc/profile/ 中的内容就会明白，这个文件里面是一系列关于登录用户取得shell后的环境信息，我们可以将我们的这个执行命令放到这个文件中
#   但是最好还是别修改这个 文件，我们有更好的办法；这个文件在最后有一个处理就是将 /etc/profile.d文件夹下的所有可执行的 *.sh 文件加入shell
#   环境中去，所以我们的思路就是把我们写好的 shell 脚本放到这个目录下去
# 注意将我们写好的 shell脚本所有用户可读和可执行权限 
# -----------------------------------------------------------------------------------------------------------------------------------------

# 设置模板文件存放路径
TPL_DIR="/root/mylinux/myCommand/newtpl/tpl"

# 这里是根据命令的第一个参数来确定调用什么样的模板文件和默认的生成文件的后缀名
case $1 in
	'html')
			TPL_NAME="html.tpl"
			suffix="html"
	;;
	'html5')
			TPL_NAME="html5.tpl"
			suffix="html"
	;;
	'php')
			TPL_NAME="php.tpl"
			suffix="php"

	;;
	'css')
			TPL_NAME="css.tpl"
			suffix="css"

	;;
	'js')
			TPL_NAME="jss.tpl"
			suffix="js"

	;;
	'py')
			TPL_NAME="py.tpl"
			suffix="py"

	;;
	'pl')
			TPL_NAME="pl.tpl"
			suffix="pl"

	;;
	'rb')
			TPL_NAME="rb.tpl"
			suffix="rb"

	;;
	'sh')
			TPL_NAME="sh.tpl"
			suffix="sh"

	;;
	*)
		echo "command type now exist"
		exit
	;;

esac
export TPL_DIR
export TPL_NAME

# 根据特定格式模板文件创建一个我们想要的文件的方法
function createTpl() {
		filename="$1.$2"   # 设置文件名
        localdir=${3}	   # 设置文件目录
		# 判断在目标目录下是否存在同名文件，对于[存在/不存在]进行相应处理
        if [ -f $localdir/$filename ]; then
            create_date=$(date +"%Y%m%d%H%M%S")
            read -p "${filename} is exist, Do you want to ${1}_${create_date}.${suffix}.(y/n)" yes_no
            if [ "$yes_no" = 'y' ] || [ "$yes_no" = "Y" ] || [ "$yes_no" = "yes" ] || [ "$yes_no" = "YES" ]; then
                filename=${1}_${create_date}.${suffix}
            elif [ "$yes_no" = 'n' ] || [ "$yes_no" = "N" ] || [ "$yes_no" = "no" ] || [ "$yes_no" = "NO" ]; then
                exit
            fi
        fi
		# 判断模板文件是否存在
  		# 存在：根据模板文件生成我们的文件，并自动替换其中的文件名、时间和创建者 
        if [ -e ${TPL_DIR}/${TPL_NAME} ]; then
            touch $localdir/$filename > /dev/null 2>&1
            cat $TPL_DIR/$TPL_NAME > $localdir/$filename 2> /dev/null
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
		# 不存在：就创建一个空文件即可
            touch $localdir/$filename > /dev/null 2>&1
            vim $localdir/$filename
        fi		
}

# 检查数据目录是否是一个有效的目录
function checkDir() {
	if [ "$1" = "" ]; then
		localdir=$(pwd)
	else
		$(cd $1 > /dev/null 2>&1) && cd $1 > /dev/null 2>&1 || exit
		localdir=$(pwd)
	fi
	echo $localdir
}

# 检查输入的文件后缀是否符合要求
function checkSuffix() {
	suffix=''
	if [[ "$1" =~ ^[a-zA-Z0-9]+$ ]]; then
		suffix=$1
	fi
	echo $suffix
}

# 左移我们的参数列表
shift

# 检查必填参数文件名情况
if [ "$#" -lt 1 ] || [ "$1" = "" ]; then
	echo "Command request file name(not allow empty) as first options"
	exit
fi

# 对于数据的可选参数，根据输入参数 进行不同处理
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

