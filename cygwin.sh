#!/bin/bash
####################################################################
# This script is the daily rsync of the Cygwin repsitory. It pulls #
# one time daily from the Cygwin mirror at OSUOSL and places it on #
# our local network. There is a lock file in place so it will not  #
# restart if there is still a sync in progress.                    #
#                                                                  #
# Author: D. Mossor                                                #
# Date:   16 July 2014                                              #
####################################################################

# Who Am I?
file=${0##*/}
script=${file%%.*}

LOCKFILE=/var/reposcripts/locks/$script.lck
TRACKER=/var/reposcripts/tracker/$script.`date +%m%d%Y`
LOGFILE=/var/log/repo/cygwin/$script.rsync.`date +%m.%d.%Y-%H:%M`.log
EXFILE=/var/reposcripts/excludes/$script
CARGS="-avH --chown=nobody:nobody --no-motd --human-readable --stats "
DELS="--exclude-from=$EXFILE --delay-updates --delete-after --delete-excluded"

if [ -e "$LOCKFILE" ] ; then
        # the lock file exists, so exit
        exit 0
fi

# create the lockfile
touch $LOCKFILE

# write the start time to the timer file
echo "$script rsync started at " `date` >> $TRACKER

cd /var/repo/cygwin
wget -nH -nd -N -nv -t 10 http://cygwin.com/setup-x86_64.exe

rsync $CARGS $DELS rsync.osuosl.org::cygwin/x86_64/ /var/repo/cygwin/x86_64/ > $LOGFILE

# Grab total bytes and stop time
tail -5 $LOGFILE | grep "Total bytes received:" >> $TRACKER
echo "$script rsync finished at" `date` >> $TRACKER

# erase the lockfile
/bin/rm -f "$LOCKFILE"
