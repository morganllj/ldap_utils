### After three years, employee records can be removed. Nightly script will pass EIDN and Email of user. Remove user from Google World.


def expireGoogleAccount(a,b):
    user=a
    eidn=b

    print("Verify user: ", user, " with EIDN: ", eidn, " exists in the Google world." )

    from google.oauth2 import service_account
    import googleapiclient.discovery
    import httplib2

    import sys

    SCOPES = ['https://www.googleapis.com/auth/admin.directory.user','https://www.googleapis.com/auth/admin.directory.group','https://www.googleapis.com/auth/admin.directory.group.member','https://www.googleapis.com/auth/admin.directory.user.readonly','https://www.googleapis.com/auth/admin.directory.group.readonly','https://www.googleapis.com/auth/admin.directory.group.member.readonly']
    SERVICE_ACCOUNT_FILE = '../../oauth2callback/groups-22cf591118c1.json'

    credentials = service_account.Credentials.from_service_account_file(SERVICE_ACCOUNT_FILE, scopes=SCOPES)

    delegated_credentials = credentials.with_subject('dirusermanager@domain.org')

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
           
    if(results["externalIds"][0]["value"]==eidn):
        print("EIDNs Match! I will delete the user, ", user, ".")

        try:
            results = service.users().delete(userKey=user).execute()
        except googleapiclient.errors.HttpError:
            print("Error! User Not Found!")
            return 1
        except NameError:
            print("ERROR! DELETE NOT SUCCESSFUL")
            return 1
        except:
            e = sys.exc_info()[0]
            print( "<p>Error: %s</p>" % e )
            print("ERROR!")
            return 1
        else:
            print("SUCCESS. DELETE COMPLETE.")
            return 0

    else:
        print("ERROR! EIDNs do NOT match.")
        return 1
        
