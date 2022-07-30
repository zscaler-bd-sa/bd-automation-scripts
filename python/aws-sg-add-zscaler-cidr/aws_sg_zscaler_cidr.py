import boto3
import requests
from botocore.exceptions import ClientError

'''
Script to call on Zscaler DC list and create AWS security groups (SG) in a VPC of your choosing

We iterate of the Zscaler DC list and add each CIDR block to a SG, in groups of 50 (keeping within the default AWS limis for SG enteries)
'''


#GLOBALS - Becasue I'm lazy and can't be bothered passing vars around
ec2 = boto3.client('ec2')
seperator = "\n"
count = 0
ipranges = ""

#change this to your VPC ID, the one where you want these SG's mnade
vpc_id = "vpc-########"



def create_sg(count):
    #gracioulsly lifted form --> https://boto3.amazonaws.com/v1/documentation/api/latest/guide/ec2-example-security-group.html
    groupname = "Zscaler" + str(count+1) + "-" + str(count+50)

    try:
        response = ec2.create_security_group(GroupName=groupname,
            Description='Zscaler ZIA Nodes',
            VpcId=vpc_id)
        security_group_id = response['GroupId']
        print('Security Group Created %s in vpc %s.' % (security_group_id, vpc_id))

        return security_group_id
    except ClientError as e:
        print(e)
        return False


######################################################################
#                                                                    #
# This is the main(), but i didn't make a main, so this is the main. #
#                                                                    #
######################################################################

#Ask Zscaler for the DC list - Example response, jusr CSV stuff, no header.
# 185.46.212.0/23,NL,,Amsterdam,
# 213.152.228.0/24,NL,,Amsterdam,
# 165.225.28.0/23,NL,,Amsterdam,

zs_dc = requests.get("http://ips.zscaler.net/sites/default/files/geoips/geoip.csv")
# bust into an array, or a list for the python tragics..
zs_dc_list = zs_dc.content.decode().split(seperator)

# Let's iterate
for line in zs_dc_list:
    #Zacaler response data generates a blank line, parsing will thrown an exemotion, so let's test for it
    if "," not in line:
        continue

    #AWS has a default max of 50 rules per security group, so, let's fill'em up then create a new
    if count % 50 == 0:
        security_group_id = create_sg(count)
        print ("Created new security group: " + str(security_group_id))

    #let's pop the CSV int the relevant variables
    dc_elements = line.split(",")
    ip_range = dc_elements[0].strip('"')
    #I wanted to ise these for the rule descriptions, but AWS doesn't have any documented support for this even thoiugh you cna pass the Descriotion param in on the AWSCLI.  Boo!
    #lets log them anyway, maybe one day we can add ot the actual API call
    city = dc_elements[3].strip('"')
    state = dc_elements[2].strip('"')
    country = dc_elements[1].strip('"')
    description = country + " " + state + " " + city
    print("adding rule for:" + description)

    #scrub the doct from the next part
    dc_elements = {}


    try:
        # doing the needful. Callimng the actual API
        data = ec2.authorize_security_group_ingress(
            GroupId=security_group_id,
            IpPermissions=[
                {'IpProtocol': "-1",
                'IpRanges': [{'CidrIp': ip_range}]}
            ])
        print('Ingress Successfully Set %s' % data)
        count += 1
        #loop = False

    except ClientError as e:
        print(e)