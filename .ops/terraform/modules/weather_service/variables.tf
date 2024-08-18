variable "p_name" {
  type = string
}

variable "lambda_iam_role_arn" {
  type = string
}

variable "aws_cli_profile" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "account_id" {
  type = string
}

variable "aws_apigatewayv2_api_execution_arn" {
  type = string
}

variable "aws_apigatewayv2_api_main_id" {
  type = string
}
# aws_apigatewayv2_api.main.id