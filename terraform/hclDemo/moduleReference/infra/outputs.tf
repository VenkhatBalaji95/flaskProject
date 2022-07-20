output "vpcID" {
	value = aws_vpc.createVpc.id
	description = "VPC ID"
}

output "InternetGatewayID" {
	value = aws_internet_gateway.createAttachIG.id
	description = "Internet Gateway ID"
}

output "publicRouteTableID" {
	value = aws_route_table.publicRouteTable.id
	description = "Public Route Table ID"
}

output "publicSubnet-ID" {
	value = aws_subnet.createPublicSubnet.id
	description = "Public subnet ID"
}

output "sg-ID" {
	value = aws_security_group.SG.id
	description = "Security Group ID"
}

output "iamUser" {
	value = {
    	for k, v in aws_iam_user.createIAMUser : k => v.arn
  	}
	description = "IAM User ARN"
}