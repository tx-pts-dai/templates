locals {
  # Additional policies to attach to the lambda
  lambda_@{{ cookiecutter.__lambda_name_tf_normalized }}_policies = [
    {% if cookiecutter.is_triggered_by_sqs -%}
    "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole", # Needed to allow Lambda manage sqs, see https://docs.aws.amazon.com/lambda/latest/dg/services-sqs-configure.html#events-sqs-permissions
    {% endif -%}
  ]
}

variable "@{{ cookiecutter.__lambda_name_tf_normalized }}" {
  description = "Configuration of the @{{ cookiecutter.lambda_name }} workflow"
  type = object({
    {% if cookiecutter.is_triggered_by_sqs -%}
    sqs_batch_size                        = number
    {% endif -%}
    cloudwatch_logs_retention_in_days     = number
    lambda_reserved_concurrent_executions = number
    lambda_timeout                        = number
  })
  default = {
    {% if cookiecutter.is_triggered_by_sqs -%}
    sqs_batch_size                        = 10
    {% endif -%}
    cloudwatch_logs_retention_in_days     = 7
    lambda_reserved_concurrent_executions = 2
    lambda_timeout                        = 60
  }
}

module "@{{ cookiecutter.__lambda_name_tf_normalized }}" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.0"

  function_name          = "${var.environment}-@{{ cookiecutter.lambda_name }}"
  description            = "@{{ cookiecutter.description }}"
  source_path            = "./lambdas/@{{ cookiecutter.lambda_name }}"
  handler                = "index.handler"
  runtime                = "nodejs20.x"
  timeout                = var.@{{ cookiecutter.__lambda_name_tf_normalized }}.lambda_timeout
  memory_size            = 256
  # layers                 = [aws_lambda_layer_version.common_lib.arn]
  vpc_subnet_ids         = data.aws_subnets.private_subnets.ids
  vpc_security_group_ids = [aws_security_group.vpc_lambda.id]
  attach_network_policy  = true
  environment_variables = {
    ENVIRONMENT  = var.environment
    SECRET       = var.@{{ cookiecutter.tf_secret_name }}
    {% if cookiecutter.is_writing_to_sqs -%}
   SQS_QUEUE_ARN = module.@{{ cookiecutter.__sqs_queue_tf_normalized }}_queue.queue_arn
   {% endif -%}
  }
  create_current_version_allowed_triggers = false // If not false then we get `adding Lambda Permission (...lambda-name/SQSQueue): ...InvalidParameterValueException: We currently do not support adding policies for $LATEST.` when not set
  cloudwatch_logs_retention_in_days       = var.@{{ cookiecutter.__lambda_name_tf_normalized }}.cloudwatch_logs_retention_in_days

  reserved_concurrent_executions = var.@{{ cookiecutter.__lambda_name_tf_normalized }}.lambda_reserved_concurrent_executions

  {% if cookiecutter.is_triggered_by_sqs -%}
  allowed_triggers = {
    SQSQueue = {
      principal  = "sqs.amazonaws.com"
      source_arn = module.@{{ cookiecutter.__sqs_queue_tf_normalized }}_queue.queue_arn
    }
  }

  event_source_mapping = {
    sqs_queue = {
      maximum_batching_window_in_seconds = 5
      batch_size                         = var.@{{ cookiecutter.__lambda_name_tf_normalized }}.sqs_batch_size
      event_source_arn                   = module.@{{ cookiecutter.__sqs_queue_tf_normalized }}_queue.queue_arn
      function_response_types            = ["ReportBatchItemFailures"]
      scaling_config = {
        # maximum_concurrency can be between 2 and 2000
        maximum_concurrency = min(max(var.@{{ cookiecutter.__lambda_name_tf_normalized }}.lambda_reserved_concurrent_executions, 2), 2000)
      }
    }
  }
  {% endif -%}

  attach_policies    = length(local.lambda_@{{ cookiecutter.__lambda_name_tf_normalized }}_policies) > 0
  number_of_policies = length(local.lambda_@{{ cookiecutter.__lambda_name_tf_normalized }}_policies)
  policies           = local.lambda_@{{ cookiecutter.__lambda_name_tf_normalized }}_policies

  attach_policy_json = true
  policy_json        = data.aws_iam_policy_document.@{{ cookiecutter.__lambda_name_tf_normalized }}_permissions.json
}

{% if cookiecutter.is_triggered_by_scheduler %}
resource "aws_scheduler_schedule" "@{{ cookiecutter.__lambda_name_tf_normalized }}" {
  name                         = "${var.environment}-@{{ cookiecutter.lambda_name }}-${random_string.this.id}"
  description                  = "Schedule for @{{ cookiecutter.lambda_name }} lambda"
  schedule_expression          = "@{{ cookiecutter.schedule_expression }}"
  schedule_expression_timezone = "@{{ cookiecutter.schedule_timezone }}"

  flexible_time_window {
    mode = "OFF"
  }
  target {
    arn      = module.@{{ cookiecutter.__lambda_name_tf_normalized }}.lambda_function_arn
    role_arn = aws_iam_role.@{{ cookiecutter.__lambda_name_tf_normalized }}.arn
  }
}

data "aws_iam_policy_document" "@{{ cookiecutter.__lambda_name_tf_normalized }}_assume_role" {
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

data "aws_iam_policy_document" "@{{ cookiecutter.__lambda_name_tf_normalized }}" {
  version = "2012-10-17"
  statement {
    actions   = ["lambda:InvokeFunction"]
    effect    = "Allow"
    resources = [module.@{{ cookiecutter.__lambda_name_tf_normalized }}.lambda_function_arn]
  }
}

resource "aws_iam_policy" "@{{ cookiecutter.__lambda_name_tf_normalized }}" {
  name        = "${var.environment}-@{{ cookiecutter.lambda_name }}-${random_string.this.id}"
  description = "Allow AWS Scheduler to invoke @{{ cookiecutter.lambda_name }} lambda"
  policy      = data.aws_iam_policy_document.@{{ cookiecutter.__lambda_name_tf_normalized }}.json
}

resource "aws_iam_role" "@{{ cookiecutter.__lambda_name_tf_normalized }}" {
  name               = "${var.environment}-@{{ cookiecutter.lambda_name }}-${random_string.this.id}"
  description        = "Allow AWS Scheduler to invoke @{{ cookiecutter.lambda_name }} lambda"
  assume_role_policy = data.aws_iam_policy_document.@{{ cookiecutter.__lambda_name_tf_normalized }}_assume_role.json
}

resource "aws_iam_role_policy_attachment" "@{{ cookiecutter.__lambda_name_tf_normalized }}" {
  role       = aws_iam_role.@{{ cookiecutter.__lambda_name_tf_normalized }}.name
  policy_arn = aws_iam_policy.@{{ cookiecutter.__lambda_name_tf_normalized }}.arn
}
{% endif -%}

{%- if cookiecutter.is_triggered_by_sqs %}
module "@{{ cookiecutter.__sqs_queue_tf_normalized}}_queue" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "~> 4.2"

  name = "${var.environment}-ness-@{{ cookiecutter.sqs_queue }}"

  create_dlq                    = true
  dlq_message_retention_seconds = 604800                                # 604800 = 1 week
  visibility_timeout_seconds    = 6 * var.@{{ cookiecutter.__lambda_name_tf_normalized }}.lambda_timeout # 6x lambda timeout, see https://docs.aws.amazon.com/lambda/latest/dg/services-sqs-configure.html#events-sqs-queueconfig
  redrive_policy = {
    maxReceiveCount = 2
  }
}
{% endif %}

# Extra permissions needed by the lambda
data "aws_iam_policy_document" "@{{ cookiecutter.__lambda_name_tf_normalized }}_permissions" {
  statement {
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]
    resources = [
      "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:${var.@{{ cookiecutter.tf_secret_name }}}*"
    ]
  }
  {% if cookiecutter.is_writing_to_sqs -%}
  statement {
    actions = [
      "sqs:SendMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl"
    ]
    resources = [
      module.@{{ cookiecutter.__sqs_queue_tf_normalized }}_queue.queue_arn
    ]
  }
  {% endif -%}
}
