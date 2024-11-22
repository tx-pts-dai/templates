'use strict';

const secret = process.env.SECRET;
const environment = process.env.ENVIRONMENT

// Example usage:
//
// 1. Send a SNS message to the topic:
//   $ SNS_MESSAGE='{"payload":"this is a test"}'
//   $ TOPIC_ARN=arn:aws:sns:eu-west-1:331393623535:dev-{{ cookiecutter.lambda_name }}
//   $ aws sns publish --topic-arn $TOPIC_ARN --message "$SNS_MESSAGE"
//
// 2. After a couple of seconds, the lambda will be called with this content in 'event':
//   {
//       "Records": [
//           {
//               "messageId": "6753f39c-ed31-4168-8368-00d6cbd157b8",
//               "receiptHandle": "AQEBv5G2KhnP/bX8UlCo8+B5JxF1uOJ+9Z3QxqR0q/EofK/vaibDowOSovuvthydu/iYxdgnE+ogZYStMK+POFH4vOhe1Xv6s2NjdKDssbebeQxLEURZXuAXfigjPCvcRGtDDntJw4MW8UQYQeF3KSj4TbVk8tdjA9useVsMJpJvNU+vpZZs3UVkVaKuGcSjCWk0/2AeVFxRDDQbsCD+1GYhvTbPvaEXmAcrUUBqUmYIpZW1unYTkYYanoVo/HulyL2aUz+77SVHglVDo8hBoEPz312ULvuRlgIk8QvydZXOmn9AuvAe+6MPkJRCYLCh1YpKXoHCe2AtCHYoPfBfGHZ3ytk5gLKLTL22WaeMxRcgnc3/P+7t9sHf9F+4/AReNDVxDRak21oFe0c71SE8TZsR6g==",
//               "body": "{\n  \"Type\" : \"Notification\",\n  \"MessageId\" : \"44740476-9ee2-5a5c-991f-5b4bdfbfdbe8\",\n  \"TopicArn\" : \"arn:aws:sns:eu-west-1:331393623535:dev-assets-webhooks\",\n  \"Message\" : \"{\\\"payload\\\":\\\"archive this dummy.txt file\\\"}\",\n  \"Timestamp\" : \"2024-08-19T12:48:29.720Z\",\n  \"SignatureVersion\" : \"1\",\n  \"Signature\" : \"L05hKaZYWJL+yBNYHX903uIRQy5Y6REtoshqHDRmP9TMPw9Pf8n89CaKzAOVECmaoeMMV6sOrF0Zq1wJjadHFqBpYTIm9Laokw7BPD8ZvN3iHtwlJJKsml4LBWndl3qMp8FdA0PLJStvdlBfxG0qoWFdMgwmdkcr7s93wMg8JnsQahWqRJZzi0LeY5/YUAIJTUjPl9z74I3w4IvjJW8jsW8i1pBbvqkljpNTRiGP3FGx/2C82ahcPdOAIL+8z5yQRUCqcP0B29dEyHPPXwXmm/Rnv4/l0uKPdbFZ+QuJENKSftD6cLM76U9L4O+zudxr+NNHUdGVFYlGfsdCY5r3OQ==\",\n  \"SigningCertURL\" : \"https://sns.eu-west-1.amazonaws.com/SimpleNotificationService-60eadc530605d63b8e62a523676ef735.pem\",\n  \"UnsubscribeURL\" : \"https://sns.eu-west-1.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:eu-west-1:331393623535:dev-assets-webhooks:38c5e1c2-0034-4e82-9b3b-67fa1c1ce2eb\",\n  \"MessageAttributes\" : {\n    \"webhookName\" : {\"Type\":\"String\",\"Value\":\"archive-sqs-disabled-for-the-moment\"}\n  }\n}",
//               "attributes": {
//                   "ApproximateReceiveCount": "1",
//                   "SentTimestamp": "1724071709749",
//                   "SenderId": "AIDAISMY7JYY5F7RTT6AO",
//                   "ApproximateFirstReceiveTimestamp": "1724071709799"
//               },
//               "messageAttributes": {},
//               "md5OfMessageAttributes": null,
//               "md5OfBody": "e02c59425d3bd1e1d1d4745203927421",
//               "eventSource": "aws:sqs",
//               "eventSourceARN": "arn:aws:sqs:eu-west-1:331393623535:dev-ness-assets-archive-sqs",
//               "awsRegion": "eu-west-1"
//           }
//       ]
//   }
//
// 3. The interesting part is the event.Records[0].body (taken from above but nicely formatted):
//   {
//       "Type": "Notification",
//       "MessageId": "44740476-9ee2-5a5c-991f-5b4bdfbfdbe8",
//       "TopicArn": "arn:aws:sns:eu-west-1:331393623535:dev-assets-webhooks",
//       "Message": "{\"payload\":\"archive this dummy.txt file\"}",
//       "Timestamp": "2024-08-19T12:48:29.720Z",
//       "SignatureVersion": "1",
//       "Signature": "L05hKaZYWJL+yBNYHX903uIRQy5Y6REtoshqHDRmP9TMPw9Pf8n89CaKzAOVECmaoeMMV6sOrF0Zq1wJjadHFqBpYTIm9Laokw7BPD8ZvN3iHtwlJJKsml4LBWndl3qMp8FdA0PLJStvdlBfxG0qoWFdMgwmdkcr7s93wMg8JnsQahWqRJZzi0LeY5/YUAIJTUjPl9z74I3w4IvjJW8jsW8i1pBbvqkljpNTRiGP3FGx/2C82ahcPdOAIL+8z5yQRUCqcP0B29dEyHPPXwXmm/Rnv4/l0uKPdbFZ+QuJENKSftD6cLM76U9L4O+zudxr+NNHUdGVFYlGfsdCY5r3OQ==",
//       "SigningCertURL": "https://sns.eu-west-1.amazonaws.com/SimpleNotificationService-60eadc530605d63b8e62a523676ef735.pem",
//       "UnsubscribeURL": "https://sns.eu-west-1.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:eu-west-1:331393623535:dev-assets-webhooks:38c5e1c2-0034-4e82-9b3b-67fa1c1ce2eb",
//       "MessageAttributes": {
//           "webhookName": {
//               "Type": "String",
//               "Value": "archive-sqs-disabled-for-the-moment"
//           }
//       }
//   }
//
// 4. And finaly the event.Records[].body.Message (again nicely formatted):
//   {
//      "payload": "this is a test"
//   }

export const handler = async (event, context) => {
    console.log("SECRET=" + secret);
    console.log("ENVIRONMENT=" + environment);
    console.log("@{{ cookiecutter.lambda_name }} function called with event=" + JSON.stringify(event));

    // Process events. Here we don't do anything with the event. We just fail randomly to test the batchItemFailure
    if (typeof event.Records !== "undefined") {
        var failedMessageIds = [];
        event.Records.forEach(
            function (item, index) {
                // Note: item.body contains the SNS message and item.body.Message the Message sent to SNS
                try {
                    console.log("Need to proceed with " + JSON.parse(item.body).Message);
                }
                catch (error) {
                    console.log("Error parsing 'item.body.Message': " + error);
                }
                let result = Math.random() > 0.5; // should be something like result=process(item)
                if (result) {
                    console.log("successfully proceed with messageId " + item.messageId);
                } else {
                    console.log("failed on processing messageId " + item.messageId);
                    failedMessageIds.push({ itemIdentifier: item.messageId });
                }
            }
        );
        if (failedMessageIds && failedMessageIds.length === 0) {
            console.log("all records processed correctly, returning nothing");
            return;
        } else {
            let batchItemFailures = JSON.stringify({ "batchItemFailures": failedMessageIds });
            console.log("had issue with: " + batchItemFailures);
            return batchItemFailures;
        }
    } else {
        return;
    }
}

// handler({ "Records": [{ "body": "{ \"Message\": { \"key\": \"value\" } }", "messageId": "my-id", }] })
