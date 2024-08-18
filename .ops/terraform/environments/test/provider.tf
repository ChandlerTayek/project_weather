terraform {
    required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.62"
    }
  }
    required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
  profile = var.aws_cli_profile
}