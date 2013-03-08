#!/bin/sh
#

function print_usage {
    echo "usage: $ARGV[0] <hostname> [<consumer1> <consumer2> ...]"
    echo "    <host> needs to be an ldap master and an ldapurl: ldaps://host.domain"
    echo "    consumers are just hostnames, not ldapurls."
    echo
    exit
}

if [ -z $1 ]; then
    print_usage
fi

master=$1

for host in $@; do
    if [ $host != $master ]; then
        consumers=$consumers" "$host
    fi
done

echo initializing $consumers on $master...
echo

host=$master  # -H style ldapurl
pass=pass
bind="cn=directory\\ manager"

filter='(|(objectclass=nsds5replicationagreement)(objectclass=nsDSWindowsReplicationAgreement))'
if [ ! -z "$consumers" ]; then
    filter=${filter}"(|"
    for consumer in $consumers; do
        filter=${filter}"(nsDS5ReplicaHost=$consumer)"
    done
    filter="(&${filter}))"
fi

echo $filter

ldapsearch -x -H $host -D "$bind" -w $pass -s one \
    -LLLb  cn=replica,cn=\"dc=domain,dc=org\",cn=mapping\ tree,cn=config \
     "$filter" dn |
perl -0000 -n -e '
    s/\n\s//;
    s/\n//;
    print; 
    print "changetype: modify\n";
    print "replace: nsds5beginreplicarefresh\n";
    print "nsds5beginreplicarefresh: start\n\n"
'|
ldapmodify -H $host -D "$bind" -w $pass


