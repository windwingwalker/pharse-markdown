terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.48.0"
    }
  }
 
  required_version = "~> 1.0"
}

provider "aws" {
  region = var.aws_region
}

module "lambda" {
  source = "./modules/lambda/"
  app_name = var.app_name
  lambda_role = var.lambda_role
  tag = var.tag
}

module "api" {
  source = "./modules/api/"
  app_name = var.app_name
  aws_region = var.aws_region
}