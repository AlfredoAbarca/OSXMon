#!/bin/bash

#=============================================================================================
#
# Author: Alfredo Abarca
# OS Version: High Sierra 10.13.6
# Creation Date: 31 July, 2018 
# Last Modification: 31 July, 2018 
# VersionForwarder: 1.0 
# 
# This script configure the supraudit app into user directory and create the directory for the
# output file for supraudit logs, readable for users and others, rather than only for the
# current user. 
# Forwarder
# The supraudit tool is the original compiled binary file downloaded from Jonathan Levin site
#
# http://newosxbook.com/tools/supraudit.html
#
# Im only create this script to simplify the steps required to configure supraudit to startup
# when a system does, and configure the output file, if you find any topic or suggestion related
# to supraudit binary file please contact Jonathan throught his website forum. 
#
# http://newosxbook.com/forum/index.php 
#
#
# IMPORTANT: 
#           This script MUST BE RUN with root privileges. 
#
# If you have any comment or any other matter related to this script, please let me know!
#
#=============================================================================================

#===========================================
#Configure this variables if you want to install Splunk Universal Forwarder to send the logs to 
# a splunk indexer server

Splunk_Index_Server_IP=x.x.x.x
Splunk_Index_Server_port=9997
Splunk_Dep_Server_IP=y.y.y.y
#===========================================

#Copy the supraudit binary to /usr/bin directory
echo "Copying supraudit file to /usr/bin directory" 
cp supraudit/usr/local/bin/supraudit /usr/bin/
echo "Changing privileges to supraudit file..."
chmod 755 /usr/bin/supraudit
echo "Creating /var/log/supraudit directory..."
if [ ! -d /var/log/supraudit/ ];
# if the directory doesn't exists, then create a new one
then
mkdir /var/log/supraudit
fi
echo "Changing privileges to /var/log/supraudit"
chmod -R 744  /var/log/supraudit
echo "Checking if supraudit log files exists"
if [ ! -f /var/log/supraudit/network.log ] || [ ! -f /var/log/supraudit/login.log ] || [ ! -f /var/log/supraudit/ExecApps.log ];
# if any of files doesn't exists then creates a new one (when required)
then
echo "Creating supraudit log files..." status=$(sudo launchctl list | grep "com.supraudit.exec.startup" | wc -l)
if [ $status -gt 0 ];
# If supraudit daemon is registered correctly, then continue asking if splunk forwarder agent
# needs to be installed
then
echo "com.supraudit.exec.startup up"
else
# If the supraudit daemon could not be registered by any error, then the scripts throw an error
# message to the user.
echo "com.supraudit.exec.startup failed to register"
fi
touch /var/log/supraudit/login.log
touch /var/log/supraudit/network.log
touch /var/log/supraudit/ExecApps.log
else 
echo "The supraudit log files already exists" 
fi

status=$(sudo launchctl list | grep "com.supraudit.exec.startup" | wc -l)
if [ $status -gt 0 ];
# If supraudit daemon is registered correctly, then continue asking if splunk forwarder agent
# needs to be installed
then
echo "com.supraudit.exec.startup up"
else
# If the supraudit daemon could not be registered by any error, then the scripts throw an error
# message to the user.
echo "com.supraudit.exec.startup failed to register"
fi
echo "Changing privileges to /var/log/supraudit/login.log"
chmod 744 /var/log/supraudit/login.log
echo "Changing privileges to /var/log/supraudit/network.log"
chmod 744 /var/log/supraudit/network.log
echo "Changing privileges to /var/log/supraudit/ExecApps.log"
chmod 744 /var/log/supraudit/ExecApps.log
if [ ! -d /opt ];
then
#if /opt directory doesn`t exists, then create it
mkdir /opt
chmod 777 /opt
fi

echo "Copy supraudit filters file to /opt"
cp -f opt/* /opt/
chown root:wheel /opt/SupraFilters_* 
chmod -R a+x /opt/SupraFilters_*

echo "Configuring supraudit as startup item..."
cp -f LaunchDaemons/* /Library/LaunchDaemons/
chown root:wheel /Library/LaunchDaemons/com.supraudit.*
chmod 644 /Library/LaunchDaemons/com.supraudit.*
echo "Registering Launchd Supraudit Daemon plist file"
sleep 5s
launchctl load -w /Library/LaunchDaemons/com.supraudit.exec.startup.plist
launchctl start -w /Library/LaunchDaemons/com.supraudit.exec.startup.plist
status=$(sudo launchctl list | grep "com.supraudit.exec.startup" | wc -l)
if [ $status -gt 0 ];
# If supraudit daemon is registered correctly, then continue asking if splunk forwarder agent
# needs to be installed
then
echo "com.supraudit.exec.startup up"
else
# If the supraudit daemon could not be registered by any error, then the scripts throw an error
# message to the user. 
echo "com.supraudit.exec.startup failed to register"
fi
sleep 5s
launchctl load -w /Library/LaunchDaemons/com.supraudit.login.startup.plist
launchctl start -w /Library/LaunchDaemons/com.supraudit.login.startup.plist
status=$(sudo launchctl list | grep "com.supraudit.login.startup" | wc -l)
if [ $status -gt 0 ];
# If supraudit daemon is registered correctly, then continue asking if splunk forwarder agent
# needs to be installed
then
echo "com.supraudit.login.startup up"
else
# If the supraudit daemon could not be registered by any error, then the scripts throw an error
# message to the user.
echo "com.supraudit.login.startup failed to register"
fi
sleep 5s
launchctl load -w /Library/LaunchDaemons/com.supraudit.net.startup.plist
launchctl start -w /Library/LaunchDaemons/com.supraudit.net.startup.plist
status=$(sudo launchctl list | grep "com.supraudit.net.startup" | wc -l)
if [ $status -gt 0 ];
# If supraudit daemon is registered correctly, then continue asking if splunk forwarder agent
# needs to be installed
then
echo "com.supraudit.net.startup up"
else
# If the supraudit daemon could not be registered by any error, then the scripts throw an error
# message to the user.
echo "com.supraudit.net.startup failed to register"
fi

#The following part ask to the user if they want to install and configure Splunk Forwarder 
# to send the logs to a Splunk SIEM
while [ -z "$REPLY" ] ; do
    if [ -z "$1" ] ; then
         read -p "Do you want to install/configure Splunk Universal Forwarder?(yes/no) "
    else
         REPLY=$1
         set --
    fi
    case $REPLY in
        [Yy]es) sleep 5s
                echo -e "\nSplunk Universal Forwarder now will be installed\n"
		tar xvfz splunkforwarder.tgz -C /opt
		export SPLUNK_HOME="/opt/splunkforwarder"
 		export PATH=$PATH:$SPLUNK_HOME/bin
		echo -e "\nConfiguring Splunk Universal Forwarder to boot at startup"
		/opt/splunkforwarder/bin/splunk start --answer-yes --no-prompt --accept-license
		/opt/splunkforwarder/bin/splunk enable boot-start
		/opt/splunkforwarder/bin/splunk stop
		sleep 5s
		#-----------------------------------------------------------------------------
		# By default the splunk credentials will be admin:changeme you could modify 
		# this script to set your defaults or maybe you want change manually
		#-----------------------------------------------------------------------------
		echo "[user_info]" > /opt/splunkforwarder/etc/system/local/user-seed.conf
		echo "USERNAME = admin" >> /opt/splunkforwarder/etc/system/local/user-seed.conf
		echo "PASSWORD = changeme" >> /opt/splunkforwarder/etc/system/local/user-seed.conf 
		echo -e "\nThis forwarder is configured to connect to ${Splunk_Index_Server_IP}"
		# -----------------------------------------------------------------------------
		# If you change the default admin password on the lines above, you need to change
		# also in the following line
		# -----------------------------------------------------------------------------
		/opt/splunkforwarder/bin/splunk add forward-server $Splunk_Index_Server_IP:$Splunk_Index_Server_port -auth admin:changeme
		echo "Creating the application \"MacMon\" locally to start watching the logs to forwarder"
		/opt/splunkforwarder/bin/splunk add monitor /var/log/supraudit/ -index main -sourcetype MacMon
		#----------------------------------------------------------------------------
		# The following lines configures the Splunk forwarder as a deployment agent too.
		#
		# If you have a Splunk Deployment Server on your Splunk infrastructure
		# uncomment the following lines to set the configurations of deployment agent.
		#-----------------------------------------------------------------------------
		echo "[deployment-client]" > /opt/splunkforwarder/etc/system/local/deploymentclient.conf
		echo "clientName = ${HOSTNAME}" >> /opt/splunkforwarder/etc/system/local/deploymentclient.conf
		echo "" >> /opt/splunkforwarder/etc/system/local/deploymentclient.conf
		echo "[target-broker:deploymentServer]" >> /opt/splunkforwarder/etc/system/local/deploymentclient.conf
		echo "targetUri = ${Splunk_Dep_Server_IP}:8089" >> /opt/splunkforwarder/etc/system/local/deploymentclient.conf
		echo "" >> /opt/splunkforwarder/etc/system/local/server.conf 
		echo "[proxyConfig]" >> /opt/splunkforwarder/etc/system/local/server.conf 
		echo "no_proxy=*" >> /opt/splunkforwarder/etc/system/local/server.conf 
		cp -f LaunchDaemons/com.splunk.bootstart.plist /Library/LaunchDaemons/
		chown root:wheel /Library/LaunchDaemons/com.splunk.bootstart.plist
		chmod 644 /Library/LaunchDaemons/com.splunk.bootstart.plist
		/opt/splunkforwarder/bin/splunk restart
		#launchctl load -w /Library/LaunchDaemons/com.splunk.bootstart.plist
		echo -e "\n Splunk Universal Forwarder has been configured on your system!!\n"
		echo -e "\n"
		echo -e "\n Happy Mac Event Monitoring!!\n"
		sleep 5s ;;
         [Nn]o) echo -e "\nThe system is now being auditing and the logs will be stored at /var/logs/supraudit\n"
		echo -e "Happy Auditing!!\n"
                sleep 5s ;;
             *) echo "Wrong answer. Print 'yes' or 'no'" 
                unset REPLY ;;
    esac
done
