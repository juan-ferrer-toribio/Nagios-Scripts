#check and revive service
import requests
import json
import os
from datetime import datetime
import requests
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)


slaEntry=[]
slaHosts=[]
internetBandwidth=[]
listofHosts=[]
lowAvailHosts=[]

hundrendService=[]
hundrendHost=[]

nagiosHost="nagios.flexopack.com"
hostToCheck="mailarchive.flexopack.local"
serviceToCheck="http"


apikey="0XqhgiJL5ttEclRoWAcDAFMeqPg7skCMh23Qk2Covlj0KapWJUPvQR3gGjmoGYbd"
print("")
print("-----------------------------------------------------------------")
print("Date of execution:"+str(datetime.now()))

def serviceStatus(hostToCheck,serviceToCheck):
    url = "https://" + nagiosHost + "/nagiosxi/api/v1/objects/servicestatus?apikey=" + apikey + "&pretty=1&host_name=" + hostToCheck + "&name=" +serviceToCheck
    #"https://nagios.flexopack.com/nagiosxi/api/v1/objects/servicestatus?apikey=0XqhgiJL5ttEclRoWAcDAFMeqPg7skCMh23Qk2Covlj0KapWJUPvQR3gGjmoGYbd&pretty=1&host_name=mailarchive.flexopack.local%20&name=http"

    headers = {'content-type': 'application/json'}

    payload = {

        # "starttime": "1543413216", #

        #
    }

    data = json.dumps(payload)

    response = requests.request("GET", url, data=data, headers=headers, verify=False)

    json_data = json.loads(response.text)

    tmp = json_data["servicestatus"]
    current_state = tmp["current_state"]

    print("Current "+serviceToCheck+" State ID : "+current_state)
    return current_state



# tmp = response[]

# print(response.text)

serviceState=int(serviceStatus(hostToCheck,serviceToCheck))

if serviceState != 0:
    print("Service" +serviceToCheck+ " of host "+hostToCheck +" Is not OK")
    print("Restarting IIS: C:\WINDOWS\system32\iisreset.exe")
    os.system("C:\\WINDOWS\\system32\\iisreset.exe")
os.system("pause")
print("Exiting ...")
#"C:\WINDOWS\system32\iisreset.exe"

