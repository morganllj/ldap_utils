#!/bin/sh
#

e="morgan@domain.org"
p="/usr/sbin/ns-slapd"
h=`hostname`
r="service dirsrv start"

r=`ps auxwww|grep ${p}|grep -v grep`;

if [ -z "$r" ]; then
    ( echo "attemping ${p} restart on ${h} at `date`:" 
      echo
      $r
    ) | mail -s "${p} restarted on ${h}" $e
fi
