#!/bin/sh

if [ $# -lt 1 ];then
	echo "usage : bash $0 [start|stop|restart]"
	exit
fi

function start()
{
	/usr/local/bin/nginx
	/usr/sbin/php-fpm -c /etc/php.ini -y /etc/php-fpm.conf 
}

function stop()
{
	killall php-fpm 
	/usr/local/bin/nginx -s stop 
}

function restart()
{
	killall php-fpm 
	/usr/sbin/php-fpm -c /etc/php.ini -y /etc/php-fpm.conf 
	/usr/local/bin/nginx -s reload
}

case $1 in
	start)
		start
		;;
	stop)
		stop
		;;
	restart)
		restart
		;;
	*)
		echo "usage : bash $0 [start|stop|restart]"
		;;
esac

