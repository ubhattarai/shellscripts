#!/bin/bash

### Uncomment to enable debug mode
### set -x

dir="/my/dir"
cmd="ln"

user="user1"
group="user1"

main (){
	echo "Please input source:"
	read ahid
	echo "============================="
	echo "Please enter sub directory:"
	read said
	echo "============================="
	linkdir
}

linkdir(){

	echo "Please enter Destination:"
	read daid
	echo "============================="
	echo "Checking if exists"
	echo "++++++++++++++++++++++++++++"
	cd $dir/$ahid/ || exit
	check_dir
}

check_dir (){
	if [ -d $daid ]; then
		echo "$daid directory exists, deleting it to create link"
		rm -rf $daid
	else
		echo "Directory doesnot exists, creating the link"
	fi
	#echo "Directory doesnot exists, creating the link"
	echo "++++++++++++++++++++++++++++++++"
	echo "Create a $daid symbolic link to main auction $dir/$ahid/$said"
	echo "++++++++++++++++++++++++++++++++"
	echo "If it is not correct, Please 'ctrl+c' to exit out and run again"
	echo "OR"
	echo "Hit ENTER to continue"
	read
	$cmd -s $said/ $daid
	chown -R $user.$group $daid
	echo "++++++++++++++++++++++++++++++"
	echo "++++++++++++++++++++++++++++++"
	echo "Please browse to $dir/$ahid to confirm link exists"
	oncemore
}

oncemore (){

	echo "Do you want more links (y/n)??"
	read more
	if [ "$more" == "y" ]; then
		echo "Running Once again..."
		linkdir

	else
		echo "Exiting Out of the Script"
		exit
	fi
}

main $@
