#!/usr/bin/python3
#
### After three years, employee records can be removed. Nightly script
### will pass EIDN and Email of user. Remove user from Google World.
# sample usage:
# ./deleteExpired.py -n -s dirusermanager@philasd.org -f ~morgan/groups-22cf591118c1.json -u morgan -e 9000000015

import sys
import getopt
from google.oauth2 import service_account
import googleapiclient.discovery
import httplib2
import sys

def print_usage():
    print ("usage: "+sys.argv[0]+" [-n] -u <user> -e <eidn> -s subject -f <svc acct file>")
    exit()


        
def expireGoogleAccount(u,e):
    user=u
    eidn=e

    print("Verify user:", user, "with EIDN:", eidn, "exists in the Google world." )

    SCOPES = ['https://www.googleapis.com/auth/admin.directory.user','https://www.googleapis.com/auth/admin.directory.group','https://www.googleapis.com/auth/admin.directory.group.member','https://www.googleapis.com/auth/admin.directory.user.readonly','https://www.googleapis.com/auth/admin.directory.group.readonly','https://www.googleapis.com/auth/admin.directory.group.member.readonly']
    SERVICE_ACCOUNT_FILE = svc_acct_file

    credentials = service_account.Credentials.from_service_account_file(SERVICE_ACCOUNT_FILE, scopes=SCOPES)

    delegated_credentials = credentials.with_subject('subject')

    service = googleapiclient.discovery.build('admin', 'directory_v1', credentials=delegated_credentials)

    try:
        results = service.users().get(userKey=user).execute()
    except NameError:
        print("User Not Found!")
        return 1
    except googleapiclient.errors.HttpError:
        print("404 NOT FOUND!")
        return 1
    except:
        e = sys.exc_info()[0]
        print( "<p>Error: %s</p>" % e )
        return 1
    else:
        print("User is in Google")

    
    print("*********** JSON RESPONSE ***********")
    print(format(results))
    print("*********** After JSON ***********")

    if not print_only:
        if(results["externalIds"][0]["value"]==eidn):
            print("EIDNs Match! I will delete the user, ", user, ".")

            # try:
            #     results = service.users().delete(userKey=user).execute()
            # except googleapiclient.errors.HttpError:
            #     print("Error! User Not Found!")
            #     return 1
            # except NameError:
            #     print("ERROR! DELETE NOT SUCCESSFUL")
            #     return 1
            # except:
            #     e = sys.exc_info()[0]
            #     print( "<p>Error: %s</p>" % e )
            #     print("ERROR!")
            #     return 1
            # else:
            #     print("SUCCESS. DELETE COMPLETE.")
            #     return 0
        else:
            print("ERROR! EIDNs do NOT match.")
            return 1

####
# begin main here
user=print_only=eidn=svc_acct_file=subject=None

opts, args = getopt.getopt(sys.argv[1:], "nu:e:s:f:")

for opt, arg in opts:
    if opt in ('-n'):
        print_only = 1
    elif opt in ('-u'):
        user = arg
    elif opt in ('-e'):
        eidn = arg
    elif opt in ('-s'):
        subject = arg
    elif opt in ('-f'):
        svc_acct_file = arg

if eidn is None or user is None or subject is None or svc_acct_file is None:
    print_usage()

expireGoogleAccount(user, eidn)
