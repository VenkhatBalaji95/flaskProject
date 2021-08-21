import boto3
import re

instanceType= "t4g.micro"
region = "ap-south-1"
ami = "ami-04bde106886a53080"

def lambda_handler(event, context):
    if checkInstanceTypeExists() and checkAmiExists():
        print ("Success")
    else:
        print ("Failed")
            
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