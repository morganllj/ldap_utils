#!/usr/bin/python
#


import ldap
import sys
# try:
# 	l = ldap.open("devldap.domain.net")
	
# 	# you should  set this to ldap.VERSION2 if you're using a v2 directory
# 	l.protocol_version = ldap.VERSION3	
# 	# Pass in a valid username and password to get 
# 	# privileged directory access.
# 	# If you leave them as empty strings or pass an invalid value
# 	# you will still bind to the server but with limited privileges.
	
# 	username = "uid=morgan,ou=employees,dc=domain,dc=org"
# 	password  = "catfood0"
	
# 	# Any errors will throw an ldap.LDAPError exception 
# 	# or related exception so you can ignore the result
# 	l.simple_bind(username, password)
# except ldap.LDAPError, e:
# 	print e
# 	# handle error however you like

l = ldap.initialize('ldaps://testldap03.domain.net:636')
l.set_option(ldap.OPT_X_TLS_REQUIRE_CERT, ldap.OPT_X_TLS_ALLOW)
binddn = "uid=morgan,ou=employees,dc=domain,dc=org"
pw = 'pass'
basedn = "dc=domain,dc=org"
searchFilter = "uid=morgan"
searchAttribute = ["mail","cn"]
#this will scope the entire subtree under UserUnits
searchScope = ldap.SCOPE_SUBTREE
#Bind to the server
try:
    l.protocol_version = ldap.VERSION3
    l.simple_bind_s(binddn, pw) 
except ldap.INVALID_CREDENTIALS:
    print ("Your username or password is incorrect.")
    sys.exit(0)
except ldap.LDAPError, e:
  if type(e.message) == dict and e.message.has_key('desc'):
      print e.message['desc']
  else: 
      print e
  sys.exit(0)
try:    
    ldap_result_id = l.search(basedn, searchScope, searchFilter, searchAttribute)
    result_set = []
    while 1:
        result_type, result_data = l.result(ldap_result_id, 0)
        if (result_data == []):
            break
        else:
            ## if you are expecting multiple results you can append them
            ## otherwise you can just wait until the initial result and break out
            if result_type == ldap.RES_SEARCH_ENTRY:
                result_set.append(result_data)
    print result_set
except ldap.LDAPError, e:
    print e
l.unbind_s()
