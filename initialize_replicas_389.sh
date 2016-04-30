#!/bin/sh
#
# morgan@morganjones.org
# simple but functional hack to force an initialization of replication

ldapsearch -x -LLL -b cn=mapping\ tree,cn=config -D cn=directory\ manager -w pass -H ldaps://devldapm01.domain.org objectclass=nsds5replicationagreement dn|perl -000 -n -e 's/\n\s//;s/\n//;print $_; print "changetype: modify\nreplace: nsds5beginreplicarefresh\nnsds5beginreplicarefresh: start\n\n";'| ldapmodify -H ldaps://devldapm01.domain.org -D cn=directory\ manager -w pass
