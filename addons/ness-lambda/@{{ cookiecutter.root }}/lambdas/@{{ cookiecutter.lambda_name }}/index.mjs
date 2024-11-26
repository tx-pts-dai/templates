'use strict';

const secret = process.env.SECRET;
const environment = process.env.ENVIRONMENT
{% if cookiecutter.is_writting_to_sqs == "true" -%}
const sqsQueueArn = process.env.SQS_QUEUE_ARN
{% endif %}

export const handler = async (event, context) => {
    console.log("SECRET=" + secret);
    console.log("ENVIRONMENT=" + environment);
    {% if cookiecutter.is_writting_to_sqs == "true" -%}
    console.log("SQS_QUEUE_ARN=" + sqsQueueArn);
    {% endif -%}

    console.log("@{{ cookiecutter.lambda_name }} function called with event=" + JSON.stringify(event));
    return
}

// handler({ "Records": [{ "body": "{ \"Message\": { \"key\": \"value\" } }", "messageId": "my-id", }] })
