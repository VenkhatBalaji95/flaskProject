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
		key = "iam/policy.tfstate"
		skip_metadata_api_check = false
		dynamodb_table = "terraform"
		workspace_key_prefix = "environment"
	}
}

provider "aws" {
	region = "ap-south-1"
}

data "terraform_remote_state" "iamUser" {
  backend = "s3"
  config = {
    bucket = "terraform-ba"
    key    = "iam/user.tfstate"
    region = "ap-south-1"
  }
}

resource "aws_iam_user_policy_attachment" "attachPolicy" {
	depends_on = [data.terraform_remote_state.iamUser]
	for_each = data.terraform_remote_state.iamUser.outputs.iamUser
	user = each.key
	policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

output "iamUsers" {
	value = data.terraform_remote_state.iamUser.outputs.iamUser
}