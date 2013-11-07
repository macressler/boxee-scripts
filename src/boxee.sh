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
			echo "Invalid option! ($1) See \"boxee --help\""
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

#clone all git repositories
git clone git@github.com:Boxee/apps.git
git clone git@github.com:Boxee/apps-dir.git
git clone git@github.com:Boxee/apps-qt.git
git clone git@github.com:Boxee/boxee-tools.git
git clone git@github.com:Boxee/server.git

if [ -n "$ignore_clients" ]; then
	git clone git@github.com:Boxee/bbx2.git
	git clone git@github.com:Boxee/client.git
fi

cd $project_base/server/boxee/_tools
git clone git@github.com:Boxee/scrapers.git
cd $project_base

#create link to scrapers dir from project base
ln -s $project_base/server/boxee/_tools/scrapers $project_base/scrapers

#check for paths
if [ -f $HOME/.profile ]; then
	prof=$HOME/.profile
elif [ -f $HOME/.bash_profile ]; then
	prof=$HOME/.bash_profile
fi

setenvs=( "BOXEE_HOME=$project_base/server/boxee" "SCRAPER_HOME=$project_base/scrapers" )

if [ -n "$prof" ]; then

	for i in "${setenvs[@]}"
	do
		:
		envname=$(echo "$i" | cut -d'=' -f1)
		envpath=$(echo "$i" | cut -d'=' -f2-)

		if [ $envname == "BOXEE_HOME" ] && [[ ! -z "$BOXEE_HOME" ]]; then
			continue
		elif [ $envname == "SCRAPER_HOME" ] && [[ ! -z "$SCRAPER_HOME" ]]; then
			continue
		fi

		if [ -z "$auto_confirm" ]; then 
			echo -n "$envname variable not set. Shall I set it? [y/n]: "
			read addbh
		else
			addbh="y"
		fi

		if [ $addbh == 'y' ]; then
			echo -e "\n# set $envname from boxee setup script\nexport $envname=$envpath" >> $prof
		else
			echo -e "\t\You then add this manually!\n$envname=$envpath"
		fi

	done

else
	echo -e "\nUnable to add variables to your bash profile. You must add them manually!"
	echo -e "\t\$BOXEE_HOME=$project_base/server/boxee"
	echo -e "\t\$SCRAPER_HOME=$project_base/scrapers\n"
fi

sudo port selfupdate
sudo port upgrade outdated

sudo port install php5 +apache2 +mysql5 +mcrypt +curl +tidy +pear

sudo port load apache2

sudo /opt/local/apache2/bin/apachectl -k start

cd /opt/local/apache2/modules
sudo /opt/local/apache2/bin/apxs -a -e -n "php5" libphp5.so

# sudo nano /opt/local/apache2/conf/httpd.conf
# Add the following at 119
# AddType application/x-httpd-php .php
# AddType application/x-httpd-php-source .phps
	
sudo /opt/local/apache2/bin/apachectl -k restart
sudo port install mysql5-server
sudo cp /opt/local/etc/php5/php.ini-development /opt/local/etc/php5/php.ini

# Install remaining ports for server env




exit;