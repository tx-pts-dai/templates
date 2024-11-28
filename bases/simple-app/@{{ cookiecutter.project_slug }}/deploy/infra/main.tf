locals {
  namespace       = var.app_name # must match the namespace in the ./deploy/application/main.tf
  service_account = var.app_name
}

module "platform_ssm" {
  source  = "tx-pts-dai/kubernetes-platform/aws//modules/ssm"
  version = "0.7.0"

  base_prefix       = "infrastructure"
  stack_type        = "platform"
  stack_name_prefix = ""

  lookup = ["cluster_name"]
}

resource "aws_ecr_repository" "this" {
  name                 = var.github_repo
  image_tag_mutability = "MUTABLE"

  force_delete = true
}

resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name
  policy     = <<EOF
{
    "rules" : [
      {
        "rulePriority" : 1,
        "description" : "Delete untagged images after 8 days",
        "selection" : {
          "tagStatus" : "untagged",
          "countType" : "sinceImagePushed",
          "countUnit" : "days",
          "countNumber" : 8
        },
        "action" : {
          "type" : "expire"
        }
      },
      {
        "rulePriority" : 2,
        "description" : "Keep last 9000 images",
        "selection" : {
          "tagStatus" : "any",
          "countType" : "imageCountMoreThan",
          "countNumber" : 9000
        },
        "action" : {
          "type" : "expire"
        }
      }
    ]
}
EOF
}

resource "aws_iam_policy" "get_all_secrets" {
  name        = "GetAllSecretsPolicy-${var.app_name}"
  description = "Policy to allow getting all secrets from AWS Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "secretsmanager:GetSecretValue"
        Effect   = "Allow"
        Resource = "arn:aws:secretsmanager:eu-central-1:${data.aws_caller_identity.current.account_id}:secret:discovery/ai-tools/*"
      }
    ]
  })
}

module "iam_eks_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-eks-role"
  version = "5.32.0"

  role_name_prefix = "${var.app_name}-"

  assume_role_condition_test = "StringLike"
  cluster_service_accounts = {
    for stack in module.platform_ssm.lookup : stack.cluster_name =>
    ["${local.namespace}*:${local.service_account}"]
  }

  # Create and set additional policies here
  role_policy_arns = {
    get_all_secrets = aws_iam_policy.get_all_secrets.arn
  }
}
