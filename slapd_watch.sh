#!/bin/sh
#

e="morgan@domain.org"
p="/usr/sbin/ns-slapd"
h=`hostname`
r="service dirsrv start"

c=`ps auxwww|grep ${p}|grep -v grep`;

if [ -z "$c" ]; then
    ( echo "attemping ${p} restart on ${h} at `date`:" 
      echo
      $r
    ) | mail -s "${p} restarted on ${h}" $e
fi
