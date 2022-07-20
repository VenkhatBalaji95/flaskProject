terraform {
	required_providers {
		aws = {
			source = "hashicorp/aws"
			version = "~> 3.0"
		}
	}
	backend "s3" {
		region = "ap-south-1"
		bucket = "venkhat-balaji"
		key = "hcl/terraform/demo.tfstate"
		dynamodb_table = "infra-terraform"
	}
}

provider "aws" {
	region = "ap-south-1"
}

module "infra" {
	source = "./infra"
	vpcCIDR = "123.0.0.0/16"
	publicSubnet = "123.0.1.0/24"
}

module "ec2" {
	depends_on = [module.infra.publicSubnet-ID, module.infra.sg-ID]
	source = "./ec2-instance"
	publicSubnetID = module.infra.publicSubnet-ID
	sgID = [module.infra.sg-ID]
}