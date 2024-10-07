locals {
  region = "@{{ cookiecutter.aws_region }}"
}

terraform {
  required_version = "~> 1.9.2"

  backend "s3" {
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = local.region

  default_tags {
    tags = {
      Terraform   = "true"
      Environment = var.metadata.environment
      GithubRepo  = var.metadata.github_repo
      GithubOrg   = var.metadata.github_org
    }
  }
}

data "aws_caller_identity" "current" {}
