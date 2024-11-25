'use strict';

const secret = process.env.SECRET;
const environment = process.env.ENVIRONMENT

export const handler = async (event, context) => {
    console.log("SECRET=" + secret);
    console.log("ENVIRONMENT=" + environment);
    console.log("@{{ cookiecutter.lambda_name }} function called with event=" + JSON.stringify(event));
    return
}

// handler({ "Records": [{ "body": "{ \"Message\": { \"key\": \"value\" } }", "messageId": "my-id", }] })
