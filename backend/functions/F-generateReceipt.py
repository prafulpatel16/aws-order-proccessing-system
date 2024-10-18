import json
import os
import boto3
from datetime import datetime

# Initialize the S3 client
s3 = boto3.client('s3')

def lambda_handler(event, context):
    try:
        # Log the entire event to inspect the input
        print(f"Received event: {event}")

        # Ensure orderId, email, productId, and quantity are present
        order_id = event.get('orderId') or event.get('OrderId')
        email = event.get('email')
        product_id = event.get('productId')
        quantity = event.get('quantity')

        if not order_id:
            raise Exception("'orderId' or 'OrderId' is required but not found in the event")
        if not email:
            raise Exception("'email' is required but not found in the event")
        if not product_id:
            raise Exception("'productId' is required but not found in the event")
        if not quantity:
            raise Exception("'quantity' is required but not found in the event")

        # Get the current timestamp using datetime
        current_time = datetime.utcnow().isoformat()

        # Define the receipt content
        receipt = {
            'orderId': order_id,
            'email': email,
            'productId': product_id,
            'quantity': quantity,
            'date': current_time  # Use current timestamp instead of context.timestamp
        }

        # Log receipt data to debug
        print(f"Generated receipt: {receipt}")

        # Get the S3 bucket name from environment variables and ensure it has no extra spaces
        bucket_name = os.environ['S3_BUCKET_NAME'].strip()

        if not bucket_name:
            raise Exception("'S3_BUCKET_NAME' environment variable is missing")

        # Generate the S3 object key (file path)
        object_key = f"receipts/{order_id}.json"

        # Log the S3 upload parameters to debug
        print(f"Uploading receipt to S3: bucket={bucket_name}, key={object_key}")

        # Upload the receipt to S3 as a JSON file
        s3.put_object(
            Bucket=bucket_name,
            Key=object_key,
            Body=json.dumps(receipt),
            ContentType='application/json'
        )

        # Log successful upload response
        print(f"Receipt successfully uploaded to S3: s3://{bucket_name}/{object_key}")

        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Receipt generated and saved successfully',
                'receiptUrl': f"s3://{bucket_name}/{object_key}"
            })
        }

    except Exception as e:
        # Log the error in detail
        print(f"Error: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'message': 'Receipt generation failed',
                'error': str(e)
            })
        }
