#!/bin/bash
####################################################################
# This script is the weekly rsync of the Ubuntu Old Releases. It   #
# pulls once a week from the Canonical archive, and places it      #
# on our local network. There is a lock file in place so it will   #
# not restart if there is still a sync in progress.                #
#                                                                  #
# Author: D. Mossor                                                #
# Date:   09 Sep 2014                                              #
####################################################################

LOCKFILE=/var/reposcripts/locks/ubuntu-archive.lck
TRACKER=/var/reposcripts/tracker/ubuntu-archive.`date +%m%d%Y`
LOGFILE=/var/log/repo/ubuntu-archive/archive.rsync.`date +%m.%d.%Y-%H:%M`.log
EXFILE=/var/reposcripts/excludes/ubuntu-archive
#RSOPTS="-avH --chown=nobody:nobody --human-readable --stats --no-motd --delay-updates --delete-after --delete-excluded --exclude-from=$EXFILE --bwlimit=375k"
RSOPTS="-avH --chown=nfsnobody:nfsnobody --human-readable --stats --no-motd --delay-updates --delete-after --delete-excluded --exclude-from=$EXFILE"

# Check to see if lockfile exists, if it does then exit
if [ -e "$LOCKFILE" ] ; then
        # the lock file exists, so exit
        exit 0
fi

# create the lockfile
touch $LOCKFILE

# write the start time to the timer file
echo "Ubuntu Archive rsync started at " `date` >> $TRACKER

rsync $RSOPTS old-releases.ubuntu.com::old-releases/ /var/repo/ubuntu-archive/ >> $LOGFILE

# Grab total bytes and stop time
tail -5 $LOGFILE | grep "Total bytes received:" >> $TRACKER
echo "Ubuntu Archive rsync finished at" `date` >> $TRACKER

# erase the lockfile
/bin/rm -f "$LOCKFILE"
