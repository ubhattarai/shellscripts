#!/bin/bash
#set -x
curlcmd=/usr/bin/curl
grepcmd=/bin/grep
cutcmd=/usr/bin/cut
url=
warning=
critical=

usage(){

	echo ""
        echo "$0 [-u url ] [-a argument] [-w warning ] [-c critical ] [-h/v]" 
        echo ""
        echo "Options:"
        echo "  -u)        Enter the URL that you want to monitor"
        echo "  -a)        Enter argument for what response time to monitor e.g CometdSessions, aspPingCount, servletPingCount, activeClientCount"
	echo "  -w)        Sets a warning level for jms ping time"
        echo "  -c)        Sets a critical level for jms ping time"
        echo "  -h)        Help"
        echo "   ?)        Help"

}

find_value(){

	SESSION_COUNT=`${curlcmd} -s $url | $grepcmd $argument | $cutcmd -f2 -d '='`
	#echo $SESSION_COUNT
	return_code=3
	compare
}

compare() {
	
	if [ "$SESSION_COUNT" == "" ]; then
		echo "Could not retrieve ${argument} |=$SESSION_COUNT"
		elif [ $SESSION_COUNT -gt $critical ]; then
			echo "Critical threshold exceeded - ${argument}: $SESSION_COUNT|=$SESSION_COUNT"
			return_code=2
			elif [ $SESSION_COUNT -gt $warning ]; then
				echo "Warning threshold exceeded - ${argument}: $SESSION_COUNT|=$SESSION_COUNT"
				return_code=1
				else
					echo "OK ${argument} : $SESSION_COUNT|=$SESSION_COUNT"
					return_code=0
	fi
exit $return_code
}

main(){

	while getopts "h:u:a:w:c:" options; do
		case $options in
                        u ) url=$OPTARG ;;
                        a ) argument=$OPTARG ;;
                        w ) warning=$OPTARG ;;
                        c ) critical=$OPTARG ;;
                        h ) usage ; exit ;;
                        ? ) usage ; exit ;;
                esac
        done
	
	if [ "x$url" = "x" ]; then
		echo "Please enter a url to be monitered with -u"
		usage
		exit 2
	fi
	if [ "x$argument" = "x" ]; then
		echo "Please enter a argument with -a"
		usage
		exit 2
	fi
	if [ "x$warning" = "x" ]; then
		echo "Please enter a warning level with -w"
		usage
		exit 2
	fi
	
	if [ "x$critical" = "x" ]; then
		echo "Please enter a critical level with -c"
		usage
		exit 2
	fi
	
	find_value	

}

main $@
