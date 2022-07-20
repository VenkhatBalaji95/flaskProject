resource "aws_vpc" "createVpc" {
	cidr_block = "${var.vpcCIDR}"
	enable_dns_hostnames = true
	tags = {
		Name = "vpc-terraform"
	}
}

resource "aws_internet_gateway" "createAttachIG" {
	vpc_id = aws_vpc.createVpc.id
	tags = {
		Name = "IG-terraform"
	}
}

resource "aws_route_table" "publicRouteTable" {
	depends_on = [aws_vpc.createVpc]
	vpc_id = aws_vpc.createVpc.id
	tags = {
		Name = "public-route-terraform"
	}
}

resource "aws_route" "addPublicRotue" {
	depends_on = [aws_route_table.publicRouteTable, aws_internet_gateway.createAttachIG]
	route_table_id = aws_route_table.publicRouteTable.id
	destination_cidr_block = "0.0.0.0/0"
	gateway_id = aws_internet_gateway.createAttachIG.id
}

resource "aws_subnet" "createPublicSubnet" {
	depends_on = [aws_vpc.createVpc]
	vpc_id = aws_vpc.createVpc.id
	cidr_block = var.publicSubnet
	availability_zone = "ap-south-1a"
	map_public_ip_on_launch = true
	tags = {
		Name = "public-subnet-terraform"
	}
}

resource "aws_route_table_association" "publicSubnetRoute" {
	subnet_id = aws_subnet.createPublicSubnet.id
	route_table_id = aws_route_table.publicRouteTable.id
}

resource "aws_security_group" "SG" {
	vpc_id = aws_vpc.createVpc.id
	name = "SSH-terraform-SG"
	description = "SSH"
	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
		description = "Open SSH Port to all"
	}
	ingress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = [var.vpcCIDR]
		description = "Open all Ports for VPC"
	}
	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
		description = "Send the traffic to all"
	}
	tags = {
		Name = "SG-terraform"
	} 
}

resource "aws_iam_user" "createIAMUser" {
	for_each = toset(local.iamUser)
	name = each.key
	path = "/"
	tags = {
		Name = "terraform-${each.key}"
		Workspace = "${terraform.workspace}"
	}
}