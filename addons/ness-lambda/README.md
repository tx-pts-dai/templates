# Ness Lambda triggered by cron or SQS

This addon is simply to manage an AWS lambda triggered by cron of SQS

At the end it create a terraform file and the skeleton of a nodejs lambda in an existing repository.

If the lambda is triggered by cron, it will have permission to write to an SQS queue
If the lambda is triggered by sqs, the queue will be created

As it's an addon, they are dependencies on terraform resources which should be present in the repo:

- `data.aws_vpc.vpc_app_prod` the VPC in which the lambda should be attached
- `data.aws_subnets.private_subnets` the subnets the lambda should be attached
- `data.aws_region.current` the AWS region to deploy too
- `data.aws_caller_identity.current` to retrieve tha AWS account id
- `aws_security_group.vpc_lambda` the security group to attach to the lambda
- `aws_vpc_security_group_egress_rule.vpc_lambda` egress in the above security group
- `var.environment` the environment for which the lambda will run
- `var.A_SECRET_NAME` a variable with the name of a secret (the name will be asked by `tam-cli`and will be passed as environment variable to the lambda). Usefull to get infos on how to connect to some external APIs
- `random_string.this` used to name some AWS resources to avoid duplicates

So the following terraform code should exists in the destination repo:

```terraform
terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

resource "random_string" "this" {
  length  = 4
  special = false
  numeric = false
  upper   = false
}

resource "aws_security_group" "vpc_lambda" {
  name        = "${var.environment}-YOUR-REPO-NAME"
  description = "Security group attached to the lambdas"
  vpc_id      = data.aws_vpc.vpc_app_prod.id
}

resource "aws_vpc_security_group_egress_rule" "vpc_lambda" {
  security_group_id = aws_security_group.vpc_lambda.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = -1
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_vpc" "vpc_app_prod" {
  tags = {
    Name      = "VPCApp-Prod"
    Landscape = "Prod"
  }
}

data "aws_subnets" "private_subnets" {
  filter {
    name   = "tag:Name"
    values = ["VPCApp-Prod-Private1", "VPCApp-Prod-Private2", "VPCApp-Prod-Private3"]
  }
}

variable "environment" {
  description = "The environment this resource will be deployed in."
  type        = string
}

variable "A_SECRET_NAME" {
  description = "Name of the secret with the infos to connect to studio"
  type        = string
}
```

## To improve

- Create a "ness-lambda" terraform module and let this template instanciate the module.
- Reduce the number of test in the template (create generic terraform file and let the user choose what to keep)
