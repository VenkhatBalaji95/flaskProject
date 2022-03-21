output "vpcID" {
	value = ( var.env == "dit" && var.user == "gameChanger" ? aws_vpc.createVpc[0].id : "N/A" )
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

output "privateRouteTableID" {
	value = aws_route_table.privateRouteTable.id
	description = "Private Route Table ID"
}

output "publicSubnet1-ID" {
	value = aws_subnet.createPublicSubnet1.id
	description = "Public subnet1 ID"
}

output "publicSubnet2-ID" {
	value = aws_subnet.createPublicSubnet2.id
	description = "Public subnet2 ID"
}

output "privateubnet1-ID" {
	value = aws_subnet.createPrivateSubnet1.id
	description = "Private subnet1 ID"
}

output "privateubnet2-ID" {
	value = aws_subnet.createPrivateSubnet2.id
	description = "Private subnet2 ID"
}

output "NAT-SG-ID" {
	value = aws_security_group.natSG.id
	description = "NAT SG ID"
}

output "LB-SG-ID" {
	value = aws_security_group.loadBalancerSG.id
	description = "LB SG ID"
}

output "App-SG-ID" {
	value = aws_security_group.appSG.id
	description = "App SG ID"
}

output "EFS-SG-ID" {
	value = aws_security_group.efsSG.id
	description = "EFS SG ID"
}

output "ami-ID" {
	value = data.aws_ami.natAMI.id
	description = "NAT AMI ID"
}

output "NAT-Instance-ID" {
	value = aws_instance.natInstance.id
	description = "NAT EC2 Instance ID"
}