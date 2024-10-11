locals {
  # TODO: should allow multiple app names in case multiple apps exist in same repo
  app_name         = var.app_name
  namespace        = var.app_name # must match the namespace in the ./deploy/app/main.tf
  service_account  = var.app_name
  ecr_repositories = [var.gitub_repo]
  ecr_lifecycle_policy = jsonencode({
    "rules" : [
      {
        "rulePriority" : 1,
        "description" : "Keep only 50 untagged image, delete all others",
        "selection" : {
          "tagStatus" : "untagged",
          "countType" : "imageCountMoreThan",
          "countNumber" : 50
        },
        "action" : {
          "type" : "expire"
        }
      },
      {
        "rulePriority" : 2,
        "description" : "Delete image older than 6 months",
        "selection" : {
          "tagStatus" : "any",
          "countType" : "sinceImagePushed",
          "countUnit" : "days",
          "countNumber" : 183
        },
        "action" : {
          "type" : "expire"
        }
      }
    ]
  })
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
  for_each = toset(local.ecr_repositories)

  name                 = each.value
  image_tag_mutability = "MUTABLE"

  force_delete = true
}

resource "aws_ecr_lifecycle_policy" "this" {
  for_each = aws_ecr_repository.this

  repository = each.value.name
  policy     = local.ecr_lifecycle_policy
}

# TODO: Why is this here and not in the app ?
resource "aws_iam_policy" "get_all_secrets" {
  name        = "GetAllSecretsPolicy-${local.app_name}"
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

  role_name_prefix = "${local.app_name}-"

  assume_role_condition_test = "StringLike"
  cluster_service_accounts = {
    for stack in module.platform_ssm.lookup : stack.cluster_name =>
    ["${local.namespace}*:${local.service_account}"]
  }

  # Create and set additional policies here
  role_policy_arns = {
    get_all_secrets = aws_iam_policy.get_all_secrets.arn
    # s3 = aws_iam_policy.read_s3.arn
  }
}
