#!/bin/sh

# SHELL SCRIPT SUCKS

do_connect(){
./server.sh &

local PID=$!

echo $PID > ./the_pid

}

check_process(){
    if [ -e ./the_pid ] && pgrep socat >> /dev/null
    then
	local PID=`cat ./the_pid`
	echo $PID
    else
	echo 0
    fi
}

may_connect(){
    if [[ $1 == "ON" || $1 == "ON_FORCE" ]];
    then	
	local PID=$(check_process)
	
	if [[ $PID == 0 ]];
	then
	    do_connect
	    PID=$(check_process)
	    echo "$(date): safe connect: $PID"
	else
	    if [[ $1 == "ON_FORCE" ]];
	    then
		kill -INT $PID
		sleep 10
		do_connect
		PID=$(check_process)
		echo "$(date): force connect: $PID"
	    fi
	fi
    else
	if [[ $1 == "OFF" || $1 == "OFF_FORCE" ]];
	then
	    local PID=$(check_process)

	    if [[ $PID != 0 ]];
	    then
		#maybe more robust
		pkill -TERM -P $PID && rm ./the_pid
		echo "$(date): killed $PID"
	    fi
	fi
	   
    fi
}


SWITCH=$(curl --silent https://raw.githubusercontent.com/ifree/Orz/master/tunnel.txt)

may_connect $SWITCH
