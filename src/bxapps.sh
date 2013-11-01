#!/bin/bash

# bxapps version 1.1.0
# Copyright (C) 2013 by Shawn Rieger
# <riegersn@gmail.com>

# bxapps comes with ABSOLUTELY NO WARRANTY.  This is free software, and you
# are welcome to redistribute it under certain conditions.  See the MIT
# Licence for details.

# bxapps is a helper script for working with boxee applications

apps_path=~/boxee/apps

usage() {
cat << EOF
usage: bxapps options

OPTIONS SUMMARY

-h, --help			Display this.
-b, --build [app]		Build/package boxee application
-p, --platform [plat]		Set platform [boxee (default), boxee2]
-d, --download [app] [ver]	Downloads application

EOF
}

build=false
download=false
platform="boxee"

while test $# -gt 0
do
	case $1 in

		# Normal option processing
		-b | --build)
			build=$2
		  	;;
		-p | --platform)
			platform=$2
			;;
		-d | --download)
			download=$2
			version=$3
			shift
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
			echo "Invalid option! ($1) See \"bxapps --help\""
		  	exit
		  	;;

		# Split apart combined short options
		-*)
		  	split=$1
		  	shift
		  	set -- $(echo "$split" | cut -c 2- | sed 's/./-& /g') "$@"
		  	continue
		  	;;

		# # Done with options
		# *)
		# 	echo "*"
		#   	break
		#   	;;
	esac

	shift
done

function packageBoxeeBox() {
	pathname=$apps_path/$1
	app=$1
	cd $pathname;

	if [ -f descriptor.xml ]; then
		version=$(cat descriptor.xml | grep "<version" | sed 's/[^0-9.0-9]//g')
		cd ..
		zip -r ~/Desktop/$app-$version.zip $app/ >/dev/null 2>&1
		echo "$app v$version packaged successfully!"
	else
		echo "Failed to package $app v$version!"
	fi
}

if [ $download != false ]; then

	if [ $platform == 'boxee' ]; then
		echo "boxee box currently not supported!"
	elif [ $platform == 'boxee2' ]; then
		echo "Downloading $download-$version..."
		wget -P ~/Downloads/ http://s3.boxee.tv.s3.amazonaws.com/mistee_apps/$download/package/$download-$version.zip
	else
		echo "Invalid platform! ($platform) See \"bxapps --help\""
		exit
	fi

elif [ $build != false ]; then

	# package boxee box application
	if [ $platform == 'boxee2' ]; then
		echo "boxee tv currently not supported!"
	elif [ $platform == 'boxee' ]; then
		echo "packaging $build"
		echo $(packageBoxeeBox $build)
	else
		echo "Invalid platform! ($platform) See \"bxapps --help\""
		exit
	fi

else
	usage
	exit

fi

exit;