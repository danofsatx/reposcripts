#!/bin/bash
####################################################################
# This script is the daily rsync of the Fedora repsitory. It pulls #
# once a day from a Tier 1 Fedora mirror and places it in a public #
# web directory. There is a lock file in place so it will not      #
# restart if there is still a sync in progress.                    #
#                                                                  #
# Author: D. Mossor                                                #
# Date:   10 Aug 2015                                              #
####################################################################

LOCKFILE=/var/lock/fedora.lck
TRACKER=/var/scripts/tracker/fedora.`date +%m%d%Y`
LOGFILE=/var/log/fedora.rsync.`date +%m.%d.%Y-%H:%M`.log
EXFILE=/var/scripts/excludes
CARGS="-avHh --chown=nobody:nobody --stats --no-motd --delay-updates --delete-after --delete-excluded"
# Check to see if lockfile exists, if it does then exit
if [ -e "$LOCKFILE" ] ; then
        # the lock file exists, so exit
        exit 0
fi

# create the lockfile
touch $LOCKFILE

# write the start time to the timer file
echo "Fedora rsync started at " `date` >> $TRACKER

#rsync $CARGS --exclude-from=$EXFILE fedora-archives.ibiblio.org::fedora-enchilada/ /var/repo/fedora/ >> $LOGFILE
#rsync $CARGS --exclude-from=$EXFILE mirrors.kernel.org::fedora-enchilada/linux /var/repo/fedora/ >> $LOGFILE
rsync $CARGS --exclude-from=$EXFILE mirror.lstn.net::fedora-enchilada/ /home/public/fedora/ >> $LOGFILE

# Grab total bytes and stop time
tail -5 $LOGFILE | grep "Total bytes received:" >> $TRACKER
echo "Fedora rsync finished at" `date` >> $TRACKER

# Run the report script so internal systems will point internally.
# /usr/bin/report_mirror -c /etc/mirrormanager-client/report_mirror.conf

# erase the lockfile
/bin/rm -f "$LOCKFILE"

