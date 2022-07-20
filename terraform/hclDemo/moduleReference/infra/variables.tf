variable "vpcCIDR" {
	default = "10.0.0.0/16"
	type = string
	description = "Enter vpc CIDR block"
	nullable = false
}

variable "publicSubnet" {
	default = "10.0.1.0/24"
	type = string
	description = "Enter public subnet's CIDR block"
	nullable = false
}