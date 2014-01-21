#!/bin/sh
# For Teamspeak 3 System TSDNS Server

BINARYPATH="$(dirname "${0}")"
cd "${BINARYPATH}"

if [ -e "tsdnsserver_linux_x86" ]; then
	BINARYNAME="tsdnsserver_linux_x86"
elif [ -e "tsdnsserver_linux_amd64" ]; then
	BINARYNAME="tsdnsserver_linux_amd64"
elif [ -e "tsdnsserver_freebsd_x86" ]; then
	BINARYNAME="tsdnsserver_freebsd_x86"
elif [ -e "tsdnsserver_freebsd_amd64" ]; then
	BINARYNAME="tsdnsserver_freebsd_amd64"
else
	echo "Could not locate binary file, aborting"
	exit 5
fi

case "$1" in
	start)
		if [ -e tsdnsserver.pid ]; then
			if ( kill -0 $(cat tsdnsserver.pid) 2> /dev/null ); then
				echo "The TSDNS server is already running, try restart or stop"
				exit 1
			else
				echo "tsdnsserver.pid found, but no server running. Possibly your previously started server crashed"
				echo "Please view the logfile for details."
				rm tsdnsserver.pid
			fi
		fi
		if [ "${UID}" = "0" ]; then
			echo "WARNING ! For security reasons we advise: DO NOT RUN THE SERVER AS ROOT"
			c=1
			while [ "$c" -le 10 ]; do
				echo -n "!"
				sleep 1
				c=$((++c))
			done
			echo "!"
		fi
		echo "Starting the TeamSpeak 3 TSDNS server"
		if [ -e "$BINARYNAME" ]; then
			if [ ! -x "$BINARYNAME" ]; then
				echo "${BINARYNAME} is not executable, trying to set it"
				chmod u+x "${BINARYNAME}"
			fi
			if [ -x "$BINARYNAME" ]; then
				echo "TeamSpeak 3 TSDNS server started"
				"./${BINARYNAME}" &
				echo $! > tsdnsserver.pid
			else
				echo "${BINARNAME} is not exectuable, cannot start TeamSpeak 3 TSDNS server"
			fi
		else
			echo "Could not find binary, aborting"
			exit 5
		fi
	;;
	stop)
		if [ -e tsdnsserver.pid ]; then
			echo -n "Stopping the TeamSpeak 3 TSDNS server"
			if ( kill -TERM $(cat tsdnsserver.pid) 2> /dev/null ); then
				c=1
				while [ "$c" -le 300 ]; do
					if ( kill -0 $(cat tsdnsserver.pid) 2> /dev/null ); then
						echo -n "."
						sleep 1
					else
						break
					fi
					c=$((++c)) 
				done
			fi
			if ( kill -0 $(cat tsdnsserver.pid) 2> /dev/null ); then
				echo "TSDNS Server is not shutting down cleanly - killing"
				kill -KILL $(cat tsdnsserver.pid)
			else
				echo "done"
			fi
			rm tsdnsserver.pid
		else
			echo "No server running (tsdnsserver.pid is missing)"
			exit 7
		fi
	;;
	restart)
		$0 stop && $0 start || exit 1
	;;
	status)
		if [ -e tsdnsserver.pid ]; then
			if ( kill -0 $(cat tsdnsserver.pid) 2> /dev/null ); then
				echo "TSDNS Server is running"
			else
				echo "TSDNS Server seems to have died"
			fi
		else
			echo "No TSDNS server running (tsdnsserver.pid is missing)"
		fi
	;;
	update)
		if [ -e tsdnsserver.pid ]; then
			if ( kill -0 $(cat tsdnsserver.pid) 2> /dev/null ); then
				"./${BINARYNAME}" --update &
			else
				echo "TSDNS Server seems to have died"
			fi
		else
			echo "No TSDNS server running (tsdnsserver.pid is missing)"
		fi
	;;
	*)
		echo "Usage: ${0} {start|stop|restart|status|update}"
		exit 2
esac
exit 0

