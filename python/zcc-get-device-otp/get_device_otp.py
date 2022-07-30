#
# written: Niladri Datta ndatta@zscaler.com
# date: April 16 2022
# This script accepts username as a parameter and retrieves OTP for all
# devices registered in Zscaler Mobile Admin for user
#
# Usage:
# > python3 get_device_otp.py user@domain.com
# HOSTNAME            |TYPE                     |OS                                                |OTP
# ________________________________________________________________________________________________________________________
# sales1               VMware, Inc. VMware7,1    Microsoft Windows 10 Enterprise;64 bit;amd64       ays0bmiu9e
# salesuser1’s iPad    Apple iPad13,4            Version 15.4.1 (Build 19E258)                      0rnbg2omrb
#
# Requirements:
# Environment: Python3 with Requests module installed
# base_url: API endpoint URL for your tenant. Change it below
# key: Change this to the Client ID value from the Mobile Admin UI
# secret: Change this to the Client Secret value from the Mobile Admin UI

import sys
import requests
import json


# Change this to your cloud used by tenant
base_url = "https://api-mobile.zscalerbeta.net/papi"

# Insert generated API key and secret from Mobile Admin UI
key = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
secret = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"


def getdeviceotp(session_token: str, url: str, dev_udid: str) -> str:
    # This function retrieves the OTP for a device

    # Include the session token in your header
    auth_header = {
        'Content-Type': 'application/json',
        'auth-token': session_token
    }

    # Send udid as parameter in URL query string
    request_params = {
        'udid': dev_udid
    }

    rurl = url + "/public/v1/getOtp"

    # Get the OTP
    response_otp = requests.get(rurl, headers=auth_header, params=request_params, verify=False)
    device_otp = response_otp.json()["otp"]

    return device_otp


####
# Step 1: Get username parameter
if len(sys.argv) == 2:
    user = sys.argv[1]
else:
    sys.exit("Exiting. Script executed incorrectly.\nExample syntax: python thisscript.py someuser@somedomain.com")

###
# Step 2: Authenticate and get session token
stdheader = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
}

fullurl = base_url + "/auth/v1/login"

# Send API key and secret in body
auth_param = {
    "apiKey": key,
    "secretKey": secret
}

response = requests.post(fullurl, headers=stdheader, data=json.dumps(auth_param), verify=False)

if response.status_code == 200:
    mytoken = response.json()["jwtToken"]
else:
    sys.exit("Check URL and API key and secret. Authentication failed")

###
# Step 3: Get all devices enrolled by user
header = {
    'Content-Type': 'application/json',
    'auth-token': mytoken
}

fullurl = base_url + "/public/v1/getDevices"

# Send username parameter in URL query string
payload = {
    'username': user
}

response = requests.get(fullurl, headers=header, params=payload, verify=False)

if response.status_code == 200:
    registered_device_count = 0
    all_user_devices = response.json()

    # Print the header
    print("{0:<20}|{1:<25}|{2:<50}|{3:<15}".format("HOSTNAME", "TYPE", "OS", "OTP"))
    print("_"*120)
    ##
    # Step 4: Get OTP for all registered user devices
    for index in all_user_devices:
        if index["registrationState"] == "Registered":
            udid = index["udid"]
            dev_otp = getdeviceotp(mytoken, base_url, udid)
            print("{0:<20} {1:<25} {2:<50} {3:<15}".format(index['machineHostname'], index['detail'],
                                                                 index['osVersion'], dev_otp))
            registered_device_count += 1

    # Existing user with no Registered devices
    if registered_device_count == 0:
        print(f"User {user} has no active devices enrolled")

# User not found returns a 400
elif response.status_code == 400:
    print(f"User {user} not found")
else:
    sys.exit("Error getting device list for user")
