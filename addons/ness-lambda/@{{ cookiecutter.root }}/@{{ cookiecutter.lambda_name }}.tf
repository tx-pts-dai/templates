locals {
  # Additional policies to attach to the lambda
  lambda_@{{ cookiecutter.lambda_name }}_policies = [
    {% if cookiecutter.is_triggered_by_sqs == "true" -%}
    "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole", # Needed to allow Lambda manage sqs, see https://docs.aws.amazon.com/lambda/latest/dg/services-sqs-configure.html#events-sqs-permissions
    {% endif %}
  ]
}

variable "@{{ cookiecutter.lambda_name }}" {
  description = "Configuration of the @{{ cookiecutter.lambda_name }} workflow"
  type = object({
    {% if cookiecutter.is_triggered_by_sqs == "true" -%}
    sqs_batch_size                        = number
    {% endif -%}
    cloudwatch_logs_retention_in_days     = number
    lambda_reserved_concurrent_executions = number
    lambda_timeout                        = number
  })
  default = {
    {% if cookiecutter.is_triggered_by_sqs == "true" -%}
    sqs_batch_size                        = 10
    {% endif -%}
    cloudwatch_logs_retention_in_days     = 7
    lambda_reserved_concurrent_executions = 2
    lambda_timeout                        = 60
  }
}

module "@{{ cookiecutter.lambda_name }}" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.0"

  function_name          = "${var.environment}-@{{ cookiecutter.lambda_name }}"
  description            = "@{{ cookiecutter.description }}"
  source_path            = "./lambdas/@{{ cookiecutter.lambda_name }}"
  handler                = "index.handler"
  runtime                = "nodejs20.x"
  timeout                = var.@{{ cookiecutter.lambda_name }}.lambda_timeout
  memory_size            = 256
  # layers                 = [aws_lambda_layer_version.common_lib.arn]
  vpc_subnet_ids         = data.aws_subnets.private_subnets.ids
  vpc_security_group_ids = [aws_security_group.vpc_lambda.id]
  attach_network_policy  = true
  environment_variables = {
    ENVIRONMENT = var.environment
    SECRET      = var.studio_secret
  }
  create_current_version_allowed_triggers = false // If not false then we get `adding Lambda Permission (...lambda-name/SQSQueue): ...InvalidParameterValueException: We currently do not support adding policies for $LATEST.` when not set
  cloudwatch_logs_retention_in_days       = var.@{{ cookiecutter.lambda_name }}.cloudwatch_logs_retention_in_days

  reserved_concurrent_executions = var.@{{ cookiecutter.lambda_name }}.lambda_reserved_concurrent_executions

  {% if cookiecutter.is_triggered_by_sqs == "true" -%}
  allowed_triggers = {
    SQSQueue = {
      principal  = "sqs.amazonaws.com"
      source_arn = module.@{{ cookiecutter.lambda_name }}_queue.queue_arn
    }

  event_source_mapping = {
    sqs_queue = {
      maximum_batching_window_in_seconds = 5
      batch_size                         = var.@{{ cookiecutter.lambda_name }}.sqs_batch_size
      event_source_arn                   = module.@{{ cookiecutter.lambda_name }}_queue.queue_arn
      function_response_types            = ["ReportBatchItemFailures"]
      scaling_config = {
        # maximum_concurrency can be between 2 and 2000
        maximum_concurrency = min(max(var.@{{ cookiecutter.lambda_name }}.lambda_reserved_concurrent_executions, 2), 2000)
      }
    }
  }
  {% endif -%}

  attach_policies    = length(local.lambda_@{{ cookiecutter.lambda_name }}_policies) > 0
  number_of_policies = length(local.lambda_@{{ cookiecutter.lambda_name }}_policies)
  policies           = local.lambda_@{{ cookiecutter.lambda_name }}_policies

  attach_policy_json = true
  policy_json        = data.aws_iam_policy_document.@{{ cookiecutter.lambda_name }}_permissions.json
}

{% if cookiecutter.is_triggered_by_scheduler == "true" %}
resource "aws_scheduler_schedule" "@{{ cookiecutter.lambda_name }}" {
  name                         = "${var.environment}-@{{ cookiecutter.lambda_name }}"
  description                  = "Schedule for @{{ cookiecutter.lambda_name }} lambda"
  schedule_expression          = "@{{ cookiecutter.schedule_expression }}"
  schedule_expression_timezone = "@{{ cookiecutter.schedule_timezone }}"

  flexible_time_window {
    mode = "OFF"
  }
  target {
    arn      = module.@{{ cookiecutter.lambda_name }}.lambda_function_arn
    role_arn = aws_iam_role.@{{ cookiecutter.lambda_name }}.arn
  }
}

data "aws_iam_policy_document" "@{{ cookiecutter.lambda_name }}_assume_role" {
  version = "2012-10-17"
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "@{{ cookiecutter.lambda_name }}" {
  version = "2012-10-17"
  statement {
    actions   = ["lambda:InvokeFunction"]
    effect    = "Allow"
    resources = [module.@{{ cookiecutter.lambda_name }}.lambda_function_arn]
  }
}

resource "aws_iam_policy" "@{{ cookiecutter.lambda_name }}" {
  name        = "${var.environment}-@{{ cookiecutter.lambda_name }}"
  description = "Allow AWS Scheduler to invoke @{{ cookiecutter.lambda_name }} lambda"
  policy      = data.aws_iam_policy_document.@{{ cookiecutter.lambda_name }}.json
}

resource "aws_iam_role" "@{{ cookiecutter.lambda_name }}" {
  name               = "${var.environment}-@{{ cookiecutter.lambda_name }}"
  description        = "Allow AWS Scheduler to invoke @{{ cookiecutter.lambda_name }} lambda"
  assume_role_policy = data.aws_iam_policy_document.@{{ cookiecutter.lambda_name }}_assume_role.json
}

resource "aws_iam_role_policy_attachment" "@{{ cookiecutter.lambda_name }}" {
  role       = aws_iam_role.@{{ cookiecutter.lambda_name }}.name
  policy_arn = module.@{{ cookiecutter.lambda_name }}.lambda_function_arn
}
{% endif -%}

{%- if cookiecutter.is_triggered_by_sqs == "true" %}
module "@{{ cookiecutter.sqs_queue}}_queue" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "~> 4.2"

  name = "${var.environment}-ness-@{{ cookiecutter.sqs_queue }}"

  create_dlq                    = true
  dlq_message_retention_seconds = 604800                                # 604800 = 1 week
  visibility_timeout_seconds    = 6 * var.@{{ cookiecutter.lambda_name }}.lambda_timeout # 6x lambda timeout, see https://docs.aws.amazon.com/lambda/latest/dg/services-sqs-configure.html#events-sqs-queueconfig
  redrive_policy = {
    maxReceiveCount = 2
  }
}
{% endif -%}

# Extra permissions needed by the lambda
data "aws_iam_policy_document" "@{{ cookiecutter.lambda_name }}_permissions" {
  statement {
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]
    resources = [
      "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:${var.studio_secret}*"
    ]
  }
}
