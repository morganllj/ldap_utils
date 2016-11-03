#!/usr/bin/python
#

import ldap

s_csv = []
s_ldap = []
    
print "reading csv..."
f = open('/Users/morgan/google_students.csv', 'r')
line = f.readline()
while line:
    line = line.rstrip()
    s_csv.append(line.split('@')[0])
    line = f.readline()
f.close


print "reading ldap..."
try:
    ldap.set_option(ldap.OPT_X_TLS_REQUIRE_CERT, ldap.OPT_X_TLS_NEVER)
    l = ldap.initialize("ldaps://sgldap.domain.net")
    #l = ldap.initialize("ldaps://ldap.domain.net")
    l.simple_bind("uid=morgan,ou=employees,dc=domain,dc=org", "pass");
    r = l.search("dc=domain,dc=org", ldap.SCOPE_SUBTREE, "objectclass=orgstudent", ["uid"]);
    result_set = []

    while 1:
        result_type, result_data = l.result(r, 0)
        if (result_data == []):
            break

        if (result_type == ldap.RES_SEARCH_ENTRY):
#            print "data: ", result_data
            result_set.append(result_data)

    for i in range(len(result_set)):
#        print "dn: ", result_set[i][0]
        for entry in result_set[i]:
            try:
                s_ldap.append(entry[1]['uid'][0])
            except:
                pass

except ldap.LDAPError, e:
    print "problem searching ldap: ", e

print "comparing..."
for s in s_csv:
    if s not in s_ldap:
        print s
        

    
