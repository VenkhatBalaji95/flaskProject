variable "sshKeyName" {
	default = "terraform"
	type = string
	description = "SSH Key pair name"
}

variable "publicSubnetID" {
	type = string
	description = "Public Subnet ID"
	nullable = false
}

variable "sgID" {
	type = list(string)
	description = "VPC SG ID"
	nullable = false
}