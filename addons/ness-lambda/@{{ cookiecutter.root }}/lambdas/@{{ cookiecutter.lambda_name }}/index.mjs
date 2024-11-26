'use strict';

const secret = process.env.SECRET;
const environment = process.env.ENVIRONMENT
{% if cookiecutter.is_writing_to_sqs -%}
const sqsQueueArn = process.env.SQS_QUEUE_ARN
{% endif %}

export const handler = async (event, context) => {
    console.log("SECRET=" + secret);
    console.log("ENVIRONMENT=" + environment);
    {% if cookiecutter.is_writing_to_sqs -%}
    console.log("SQS_QUEUE_ARN=" + sqsQueueArn);
    {% endif -%}

    console.log("@{{ cookiecutter.lambda_name }} function called with event=" + JSON.stringify(event));
    return
}

// handler({ "Records": [{ "body": "{ \"Message\": { \"key\": \"value\" } }", "messageId": "my-id", }] })
