import json
import boto3

# Initialize the SNS client
sns = boto3.client('sns', region_name='us-east-1')  # Specify the region if needed

def lambda_handler(event, context):
    try:
        # Log the incoming event
        print(f"Received event: {event}")

        # Get the required fields from the event
        order_id = event.get('orderId')
        email = event.get('email')  # Ensure this field is included in the event
        product_id = event.get('productId')
        quantity = event.get('quantity')

        if not email:
            raise Exception("'email' is required but not found in the event")

        # Construct the message
        message = f"Your order (Order ID: {order_id}) for Product ID: {product_id} with quantity {quantity} has been successfully processed."

        # Log the message
        print(f"Sending notification: {message}")

        # Send the notification using SNS
        response = sns.publish(
            Message=message,
            Subject="Order Confirmation",
            TopicArn='arn:aws:sns:us-east-1:202533534284:orderEmailNotification'
        )

        # Log the SNS response
        print(f"SNS Publish Response: {response}")

        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Notification sent successfully',
                'orderId': order_id,
                'email': email,
                'sns_response': response  # Include response for debugging
            })
        }

    except Exception as e:
        print(f"Error sending notification: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'message': 'Notification failed',
                'error': str(e)
            })
        }