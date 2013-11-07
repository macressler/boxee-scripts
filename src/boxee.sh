#!/bin/bash

if [ "$(id -u)" == "0" ]; then
   echo >&2 "Do not run as root user.  Aborting."; exit 1;
fi

usage() {
cat << EOF
usage: boxee options

OPTIONS SUMMARY

	-h, --help		Display this.
	-i, --ignore-clients	Set this to not clone the client repositories
	-y, --auto-confirm	Auto confirm any prompts. Caution.

EOF
}

while test $# -gt 0
do
	case $1 in

		# Normal option processing
		-i | --ignore-clients)
			ignore_clients=true
		  	;;
		-y | --auto-confirm)
			auto_confirm=true
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

#paths
project_base=$HOME/boxee-test

#check for git/port
command -v git >/dev/null 2>&1 || { echo >&2 "I require git but it's not installed.  Aborting."; exit 1; }
command -v port >/dev/null 2>&1 || { echo >&2 "I require port but it's not installed.  Aborting."; exit 1; }

#array of required sub directories
subdirs=( "$project_base" "$project_base/device-share" "$project_base/device-share/bbx" "$project_base/device-share/bbxapps" "$project_base/device-share/btv" "$project_base/logs" )

#loop through each dir and create it if it doesn't exist
for i in "${subdirs[@]}"
do
	:
	if [ ! -d $i ]; then
		mkdir $i
	fi
done

#back to base dir and create initial log file
cd $project_base;
touch logs/boxee.log

# clone all git repositories
# git clone git@github.com:Boxee/apps.git
# git clone git@github.com:Boxee/apps-dir.git
# git clone git@github.com:Boxee/apps-qt.git
# git clone git@github.com:Boxee/boxee-tools.git
# git clone git@github.com:Boxee/server.git

# if [ -n "$ignore_clients" ]; then
# 	git clone git@github.com:Boxee/bbx2.git
# 	git clone git@github.com:Boxee/client.git
# fi

# cd $project_base/server/boxee/_tools
# git clone git@github.com:Boxee/scrapers.git

# cd $project_base
# ln -s $project_base/server/boxee/_tools/scrapers $project_base/scrapers

#check for paths
if [ -f $HOME/.profile ]; then
	prof=$HOME/.profile
elif [ -f $HOME/.bash_profile ]; then
	prof=$HOME/.bash_profile
fi

if [ -n "$prof" ]; then

	if [[ -z "$BOXEE_HOME" ]]; then

		if [ -z "$auto_confirm" ]; then 
			echo -n "BOXEE_HOME variable not set. Shall I set it? [y/n]: "
			read addbh
		else
			addbh="y"
		fi

		if [ $addbh == 'y' ]; then
			echo -e "\n# set BOXEE_HOME from boxee setup script\nexport BOXEE_HOME=$project_base/server/boxee" >> $prof
		else
			echo -e "\t\You then add this manually!\n\$BOXEE_HOME=$project_base/server/boxee"
		fi
	fi

	if [[ -z "$SCRAPER_HOME" ]]; then

		if [ -z "$auto_confirm" ]; then 
			echo -n "SCRAPER_HOME variable not set. Shall I set it? [y/n]: "
			read addsh
		else
			addsh="y"
		fi

		if [ $addsh == 'y' ]; then
			echo -e "\n# set SCRAPER_HOME from boxee setup script\nexport SCRAPER_HOME=$project_base/scrapers" >> $prof
		else
			echo -e "\t\You then add this manually!\n\$SCRAPER_HOME=$project_base/scrapers"
		fi
	fi

else
	echo -e "\nUnable to add variables to your bash profile. You must add them manually!"
	echo -e "\t\$BOXEE_HOME=$project_base/server/boxee"
	echo -e "\t\$SCRAPER_HOME=$project_base/scrapers\n"
fi


exit;