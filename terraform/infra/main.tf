terraform {
	required_providers {
		aws = {
			source = "hashicorp/aws"
			version = "~> 3.0"
		}
	}
}

provider aws {
	region = "ap-south-1"
}

resource "aws_vpc" "createVpc" {
	count = ( var.env == "dit" && var.user == "gameChanger" ? 1 : 0 )
	cidr_block = "${var.vpcCIDR}"
	enable_dns_hostnames = true
	tags = {
		Name = "${var.env}-vpc-terraform"
		User = "${var.user}"
	}
}

resource "aws_internet_gateway" "createAttachIG" {
	depends_on = [aws_vpc.createVpc]
	vpc_id = aws_vpc.createVpc[0].id
	tags = {
		Name = "${var.env}-IG-terraform"
	}
}

resource "aws_route_table" "publicRouteTable" {
	depends_on = [aws_vpc.createVpc]
	vpc_id = aws_vpc.createVpc[0].id
	tags = {
		Name = "${var.env}-public-route-terraform"
	}
}

resource "aws_route" "addPublicRotue" {
	depends_on = [aws_route_table.publicRouteTable, aws_internet_gateway.createAttachIG]
	route_table_id = aws_route_table.publicRouteTable.id
	destination_cidr_block = "0.0.0.0/0"
	gateway_id = aws_internet_gateway.createAttachIG.id
}

resource "aws_route_table" "privateRouteTable" {
	depends_on = [aws_vpc.createVpc]
	vpc_id = aws_vpc.createVpc[0].id
	tags = {
		Name = "${var.env}-private-route-terraform"
	}
}

resource "aws_subnet" "createPublicSubnet1" {
	depends_on = [aws_vpc.createVpc]
	vpc_id = aws_vpc.createVpc[0].id
	cidr_block = var.publicSubnet1
	availability_zone = local.zoneMap.az1
	map_public_ip_on_launch = true
	tags = {
		Name = "${var.env}-public-subnet1-terraform"
	}
}

resource "aws_route_table_association" "publicSubnet1Route" {
	depends_on = [aws_subnet.createPublicSubnet1, aws_route_table.publicRouteTable]
	subnet_id = aws_subnet.createPublicSubnet1.id
	route_table_id = aws_route_table.publicRouteTable.id
}

resource "aws_subnet" "createPublicSubnet2" {
	depends_on = [aws_vpc.createVpc]
	vpc_id = aws_vpc.createVpc[0].id
	cidr_block = var.publicSubnet2
	availability_zone = local.zoneMap.az2
	map_public_ip_on_launch = true
	tags = {
		Name = "${var.env}-public-subnet2-terraform"
	}
}

resource "aws_route_table_association" "publicSubnet2Route" {
	depends_on = [aws_subnet.createPublicSubnet2, aws_route_table.publicRouteTable]
	subnet_id = aws_subnet.createPublicSubnet2.id
	route_table_id = aws_route_table.publicRouteTable.id
}

resource "aws_subnet" "createPrivateSubnet1" {
	depends_on = [aws_vpc.createVpc]
	vpc_id = aws_vpc.createVpc[0].id
	cidr_block = var.privateSubnet1
	availability_zone = local.zoneMap.az1
	tags = {
		Name = "${var.env}-private-subnet1-terraform"
	}
}

resource "aws_route_table_association" "privateSubnet1Route" {
	depends_on = [aws_subnet.createPrivateSubnet1, aws_route_table.privateRouteTable]
	subnet_id = aws_subnet.createPrivateSubnet1.id
	route_table_id = aws_route_table.privateRouteTable.id
}

resource "aws_subnet" "createPrivateSubnet2" {
	depends_on = [aws_vpc.createVpc]
	vpc_id = aws_vpc.createVpc[0].id
	cidr_block = var.privateSubnet2
	availability_zone = local.zoneMap.az2
	tags = {
		Name = "${var.env}-private-subnet2-terraform"
	}
}

resource "aws_route_table_association" "privateSubnet2Route" {
	depends_on = [aws_subnet.createPrivateSubnet2, aws_route_table.privateRouteTable]
	subnet_id = aws_subnet.createPrivateSubnet2.id
	route_table_id = aws_route_table.privateRouteTable.id
}

resource "aws_security_group" "natSG" {
	depends_on = [aws_vpc.createVpc]
	vpc_id = aws_vpc.createVpc[0].id
	name = "NAT-SG-${var.env}-terraform"
	description = "NAT instance Security group"
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
		Name = "NAT-SG-${var.env}-terraform"
	} 
}

resource "aws_security_group" "loadBalancerSG" {
	depends_on = [aws_vpc.createVpc]
	vpc_id = aws_vpc.createVpc[0].id
	name = "LB-SG-${var.env}-terraform"
	description = "Load balancer Security group"
	ingress {
		from_port = 80
		to_port = 80
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
		description = "Open HTTP Port to all"
	}
	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
		description = "Send the traffic to all"
	}
	tags = {
		Name = "LB-SG-${var.env}-terraform"
	}
}

resource "aws_security_group" "appSG" {
	depends_on = [aws_vpc.createVpc, aws_security_group.natSG, aws_security_group.loadBalancerSG]
	vpc_id = aws_vpc.createVpc[0].id
	name = "APP-SG-${var.env}-terraform"
	description = "App Security Group"
	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		security_groups = [aws_security_group.natSG.id]
		description = "Open 22 port for NAT SG ID alone"
	}
	ingress {
		from_port = 5500
		to_port = 5500
		protocol = "tcp"
		security_groups = [aws_security_group.loadBalancerSG.id]
		description = "Open 5500 port for Load Balancer SG ID alone"
	}
	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
		description = "Send the traffic to all"
	}
	tags = {
		Name = "APP-SG-${var.env}-terraform"
	}
}

resource "aws_security_group" "efsSG" {
	depends_on = [aws_vpc.createVpc, aws_security_group.appSG]
	vpc_id = aws_vpc.createVpc[0].id
	name = "EFS-SG-${var.env}-terraform"
	description = "EFS Security group"
	ingress {
		from_port = 2049
		to_port = 2049
		protocol = "tcp"
		security_groups = [aws_security_group.appSG.id]
		description = "Open 2049 port for App SG ID alone"
	}
	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
		description = "Send the traffic to all"
	}
	tags = {
		Name = "EFS-SG-${var.env}-terraform"
	}
}

resource "aws_network_interface" "natNI" {
	depends_on =[aws_vpc.createVpc, aws_security_group.natSG, aws_subnet.createPublicSubnet1]
	subnet_id = aws_subnet.createPublicSubnet1.id
	private_ips = [var.natInstancePrivateIP1]
	security_groups = [aws_security_group.natSG.id]
	source_dest_check = false
}

resource "aws_instance" "natInstance" {
	depends_on =[aws_vpc.createVpc, aws_network_interface.natNI, aws_subnet.createPublicSubnet1]
	ami = data.aws_ami.natAMI.id
	availability_zone = local.zoneMap.az1
	instance_type = "t2.micro"
	monitoring = false
	hibernation = false
	key_name = var.sshKeyName
	network_interface {
		delete_on_termination = false
		device_index = 0
		network_interface_id = aws_network_interface.natNI.id
	}
	tags = {
		Name = "NAT-INSTANCE-${var.env}-terraform"
	}
	user_data = <<EOT
	!/bin/bash
  yum update -y
  EOT
}