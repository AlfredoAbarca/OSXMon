#!/bin/bash
#==============================================================================================
#
# Author: Alfredo Abarca Barajas
# Operating System:  Mac OSX 10.13.6 (High Sierra) 
# Creation Date: August 14, 2018 
# Last Modification: August 14, 2018
#
#
# This Script undo the installation of Supraudit to monitor de events of the operating system.
#
# It MUST TO BE RUN with root privileges 
#
# Any doubt or comment related to this script, please let me know.
#
#==============================================================================================
echo -e "\n This script will uninstall the Supraudit Monitoring system from your computer.\n"
while [ -z "$REPLY" ] ; do
    if [ -z "$1" ] ; then
         read -p "Do you want to proceed?(yes/no) "
    else
         REPLY=$1
         set --
    fi
    case $REPLY in
        [Yy]es) sleep 5s
		echo -e "\n Starting with the uninstallation process, please wait...\n"
		echo -e "\n It maybe take some minutes to complete"
		sleep 5s
		echo -e "Stoping Monitoring daemons..\n"
		launchctl unload -w /Library/LaunchDaemons/com.supraudit.*
		echo -e "Stoping and Uninstalling Splunk Universal Forwarder...\n"
		/opt/splunkforwarder/bin/splunk stop
		rm -rf /opt/splunkforwarder/
		echo -e "Checking that all changes has been applied succesfully\n"
	        daemons=$(launchctl list | grep "com.supraudit.*" | wc -l)
		if [[ $daemon -eq 0 ]];
		then
		  echo -e "Startup items has been removed succesfully\n"
		else
		  echo -e "This startup items still remains on memory\n"
		  launchctl list | grep "com.supraudit.*"
		fi
		if [ ! -d /opt/splunkforwarder/ ];
		then
		 echo -e "The splunk forwarder directory /opt/splunkforwarder/ has been removed\n"
		else
		 echo -e "The splunk forwarder directory /opt/splunkforwarder cannot be deleted\n"
		fi		
		echo -e "\n The uninstallation script has ended!!\n"
		sleep 5s;;
         [Nn]o) echo -e "\nYou don't have made any change to the system, Good Bye!!\n"
                sleep 5s ;;
             *) echo "Wrong answer. Print 'yes' or 'no'"
                unset REPLY ;;
    esac
done
