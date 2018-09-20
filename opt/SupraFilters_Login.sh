#!/bin/bash
#===========================================================================================================
#
#
# AUTHOR: Alfredo Abarca
# OS Version: High Sierra 10.13.6
# Creation Date: July 31, 2018 
# Last Modification: July 31, 2018 
# Version: 1.0 
#
# This bash script executes supraudit with some modifiers in order to try filtering not relevant events and
# reduce the amount of information stored in the local computer. 
#
# supraudit tool has been developed by Jonathan Levin and any topic related with the binary could be reported
# to him throught his forum section at newosxbook.com
#
#==========================================================================================================

#The form in which the events will be recorded are like the following example:
 
#TIMESTAMP    |   PROCESS NAME | PID/UID |operation (modifiers) (arguments) = return value
#-------------+----------------+---------+--------------------------------------------------
#1507164879.89|      vmnet-natd|53832/501|open (read)(flags=0 path=/private/etc/hosts ) = 10
#1507164879.89|      vmnet-natd|53832/501|close(fd=10 path=/private/etc/hosts ) = 0


# ====USER FAILED/SUCCESS LOGIN======
# Send the log related to succesfully/failed login 
#
supraudit  -S /dev/auditpipe | grep -Ev 'ioctl|close\(|INET6|127.0.0.1|INET4 10.|INET4 192.|INET4 0.|INET4 255.' | grep "password" >> /var/log/supraudit/login.log 


