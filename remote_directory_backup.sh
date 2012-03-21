#!/bin/sh
#
# password-less ssh keys must be set up between the host this runs on
# and the destination hosts
#
# TODO: assumes one ldap instance per host named slapd-hostname

# only ldap masters need to be backed up.
hosts="ldapm01-mgmt ldapm02-mgmt devldap01-mgmt devldap02-mgmt"
domain="domain.org"
bases="dc=domain,dc=org o=netscaperoot"
db2ldif_base="/usr/lib64/dirsrv/slapd-"
backups_remote_base="/var/lib/dirsrv/slapd-"
backups_local_base="/export/jobroot/employeeLDAP/backups/ldif"

for mh in $hosts; do
    h=`echo ${mh} | sed 's/-mgmt//'`
    echo; echo; echo "***working on ${h}..."
    bases=`ldapsearch -x -H ldaps://${mh}.${domain} -LLLb "" -s base objectclass=\* namingcontexts|awk '{print $2}'|egrep -v '^$'`
    for b in $bases; do
        echo ssh ${mh}.${domain} -l root "${db2ldif_base}${h}/db2ldif -s $b && gzip -v ${backups_remote_base}$h/ldif/*ldif"
        ssh ${mh}.${domain} -l root "${db2ldif_base}${h}/db2ldif -s $b && gzip -v ${backups_remote_base}$h/ldif/*ldif"
    done
    echo
    echo rsync -avHe "ssh -l root" ${mh}.${domain}:${backups_remote_base}${h}/ldif/ $backups_local_base
    rsync -avHe "ssh -l root" ${mh}.${domain}:${backups_remote_base}${h}/ldif/ $backups_local_base
done

