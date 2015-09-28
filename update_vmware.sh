#/bin/bash
####################################################################
# This script is the daily download of the VMware repository.  It  #
# pulls one time daily from the main VMware updates server and     #
# puts it on our local network. There is a lock file in place so   #
# it will not restart if there is still a sync in progress.        #
#                                                                  #
# Authors:                                                         #
# Wrapper script - D. Mossor, 24 Aug 2014                          #
####################################################################

LOCKFILE=/var/reposcripts/locks/vmware.lck
TRACKER=/var/reposcripts/tracker/vmware.`date +%m%d%Y`
LOGFILE=/var/log/repo/vmware/vmware.`date +%m.%d.%Y-%H:%M`.log
EXFILE=/var/reposcripts/excludes/vmware
DEST=/var/repo/apt-mirror/mirror/
C_ARGS="-e robots=off --wait 1 --domains softwareupdate.vmware.com --no-parent --page-requisites -x -m -N -nv -t 10 -P"
# Check to see if lockfile exists, if it does then exit
if [ -e "$LOCKFILE" ] ; then
        # the lock file exists, so exit
        exit 0
fi

# create the lockfile
touch $LOCKFILE

# write the start time to the timer file
echo "VMware download  started at " `date` >> $TRACKER

wget $C_ARGS $DEST http://softwareupdate.vmware.com/cds/ >> $LOGFILE 2>&1

#################
# Historical lines
#
#wget -e robots=off --wait 1 --domains softwareupdate.vmware.com --no-parent --page-requisites -x -m -N -nv -q -t 10 -P /export/apt-mirror/mirror/ http://softwareupdate.vmware.com/cds/
#wget -e robots=off --wait 1 --domains softwareupdate.vmware.com --no-parent --page-requisites -x -m -N -v -t 10 -P /export/apt-mirror/mirror/ http://softwareupdate.vmware.com/cds/
# TODO: update the latest vmware player
#################

# Grab total bytes and stop time
TFILES=`cat $LOGFILE | grep -i "Downloading" | wc -l`
echo "$TFILES downloaded"  >> $TRACKER
echo "VMware download finished at" `date` >> $TRACKER

# erase the lockfile
/bin/rm -f "$LOCKFILE"
