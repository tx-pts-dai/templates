# Ness Lambda triggered by cron or SQS

This addon is simply to manage an AWS lambda triggered by cron of SQS

At the end it create a terraform file and the skeleton of a nodejs lambda in an existing repository.

If the lambda is triggered by cron, it will have permission to write to an SQS queue
If the lambda is triggered by sqs, the queue will be created

As it's an addon, they are dependencies on terraform resources which should be present in the repo:

- `aws_security_group.vpc_lambda` the security group to attach to the lambda
- `aws_vpc_security_group_egress_rule.vpc_lambda` egress in the above security group
- `var.studio_secret` the name of the secret the lambda will use to get info on how to connect to studio
- `var.environment` the environment for which the lambda will run
