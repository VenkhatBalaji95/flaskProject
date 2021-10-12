#!/usr/bin/python

import boto3,yaml,json,os

def main ():
  aws_creds = yaml.load(open("vars/dynamicHosts.yaml", "r"), Loader=yaml)["boto3"]
  ansible = yaml.load(open("vars/dynamicHosts.yaml", "r"), Loader=yaml)["ansible"]
  env = yaml.load(open("vars/dynamicHosts.yaml", "r"), Loader=yaml)["env"]

  ec2 = boto3.resource("ec2", region_name = aws_creds["region"], aws_access_key_id = os.environ["access_key"], aws_secret_access_key = os.environ["secret_access"])
  ansibleFilter = { 'Name': 'tag:{0}'.format(ansible["tag"]), 'Values':[ansible["value"]] }
  envFilter = { 'Name': 'tag:{0}'.format(env["tag"]), 'Values':[env["value"]] }
  hosts = []
  for i in ec2.instances.filter(Filters=[ansibleFilter,envFilter]):
    if i.public_ip_address is not None:
      hosts.append(i.public_ip_address)
  if hosts:
    inventory = {"{0}".format(ansible["tag"]): hosts}
    print (json.dumps(inventory))
  else:
    print ("No servers matched with Tags '{0}: {1}' and '{2}: {3}'.".format(ansible["tag"],ansible["value"],env["tag"],env["value"]))
    exit (1)

if __name__ == "__main__":
  main()
