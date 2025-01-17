import json
import os
import boto3
import random  # Assuming random for generating OrderId

# Initialize the DynamoDB client
dynamodb = boto3.client('dynamodb')

def lambda_handler(event, context):
    try:
        # Log the entire event to inspect the input
        print(f"Received event: {event}")

        # Get productId, quantity, and customerEmail from the event
        product_id = event.get('productId')
        quantity = event.get('quantity')
        customer_email = event.get('customerEmail')

        if not product_id or not quantity:
            raise Exception("Invalid input: productId and quantity are required")
        if not customer_email:
            raise Exception("Invalid input: customerEmail is required")

        # Generate a unique 4-digit OrderId
        order_id = str(random.randint(1000, 9999))  # Generate a random 4-digit number as OrderId

        # Define the parameters for fetching the product information from DynamoDB
        table_name = os.environ['INVENTORY_TABLE'].strip()
        params = {
            'TableName': table_name,
            'Key': {
                'productId': {'S': product_id}
            }
        }

        # Get the item from DynamoDB
        result = dynamodb.get_item(**params)

        # Debugging log for DynamoDB response
        print(f"DynamoDB get_item result: {result}")

        # Check if the item exists
        if 'Item' not in result:
            raise Exception(f"Product with productId {product_id} not found")

        # Check if 'stock' exists in the item and is valid
        if 'stock' not in result['Item']:
            raise Exception(f"Stock information missing for productId {product_id}")
        
        # Convert stock to integer for comparison
        stock = int(result['Item']['stock']['N'])

        print(f"Stock for productId {product_id}: {stock}, Requested quantity: {quantity}")

        # Ensure that quantity is an integer
        if not isinstance(quantity, int):
            quantity = int(quantity)

        # Calculate the amount (for example, let's assume price is fixed for now)
        amount = quantity * 100  # Example: each item costs $100
        
        # Generate a unique OrderId
        order_id = str(random.randint(1000, 9999))

        # Payment method should come from input or have a default value
        payment_method = event.get('paymentMethod', 'creditCard')  # Default to 'creditC

        # Check if stock is enough
        if stock >= quantity:
            return {
                'status': 'VALID',
                'OrderId': order_id,  # Include the generated 4-digit OrderId
                'productId': product_id,
                'quantity': quantity,
                'customerEmail': customer_email,
                'amount': amount,  # Include the calculated amount
                'paymentMethod': payment_method
            }
        else:
            raise Exception('Out of stock')

    except Exception as e:
        print(f"Error validating order: {e}")
        raise Exception('Order validation failed')
