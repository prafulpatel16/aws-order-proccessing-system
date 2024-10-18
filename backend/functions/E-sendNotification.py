import json
import os
import boto3

# Initialize the SNS client
sns = boto3.client('sns')

def lambda_handler(event, context):
    try:
        # Log the entire event to inspect the input
        print(f"Received event: {event}")

        # Ensure orderId and email are present
        order_id = event.get('OrderId')
        email = event.get('email')

        if not order_id:
            raise Exception("'OrderId' is required but not found in the event")
        if not email:
            raise Exception("'email' is required but not found in the event")

        # Define the message body for the notification
        message_body = {
            'OrderId': order_id,
            'email': email,
            'message': 'Your order has been successfully processed!'
        }

        # Get the SNS topic ARN from environment variables and ensure it has no extra spaces
        topic_arn = os.environ['SNS_TOPIC_ARN'].strip()

        # Log the parameters for the SNS publish operation
        print(f"Publishing message to SNS topic {topic_arn} with body: {message_body}")

        # Publish the message to the SNS topic
        response = sns.publish(
            TopicArn=topic_arn,
            Message=json.dumps(message_body),
            Subject='Order Processed Notification'
        )

        # Log the successful response from SNS
        print(f"SNS publish response: {response}")

        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Notification sent successfully',
                'OrderId': order_id,
                'email': email
            })
        }

    except Exception as e:
        # Log the error and raise an exception with a clear message
        print(f"Error: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'message': 'Notification failed',
                'error': str(e)
            })
        }
