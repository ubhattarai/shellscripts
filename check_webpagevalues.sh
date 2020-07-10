#!/bin/bash
#set -x
wgetcmd="/usr/bin/wget"
grepcmd="/bin/grep"
URL="https://mywebsite.com/healthMonitor.do?token=healthMonitorToken&compact=1"
tempfile="/tmp/jmsresp"
ST_OK=0
ST_WR=1
ST_CR=2
ST_UK=3
targetname=
warning=
critical=

###########################
usage() {

     	echo ""
     	echo "$0 [-t targetname ] [-w warning ] [-c critical ] [-h/v]" 
     	echo ""
     	echo "Options:"
        echo "  -t)	Defines the jms target either 00, 01, 02, 03"
     	echo "  -w)     Sets a warning level for jms ping time"
     	echo "  -c)     Sets a critical level for jms ping time"
	echo "  -h/-v)  Help"
	echo "   ?)     Help"

     #exit $ST_UK
 }

find_value() {

	###calling function "target_name" which determines what are other targets needs to be checked based on the target value that was passed as option####
        target_name $targetname
       	
	####WGET Command to get the URL and save it in a temp file
        wgetoutput=`$wgetcmd -O $tempfile $URL`
	###find the which message bus the target is connected to###
        CMD_OUT1=`$grepcmd "jmsTargetName${targetname}" $tempfile | cut -f2 -d '='`
	###find the jms ping time from provided target name to 1st target###
        CMD_OUT2=`$grepcmd "jmsPing${targetname}to${target1}" $tempfile | cut -f2 -d '='`
	###find the jms ping time from provided target name to 2nd target###
        CMD_OUT3=`$grepcmd "jmsPing${targetname}to${target2}" $tempfile | cut -f2 -d '='`
	###find the jms ping time from provided target name to 3rd target###
        CMD_OUT4=`$grepcmd "jmsPing${targetname}to${target3}" $tempfile | cut -f2 -d '='`
	###find the jms ping time from provided target name to itself###
        CMD_OUT5=`$grepcmd "jmsPing${targetname}to${targetname}" $tempfile | cut -f2 -d '='`
	
	compare 
}

compare() {

	echo $targetname,$warning,$critical,$CMD_OUT1,$CMD_OUT2,$CMD_OUT3,$CMD_OUT4,$CMD_OUT5

	if [ "$warning" -a -n "$critical" ]; then
	
		if [ "$CMD_OUT2" -ge "$warning" -a "$CMD_OUT2" -lt "$critical" ]; then
			echo "WARNING: jmsPing${targetname}to${target1} = ${CMD_OUT2} is greater than $warning"
			exit 1
		elif [ "$CMD_OUT2" -gt "$critical" ]; then
			echo "CRITICAL: jmsPing${targetname}to${target1} = ${CMD_OUT2} is greater than $critical"
			exit 2
		else
			echo "OK: jmsPing${targetname}to${target1} = ${CMD_OUT2} is okay"
	#		exit 0
		fi

		
		if [ "$CMD_OUT3" -ge "$warning" -a "$CMD_OUT3" -lt "$critical" ]; then
                        echo "WARNING: jmsPing${targetname}to${target2} = ${CMD_OUT3} is greater than $warning"
			exit 1
                elif [ "$CMD_OUT3" -gt "$critical" ]; then
       	                echo "CRITICAL: jmsPing${targetname}to${target2} = ${CMD_OUT3} is greater than $critical"
			exit 2
               	else
               		echo "OK: jmsPing${targetname}to${target2} = ${CMD_OUT3} is okay"
	#		exit 0
                fi

		
		if [ "$CMD_OUT4" -ge "$warning" -a "$CMD_OUT4" -lt "$critical" ]; then
                        echo "WARNING: jmsPing${targetname}to${target3} = ${CMD_OUT4} is greater than $warning"
			exit 1
               	elif [ "$CMD_OUT4" -gt "$critical" ]; then
                       	echo "CRITICAL: jmsPing${targetname}to${target3} = ${CMD_OUT4} is greater than $critical"
			exit 2
               	else
                	echo "OK: jmsPing${targetname}to${target3} = ${CMD_OUT4} is okay"
	#		exit 0
                fi
		
		
		if [ "$CMD_OUT5" -ge "$warning" -a "$CMD_OUT5" -lt "$critical" ]; then
                        echo "WARNING: jmsPing${targetname}to${targetname} = ${CMD_OUT5} is greater than $warning"
			exit 1
               	elif [ "$CMD_OUT5" -gt "$critical" ]; then
                       	echo "CRITICAL: jmsPing${targetname}to${targetname} = ${CMD_OUT5} is greater than $critical"
			exit 2
        	else
                       	echo "OK: jmsPing${targetname}to${targetname} = ${CMD_OUT5} is okay"
	#		exit 0
                fi

	else
		echo "OK"
	#	exit 0
	fi
	####deleting the temporary file####
 	rm -f $tempfile
	
}

target_name() {

	if [ "$targetname" == "00" ]; then
         	target1=01
         	target2=02
         	target3=03
	elif [ "$targetname" == "01" ]; then
         	target1=00
         	target2=02
         	target3=03
	elif [ "$targetname" == "02" ]; then
         	target1=00
         	target2=01
         	target3=03
	elif [ "$targetname" == "03" ]; then
         	target1=00
         	target2=01
         	target3=02
	fi
}

main() {

	while getopts ":t:w:c:hv" option; do
		case $option in
                        t ) targetname=$OPTARG ;;
                        w ) warning=$OPTARG ;;
                        c ) critical=$OPTARG ;;
                        h ) usage ; exit ;;
                        v ) version ; exit ;;
                        ? ) usage ; exit ;;
                esac
        done
	
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


