variable "lambda_function_invoke_arn" {
  description = "Lambda's Arn for API Gateway to invoke lambda"
}

variable "lambda_function_name" {
  description = "Name of the lambda"
}

variable "app_name" {
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

variable "api_execution_arn"{
  type = string
}