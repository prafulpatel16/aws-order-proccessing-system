import json
import os
import boto3

# Initialize the DynamoDB client
dynamodb = boto3.client('dynamodb')

def lambda_handler(event, context):
    try:
        # Log the entire event to inspect the input
        print(f"Received event: {event}")

        # Ensure that customerEmail is present in the event
        customer_email = event.get('customerEmail')
        if not customer_email:
            raise Exception("'customerEmail' is required but not found in the event")

        # Ensure orderId is present and not None
        order_id = event.get('OrderId')  # Adjust key as necessary based on schema
        if not order_id:
            raise Exception("'OrderId' is required but not found in the event or is None")

        # Ensure productId, quantity, amount, and paymentMethod are present
        product_id = event.get('productId')
        quantity = event.get('quantity')
        amount = event.get('amount')
        payment_method = event.get('paymentMethod')  # Get paymentMethod from event

        if not product_id or not quantity:
            raise Exception("'productId' and 'quantity' are required fields")

        # Ensure amount is not None and is valid
        if amount is None:
            raise Exception("'amount' is required but not found or is None")
        if not isinstance(amount, (int, float)):
            raise Exception("'amount' must be a numeric value")

        # Ensure paymentMethod is present
        if not payment_method:
            raise Exception("'paymentMethod' is required but not found in the event")

        # Get table name and strip any extra spaces
        table_name = os.environ['ORDERS_TABLE'].strip()

        # Save the order to DynamoDB with correct key casing
        params = {
            'TableName': table_name,
            'Item': {
                'OrderId': {'S': order_id},
                'customerEmail': {'S': customer_email},
                'productId': {'S': product_id},
                'quantity': {'N': str(quantity)},
                'amount': {'N': str(amount)},
                'paymentMethod': {'S': payment_method}  # Ensure paymentMethod is saved
            }
        }
        dynamodb.put_item(**params)

        return {
            'statusCode': 200,
            'message': 'Order successfully saved',
            'OrderId': order_id,
            'amount': amount,
            'customerEmail': customer_email,
            'productId': product_id,
            'quantity': quantity,
            'paymentMethod': payment_method  # Include paymentMethod in response
        }

    except Exception as e:
        print(f"Error: {e}")
        return {
            'statusCode': 500,
            'message': 'Failed to save order to database',
            'error': str(e)
        }
