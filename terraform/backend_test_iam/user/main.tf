terraform {
	required_providers {
		aws = {
			source = "hashicorp/aws"
			version = "~> 3.0"
		}
	}
	backend "s3" {
		region = "ap-south-1"
		bucket = "terraform-ba"
		key = "iam/user.tfstate"
		skip_metadata_api_check = false
		dynamodb_table = "terraform"
		workspace_key_prefix = "environment"
	}
}

provider "aws" {
	region = "ap-south-1"
}

locals {
	iamUser = ["venkhat","balaji"]
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

output "iamUser" {
	value = {
    for k, v in aws_iam_user.createIAMUser : k => v.arn
  }
	description = "IAM User ARN"
}