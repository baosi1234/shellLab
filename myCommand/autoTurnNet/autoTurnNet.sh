#!/bin/bash
if ifup eth0 > /dev/null 2>&1
then
		ipinfo=$(ifconfig | grep -n "inet addr:" | grep "Bcast:")
		ip=$(echo $ipinfo | cut -d ':' -f 3 | cut -d ' ' -f 1)
		user=$(whoami)
		echo "Hi! $user, NetWork turn on success. IP4: $ip "
	
else
		echo "Sorry! sir, network don't turn on "

fi
