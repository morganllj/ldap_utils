#!/bin/sh
#
# password-less ssh keys must be set up between the host this runs on
# and the destination hosts
#
# TODO: assumes one ldap instance per host named slapd-hostname

# only ldap masters need to be backed up.
hosts="ldapm01-mgmt ldapm02-mgmt devldapm01-mgmt devldapm02-mgmt"
domain="domain.org"
#bases="dc=domain,dc=org o=netscaperoot"
db2ldif_base="/usr/lib64/dirsrv/slapd-"
backups_remote_base="/var/lib/dirsrv/slapd-"
backups_local_base="/export/jobroot/employeeLDAP/backups/ldif"


function backup() {
    _protocol=$1    
    _host=$2
    _domain=$3
    _db2ldif_base=$4
    _backups_remote_base=$5
    _backups_local_base=$6

    h=`echo ${_host} | sed 's/-mgmt//'`
    echo; echo; echo "***working on ${h}..."
    bases=`ldapsearch -x -H ${_protocol}://${_host}.${_domain} -LLLb "" -s base objectclass=\* namingcontexts|awk '{print $2}'|egrep -v '^$'`
    for b in $bases; do
    	echo ssh ${_host}.${_domain} -l root "${_db2ldif_base}${h}/db2ldif -s $b && gzip -v ${_backups_remote_base}$h/ldif/*ldif"
    	ssh ${_host}.${_domain} -l root "${_db2ldif_base}${h}/db2ldif -s $b && gzip -v ${_backups_remote_base}$h/ldif/*ldif"
    done
    echo
    echo rsync -avHe "ssh -l root" ${_host}.${_domain}:${_backups_remote_base} ${_host}/ldif/ $backups_local_base
    rsync -avHe "ssh -l root" ${_host}.${_domain}:${_backups_remote_base}${h}/ldif/ $_backups_local_base
}

backup ldap ldap0 domain.org /var/Sun/mps/slapd- /var/Sun/mps/slapd- $backups_local_base

for host in $hosts; do
    backup ldaps $host $domain $db2ldif_base $backups_remote_base $backups_local_base
done



