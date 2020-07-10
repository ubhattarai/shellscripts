#!/bin/bash
#set -x
curlcmd="/usr/bin/curl"
grepcmd="/bin/grep"
cutcmd="/usr/bin/cut"
tempfile="/tmp/jmsresp"
ST_OK=0
ST_WR=1
ST_CR=2
ST_UK=3
url=
sourcename=
targetname=
warning=
critical=

###########################
usage() {

     	echo ""
     	echo "$0 [-u url ] [-s source jms ] [-t target jms ] [-w warning ] [-c critical ] [-h/v]" 
     	echo ""
     	echo "Options:"
        echo "  -u)		Enter the URL that you want to monitor"
        echo "  -s)		Please enter the source jms 00, 01, 02, 03"
        echo "  -t)		Please enter the target jms 00, 01, 02, 03"
     	echo "  -w)     	Sets a warning level for jms ping time"
     	echo "  -c)     	Sets a critical level for jms ping time"
	echo "  -h/-v)  	Help"
	echo "   ?)     	Help"
}

find_value() {

	####WGET Command to get the URL and save it in a temp file
        jmspingtime=`$curlcmd -s $url | ${grepcmd} "jmsPing${sourcename}to${targetname}" | cut -f2 -d '='`
	#return_code=$
	
	compare 
}

compare() {

	if [ "$warning" -gt "$critical" ]; then
		echo "Warning must be less than Critical"
		exit
		elif [ "$jmspingtime" == "null" ]; then
			echo "Unknown jmsPing${sourcename}to${targetname}: $jmspingtime|=$jmspingtime"
			return_code=3
			elif [ "$jmspingtime" == "" ]; then
				echo "Could not retrive jmsPing${sourcename}to${targetname}: $jmspingtime|=$jmspingtime"
				return_code=3
				elif [ "$jmspingtime" -ge "$warning" -a "$jmspingtime" -lt "$critical" ]; then
					echo "WARNING: jmsPing${sourcename}to${targetname}: ${jmspingtime}>$warning"
					return_code=1
					elif [ "$jmspingtime" -gt "$critical" ]; then
						echo "CRITICAL: jmsPing${sourcename}to${targetname}:${jmspingtime}>$critical"
						return_code=2
						else
							echo "OK: jmsPing${sourcename}to${targetname}|=${jmspingtime}"
							return_code=0

	fi
	
	exit $reutrn_code
	
}

main() {

	while getopts ":u:s:t:w:c:hv" option; do
		case $option in
			u ) url=$OPTARG ;;
			s ) sourcename=$OPTARG ;;
			t ) targetname=$OPTARG ;;
                        w ) warning=$OPTARG ;;
                        c ) critical=$OPTARG ;;
                        h ) usage ; exit ;;
                        v ) version ; exit ;;
                        ? ) usage ; exit ;;
                esac
        done
	
	if [ "x${url}" = "x" ]; then
		echo "error: please enter the URL with -u"
		usage
		exit 2
	fi

	if [ "x$sourcename" = "x" ]; then
		echo "error: please enter the source jms with -s"
		usage
		exit 2
	fi

	if [ "x$targetname" = "x" ]; then
                echo "error: targetname was not specified with -t"
                usage
                exit 2
        fi

        if [ "x$warning" = "x" ]; then
                echo "error: warning value was not specified with -w"
                usage
                exit 2
        fi
	
	if [ "x$critical" = "x" ]; then
                echo "error: critical value was not specified with -c"
                usage
                exit 2
        fi
	
	find_value
}

main $@


