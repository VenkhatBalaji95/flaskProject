import argparse
import time

parser = argparse.ArgumentParser()
parser.add_argument("-n","--name",default="venkhat",help="Enter your name")
args = parser.parse_args()
args.name=args.name.strip()
print ("Name is {0}".format(args.name))
if args.name == "venkhat":
    print ("Success")
    time.sleep(2)
    print ("Sleeping...")
    time.sleep(20)
    print ("done")
    exit (0)
else:
    print ("Failed")
    time.sleep(2)
    print ("Sleeping...")
    time.sleep(20)
    print ("done")
    exit (1)
