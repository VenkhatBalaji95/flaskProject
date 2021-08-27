import boto3
import re
import requests
import json

instanceType= "t4g.micro"
region = "ap-south-1"
ami = "ami-04bde106886a53080"
vpcid = "vpc-0aa544df1652ac1bb"
subnetID = ["subnet-072d5b12602626bc6","subnet-0d7fbda544122efd7"]
az = []

def lambda_handler(event, context):
    if event ['RequestType'] in  ["Create", "Update"]:
        print ("Inside create/update request type")
        if checkInstanceTypeExists() and checkAmiExists() and checkVpcExists() and checkSubnetExists():
            print ("Success")
            print ("Event is {0}".format(event))
            data = {
                "Name": "Venkhat-Lambda"
            }
            sendResponse (event, context, "SUCCESS", data)
            
        else:
            print ("Failed")
            print ("Event is {0}".format(event))
            sendResponse (event, context, "FAILED")
    elif event ['RequestType'] == "Delete":
        print ("Delete request type")
        sendResponse (event, context, "SUCCESS")
            
def getInstanceTypes():
    print ("Getting all the EC2 Instance types...")
    price = boto3.client("pricing", region_name=region)
    instanceType = []
    nextToken = "init"
    while nextToken != None:
        if nextToken == "init":
            try:
                response = price.get_attribute_values(ServiceCode = "AmazonEC2", AttributeName = "instanceType")
            except Exception as err:
                print (f"Failed - {err}")
                return instanceType
        else:
            try:
                response = price.get_attribute_values(ServiceCode = "AmazonEC2", AttributeName = "instanceType", NextToken = nextToken)
            except Exception as err:
                print (f"Failed - {err}")
                return instanceType
        instanceType += [k["Value"] for k in response["AttributeValues"]]
        nextToken = response.get("NextToken", None)
    return instanceType

def checkInstanceTypeExists():
    global instanceType
    instanceType = instanceType.strip()
    print (f"Validating {instanceType} type...")
    flag = False
    for i in getInstanceTypes():
        if i == instanceType:
            print (f"'{instanceType}' is a valid EC2 instance type!")
            flag = True
    return flag
    
def checkAmiExists():
    global ami
    ami = ami.strip()
    print ("Validating {0} AMI...".format(ami))
    flag = False
    ec2 = boto3.client("ec2", region_name=region)
    try:
        image = ec2.describe_images(ImageIds=[ami])
        amiRegExPattern = re.compile(r"^(ubuntu\/images\/hvm-ssd\/ubuntu)-(bionic|xenial|focal)-([\d]{2}.[\d]{2})-(amd64-server)-([\d]{8})$")
        result = amiRegExPattern.match(image["Images"][0]["Name"])
        if result:
            print ("'{ami}' is a valid AMI!".format(ami=ami))
            flag = True
        else:
            print ("'{ami}' is an Invalid AMI... Please use Ubuntu amd64 AMI".format(ami=ami))
    except Exception as err:
        print (err)
    return flag
    
def checkVpcExists():
    global vpcid
    print ("Validating {0} VPC ID...".format(vpcid))
    flag = False
    vpcid = vpcid.strip()
    ec2 = boto3.client("ec2", region_name="ap-south-1")
    try:
        response = ec2.describe_vpcs(VpcIds = [vpcid])
        if response['Vpcs'][0]["State"] == "available":
            print ("'{vpcid} is a valid VPC!".format(vpcid=vpcid))
            flag = True
        else:
            print ("'{vpcid} is an Invalid VPC... Please use correct VPC".format(vpcid=vpcid))
    except Exception as err:
        print (err)
    return flag
    
def checkSubnetExists():
    print ("Subnet Validation..")
    print ("Subnets are {0}...".format(str(subnetID)))
    global az
    flag = False
    ec2 = boto3.client("ec2", region_name="ap-south-1")
    try:
        response = ec2.describe_subnets(SubnetIds = subnetID)
        availabilityZone = ec2.describe_availability_zones()
        [az.append(i['ZoneName']) for i in availabilityZone['AvailabilityZones']]
        for i in response["Subnets"]:
            print ("Validating Subnet ID {0}...".format(i["SubnetId"]))
            if i["State"] != "available":
                print ("{0} is not available. Please check your subnet ID".format(i["SubnetId"]))
                flag = False
                break
            if i["AvailabilityZone"] in az:
                az.remove(i["AvailabilityZone"])
            else:
                print ("{0} should be in {1} AZ's. Please check your subnet ID".format(i["SubnetId"],str(az)))
                flag = False
                break
            if i["AvailableIpAddressCount"] <= 30:
                print ("Available IP address on {0} is less than 30. Please use Subnet which has high IP address. Available IP address count is {1}.".format(i["SubnetId"],i["AvailableIpAddressCount"]))
                flag = False
                break
            routeTable = ec2.describe_route_tables(Filters=[{'Name': "association.subnet-id", 'Values': [i["SubnetId"]]}])
            for routes in routeTable["RouteTables"]:
                for state in routes["Routes"]:
                    if "NetworkInterfaceId" not in state and "GatewayId" in state and state["GatewayId"].__contains__("igw-"):
                        print ("Route table '{0}' has Internet gateway as the destination for '{1}'. Please use NAT instance as the destination route!".format(routes["RouteTableId"],i["SubnetId"]))
                        flag = False
                        break
                    if state["State"] != "active":
                        print ("Route table state is not active. It is '{0}' for '{1}'".format(state["State"],routes["RouteTableId"]))
                        flag = False
                        break
            if not flag:
                break
            flag = True
        return flag
    except Exception as err:
        print (err)

def sendResponse(event, context, status, data=None):
    print ("Sending Response...")
    responseURL = event["ResponseURL"] if "ResponseURL" in event else None
    print ("Response URL is {0}".format(responseURL))
    if responseURL:
        responseBody = dict()
        responseBody["Status"] = status
        responseBody["Reason"] = "Log Stream={0}".format(context.log_stream_name)
        responseBody["PhysicalResourceId"] = "resourceValidator"
        responseBody["StackId"] = event["StackId"] if "StackId" in event else "Unknown StackID"
        responseBody["RequestId"] = event["RequestId"] if "RequestId" in event else "Unknown Request ID"
        responseBody["LogicalResourceId"] = event["LogicalResourceId"] if "LogicalResourceId" in event else "Unknown LogicalResourceId"
        responseBody["Data"] = data if data else {}
        
        print ("Response body is {0}".format(responseBody))
        
        jsonBody = json.dumps(responseBody)

        response = requests.put(responseURL, data=jsonBody)
        print ("Response status code is {0}".format(response.status_code))
        return response.status_code