data "aws_caller_identity" "current" {}

variable "aws_region" {
  type = string
}

variable "p_name" {
  type = string
}

variable "aws_cli_profile" {
  type = string
}