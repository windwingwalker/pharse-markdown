# Input variable definitions
variable "aws_region" {
  description = "AWS region for all resources."

  type    = string
  default = "us-east-1"
}

variable "app_name" {
  type = string 
}

variable "lambda_role" {
  type = string
}

variable "api_id" {
  type = string
}

variable "api_root_resource_id" {
  type = string
}

variable "api_resource_id" {
  type = string
}

variable "api_execution_arn" {
  type = string
}

variable "tag" {
  type = string
}