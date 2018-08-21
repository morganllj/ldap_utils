#!/usr/bin/python

import csv
import re
import sys

Print = sys.stdout.write

with open ('Renames.csv', 'rb') as csvfile:
    r = csv.reader(csvfile, delimiter=',', quotechar='"')
    for row in r:

        if row[2] == "USER NAME":
            continue
        
        ldif = "dn: uid=" +  row[2] + ",ou=employees,dc=domain,dc=org\n"
        ldif += "changetype: modrdn\n"
        ldif += "newrdn: uid=" + row[10] + "\n"
        ldif += "deleteoldrdn: 1\n"
        ldif += "\n"
        ldif += "dn: uid=" +  row[10] + ",ou=employees,dc=domain,dc=org\n"
        ldif += "changetype: modify\n"
        ldif += "add: objectclass\n"
        ldif += "objectclass: orgzimbraperson\n"
        
        print ldif
        

