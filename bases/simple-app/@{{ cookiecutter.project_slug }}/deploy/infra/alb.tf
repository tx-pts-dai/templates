### ALB creation handled in the Aplication repository ###
### To be removed if the ALB is created in the shared stack of infrastructure repository ###


# To set whether a token is used for allowing ALB traffic
# Valid for Cloudfront context
data "aws_secretsmanager_secret_version" "cdn_secret_header" {
  secret_id = "alb-cloudfront-header-token"
}

data "terraform_remote_state" "account" {
  backend = "s3"

  config = {
    bucket = "tf-state-${data.aws_caller_identity.current.account_id}"
    # Add the key to retrieve outputs from the account remote state
    # Used to pass the bucket name to the alb module
    # key    = "remote-infrastructure/account/terraform.tfstate"
    region = local.region
  }
}

locals {
  network_stack     = "name_of_the_stack"
  public_subnet_ids = data.aws_subnets.public_subnets.ids
  vpc_id            = module.network_lookup.lookup[local.network_stack].vpc_id
  domain_names = concat(
    [var.acm_domain_names],
    var.acm_alternative_domain_names
  )
}

######## KaaS ########
module "network_lookup" {
  source  = "tx-pts-dai/kubernetes-platform/aws//modules/ssm"
  version = "0.9.1"

  base_prefix       = "infrastructure"
  stack_type        = "network"
  stack_name_prefix = local.network_stack

  lookup = [
    "vpc_id"
  ]
}

data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [module.network_lookup.lookup[local.network_stack].vpc_id]
  }
  filter {
    name   = "tag:Name"
    values = ["*public*"]
  }
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "5.1.1"

  domain_name               = var.acm_domain_names
  subject_alternative_names = var.acm_alternative_domain_names
  create_route53_records    = false
  validation_method         = "DNS"
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.11.0"

  name    = var.app_name
  vpc_id  = local.vpc_id
  subnets = local.public_subnet_ids

  # http > https managed by AWS cloudfront
  security_group_ingress_rules = {
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  security_group_egress_rules = {
    all_traffic = {
      ip_protocol = "-1"
      description = "Allow all outbound traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  security_groups = []


  access_logs = {
    enabled = true
    bucket  = data.terraform_remote_state.account.outputs.log_bucket_name
    prefix  = "/access-logs"
  }


  connection_logs = {
    enabled = true
    bucket  = data.terraform_remote_state.account.outputs.log_bucket_name
    prefix  = "/connection-logs"
  }


  listeners = {
    https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = module.acm.acm_certificate_arn

      fixed_response = {
        type         = "return-fixed-response"
        content_type = "text/plain"
        message_body = "HIT"
        status_code  = "200"

      }


      rules = [
        for domain in local.domain_names : {
          priority = 1000 + index(local.domain_names, domain)
          actions = [{
            type             = "forward"
            target_group_key = "application"
          }]

          conditions = [
            {
              host_header = {
                values = [domain]
              }
            },
            # To set whether a token is used for allowing ALB traffic
            # Valid for Cloudfront context
            {
              http_header = {
                http_header_name = jsondecode(data.aws_secretsmanager_secret_version.cdn_secret_header.secret_string)["name"]
                values           = [jsondecode(data.aws_secretsmanager_secret_version.cdn_secret_header.secret_string)["value"]]
              }
            }
          ]
        }
      ]
    }
  }

  target_groups = {
    application = {
      name              = var.app_name
      protocol          = "HTTP"
      port              = var.app_port
      target_type       = "ip"
      create_attachment = false

      health_check = {
        enabled             = true
        healthy_threshold   = 2
        unhealthy_threshold = 2
        interval            = 10
        timeout             = 5
        matcher             = "200"
        path                = var.app_health_check_path
        port                = "traffic-port"
        protocol            = "HTTP"
      }
    }
  }
}
