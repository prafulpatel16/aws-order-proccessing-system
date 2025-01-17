import json
import os
import boto3

# Initialize the DynamoDB client
dynamodb = boto3.client('dynamodb')

def lambda_handler(event, context):
    try:
        # Log the entire event to inspect the input
        print(f"Received event: {event}")

        # Ensure productId, quantity, and orderId are present
        product_id = event.get('productId')
        quantity = event.get('quantity')
        order_id = event.get('OrderId')

        if not product_id:
            raise Exception("'productId' is required but not found in the event")
        if not quantity:
            raise Exception("'quantity' is required but not found in the event")
        if not order_id:
            raise Exception("'OrderId' is required but not found in the event")

        # Get the table name from environment variables and ensure it has no extra spaces
        table_name = os.environ['INVENTORY_TABLE'].strip()

        # Log the parameters for the DynamoDB update
        print(f"Updating inventory for productId: {product_id}, quantity: {quantity}, OrderId: {order_id}")

        # Define parameters for updating the inventory in DynamoDB
        params = {
            'TableName': table_name,
            'Key': {
                'productId': {'S': product_id}
            },
            'UpdateExpression': 'SET stock = stock - :q',
            'ExpressionAttributeValues': {
                ':q': {'N': str(quantity)}
            }
        }

        # Perform the DynamoDB update
        response = dynamodb.update_item(**params)

        # Log the successful response from DynamoDB
        print(f"DynamoDB update_item response: {response}")

        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Inventory updated successfully',
                'OrderId': order_id,
                'productId': product_id,
                'quantity': quantity
            })
        }

    except Exception as e:
        # Log the error and raise an exception with a clear message
        print(f"Error: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'message': 'Inventory update failed',
                'error': str(e)
            })
        }
