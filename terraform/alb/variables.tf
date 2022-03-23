variable "alb-sg-id" {
	type = list(string)
	default = ["sg-0911962e0a933b42d"]
	description = "List of Security Group ID"
	nullable = false
}

variable "public-subnet-ids" {
	type = list(string)
	default = ["subnet-05763703a005a54a6","subnet-099c9375c30aa2ffc"]
	description = "List of Public Subnet ID's"
	nullable = false
}

variable "vpc-id" {
	type = string
	default = "vpc-0b50411606d367af6"
	description = "VPC ID"
	nullable = false
}

variable "alb-algorithm-type" {
	type = string
	default = "round_robin"
	description = "Enter ALB Algorithm type? 'round_robin' or 'least_outstanding_requests'"
	validation {
		condition = contains (["round_robin","least_outstanding_requests"], var.alb-algorithm-type)
		error_message = "ALB Algorithm type should be 'round_robin' or 'least_outstanding_requests'!!!"
	}
}

variable "tg-port" {
	type = number
	default = 5500
	description = "Enter Target Group port"
	nullable = false
}

variable "albProtocol" {
	type = string
	default = "HTTP"
	description = "Enter ALB Protocol? 'HTTP' or 'HTTPS'"
	validation {
		condition = contains (["HTTP","HTTPS"], var.albProtocol)
		error_message = "ALB Protocol should be 'HTTPS' or 'HTTPS'!!!"
	}
}

variable "alb-port" {
	type = number
	default = 80
	description = "Enter ALB port"
	nullable = false
}

variable "sslCertARN" {
	type = string
	default = ""
	description = "Enter HTTPS Cert Arn"
	nullable = true
}