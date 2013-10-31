#!/bin/bash

# mcom version 1.1.0
# Copyright (C) 2013 by Shawn Rieger
# <riegersn@gmail.com>

# mcom comes with ABSOLUTELY NO WARRANTY.  This is free software, and you
# are welcome to redistribute it under certain conditions.  See the MIT
# Licence for details.

# mcom is a simple helper script for working with minicom

usage() {
cat << EOF
usage: mcom options [device number]

OPTIONS SUMMARY

	-h, --help		Display this.
	-l, --log		Enable minicom logging
	-a, --available		List available devices
	-o, --output [file]	Override default log file
	-u, --unlock		Clear lock files before starting minicom

EOF
}

log=false
default_log=~/boxee/logs/minicom.log

while test $# -gt 0
do
	case $1 in

		# Normal option processing
		-l | --log)
			log=true
		  	;;
		-a | --available)
			ls -l /dev/tty.usbserial*
			exit
			;;
		-o | --log_file)
		  	default_log=$2
		  	;;
		-u | --unlock)
			rm /tmp/LCK* >/dev/null 2>&1 
			;;
		-h | --help)
			usage
			exit
			;;
		# ...

		# Special cases
		--)
		  	break
		  	;;
		--*|-?)
			echo "Invalid option! ($1) See \"mcom --help\""
		  	exit
		  	;;

		# Split apart combined short options
		-*)
		  	split=$1
		  	shift
		  	set -- $(echo "$split" | cut -c 2- | sed 's/./-& /g') "$@"
		  	continue
		  	;;

		# Done with options
		*)
		  	break
		  	;;
	esac

	shift
done

finish=""

if $log ; then
	finish="-C $default_log"
	if -f $default_log ; then
		rm $default_log
	fi
fi

minicom -D /dev/tty.usbserial$@ $finish

exit;