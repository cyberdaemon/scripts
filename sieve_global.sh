#!/bin/bash
#
############################################################
# A simple script for Kolab 3.1 that creates for every     #
# mailbox a sieve spam rule                                #
#                                                          #
# Date started: 25.01.14                                   #
# Version: 0.1                                             #
# Changes: initial script                                  #
#                                                          #
############################################################

# some variables
DOMAINDIR="/var/spool/imap/domain"
SIEVEDIR="/var/lib/imap/sieve/domain"
SIEVEC="/usr/lib/cyrus-imapd/sievec"

# check that we are root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# check if we have the sievec executable

if [ ! -f "$SIEVEC" ]; then
 echo "'$SIEVEC' executable not found...exiting"
 exit 1
   else
     echo  "'$SIEVEC' executable found..proceeding"
fi


# check if the domain directory exists
 if [ ! -d "$SIEVEDIR" ]; then
 echo "Creating domain directory for sieve"
  mkdir "$SIEVEDIR"
   else
     echo  "domain directory exists..proceeding"
fi

# get existant domains and users

cd $DOMAINDIR
for i in `find . -maxdepth 5 -type d -wholename '*/user/*' | sed  's/\user\///g'`
 do
  echo "create directories for sieve"
  cd $SIEVEDIR
   mkdir -p $i
   cat >>$i/roundcube.script <<EOF
require ["fileinto"];
# rule:[SPAM]
if header :contains "X-Spam-Flag" "YES" {
        fileinto "Spam";
}
EOF
# compiling the sieve script and create symbolic link
  /usr/lib/cyrus-imapd/sievec $i/roundcube.script $i/roundcube.bc
  cd $i
  ln -s roundcube.bc defaultbc
# setting permissions and owner
  chown -R cyrus:mail $SIEVEDIR
  chmod 600 -R $SIEVEDIR
done
  echo "All done..please check sieve filter in Roundcube->Settings->Filter"

