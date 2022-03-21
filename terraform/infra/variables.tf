variable "vpcCIDR" {
	default = "10.0.0.0/16"
	type = string
	description = "Enter vpc CIDR block"
	nullable = false
}

variable "env" {
	default = "dit"
	type = string
	description = "Enter your environment name (options: dit, sit)"
	validation {
		condition = contains (["dit","sit"], var.env)
		error_message = "Env must be either 'dit' or 'sit'!"
	}
}

variable "user" {
	default = "gameChanger"
	type = string
	description = "Enter your name"
	validation {
		condition = can(regex("^[A-Z a-z]+", var.user))
		error_message = "Your name must start with letters!"
	}
	nullable = false
}

variable "publicSubnet1" {
	default = "10.0.1.0/24"
	type = string
	description = "Enter first public subnet's CIDR block"
	nullable = false
}

variable "publicSubnet2" {
	default = "10.0.2.0/24"
	type = string
	description = "Enter second public subnet's CIDR block"
	nullable = false
}

variable "privateSubnet1" {
	default = "10.0.3.0/24"
	type = string
	description = "Enter first private subnet's CIDR block"
	nullable = false
}

variable "privateSubnet2" {
	default = "10.0.4.0/24"
	type = string
	description = "Enter second private subnet's CIDR block"
	nullable = false
}

variable "natAmiName" {
	default = "amzn-ami-vpc-nat"
	type = string
	description = "Enter NAT AMI name"
}

variable "sshKeyName" {
	default = "eks"
	type = string
	description = "SSH Key pair name"
}

variable "natInstancePrivateIP1" {
	default = "10.0.1.10"
	type = string
	description = "Enter Private IP address for NAT instance"
}