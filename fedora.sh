#!/bin/bash
####################################################################
# This script is the daily rsync of the Fedora repsitory. It pulls #
# six times daily from a Tier 1 Fedora mirror and places it on our #
# local network. There is a lock file in place so it will not      #
# restart if there is still a sync in progress.                    #
#                                                                  #
# Author: D. Mossor                                                #
# Date:   14 May 2014                                              #
####################################################################

LOCKFILE=/var/reposcripts/locks/fedora.lck
TRACKER=/var/reposcripts/tracker/fedora.`date +%m%d%Y`
LOGFILE=/var/log/repo/fedora/fedora.rsync.`date +%m.%d.%Y-%H:%M`.log
EXFILE=/var/reposcripts/excludes/fedora
CARGS="-avH --chown=nobody:nobody --human-readable --stats --no-motd --delay-updates --delete-after --delete-excluded"
LIMIT="--bwlimit=10m"
# Check to see if lockfile exists, if it does then exit
if [ -e "$LOCKFILE" ] ; then
        # the lock file exists, so exit
        exit 0
fi
######
#TODO: Add Time-stamping checks
#
#TIME_STAMP=name of the file, starting from the root of the repository
#FROM=upstream site
#TO=path of local repository
#
#In bash:
#
#cd /to/scratch/directory
#export TZ=UTC
#
#if [ $TIME_STAMP ] && [ -e $TO/$TIME_STAMP ]; then
#    # use rsync without a destination to get listing only
#    rsync [options] $FROM/$TIME_STAMP > time-stamp
#    # parse first line to get info from time_stamp file; use date to
#    # convert format to seconds from Epoch
#    upstream_timestamp=$(date -d "$(awk 'BEGIN {getline; print $3 " " $4}' time-stamp)" +%s)
#    # same for local version
#    local_timestamp=$(stat -c %Y $TO/$TIME_STAMP)
#    if (($upstream_timestamp <= $local_timestamp + 5)); then
#        echo "Upstream timestamp is not more recent than here"
#        echo "Aborting"
#        exit 0
#    fi
#fi
########
# create the lockfile
touch $LOCKFILE

# write the start time to the timer file
echo "Fedora rsync started at " `date` >> $TRACKER

#rsync $CARGS --exclude-from=$EXFILE redora-archives.ibiblio.org::fedora-enchilada/ /var/repo/fedora/ >> $LOGFILE
rsync $CARGS --exclude-from=$EXFILE mirrors.kernel.org::fedora-enchilada/linux /var/repo/fedora/ >> $LOGFILE
#rsync $CARGS --exclude-from=$EXFILE mirror.lstn.net::fedora-enchilada/ /var/repo/fedora/ >> $LOGFILE

# Grab total bytes and stop time
tail -5 $LOGFILE | grep "Total bytes received:" >> $TRACKER
echo "Fedora rsync finished at" `date` >> $TRACKER

# Run the report script so internal systems will point internally.
/usr/bin/report_mirror -c /etc/mirrormanager-client/report_mirror.conf

# erase the lockfile
/bin/rm -f "$LOCKFILE"
