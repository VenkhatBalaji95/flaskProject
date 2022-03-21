data "aws_ami" "natAMI" {
	owners = ["amazon"]
	most_recent = true
	filter {
		name = "name"
		values = ["${var.natAmiName}*"]
	}
	filter {
		name = "state"
		values = ["available"]
	}
	filter {
		name = "root-device-type"
		values = ["ebs"]
	}
	name_regex = "^amzn-ami-vpc-nat(.*)$"
}