#!/bin/sh
#

host=ldaps://ldapm01.domain.org  # -H style ldapurl
pass=pass

ldapsearch -x -H $host -D cn=directory\ manager -w $pass -s one \
    -LLLb  cn=replica,cn=\"dc=domain,dc=org\",cn=mapping\ tree,cn=config \
    '(|(objectclass=nsds5replicationagreement)(objectclass=nsDSWindowsReplicationAgreement))' dn |
perl -0000 -n -e '
    s/\n\s//;
    s/\n//;
    print; 
    print "changetype: modify\n";
    print "replace: nsds5beginreplicarefresh\n";
    print "nsds5beginreplicarefresh: start\n\n"
'|
ldapmodify -H $host -D cn=directory\ manager -w $pass
