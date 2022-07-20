output "publicSubnet-ID" {
	value = module.infra.publicSubnet-ID
	description = "Public subnet ID"
}

output "InternetGatewayID" {
	value = module.infra.InternetGatewayID
	description = "Internet Gateway ID"
}

output "publicRouteTableID" {
	value = module.infra.publicRouteTableID
	description = "Public Route Table ID"
}

output "vpcID" {
	value = module.infra.vpcID
	description = "VPC ID"
}

output "sg-ID" {
	value = module.infra.sg-ID
	description = "Security Group ID"
}

output "instance-ID" {
	value = module.ec2.instance-ID
	description = "Ubuntu instance ID"
}

output "iamUser" {
	value = module.infra.iamUser
	description = "IAM User ARN"
}