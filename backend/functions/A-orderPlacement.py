import json  # Make sure to import the json module
import os
import boto3

# Initialize the Step Functions client
stepfunctions = boto3.client('stepfunctions')

def lambda_handler(event, context):
    try:
        # Parse the incoming order data
        order = json.loads(event['body'])

        # Define parameters for starting the Step Functions execution
        params = {
            'stateMachineArn': os.environ['STATE_MACHINE_ARN'],  # Step Function ARN from environment variables
            'input': json.dumps(order)  # Convert order details to JSON format
        }

        # Start the Step Functions execution
        response = stepfunctions.start_execution(**params)

        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',  # Allow all origins or specify your frontend origin
                'Access-Control-Allow-Methods': 'POST,OPTIONS',  # Allowed methods
                'Access-Control-Allow-Headers': 'Content-Type'
            },
            'body': json.dumps({
                'message': 'Order processing started',
                'executionArn': response['executionArn']
            })
        }
    except Exception as e:
        print(f"Error starting Step Function execution: {e}")
        return {
            'statusCode': 500,
            'headers': {
                'Access-Control-Allow-Origin': '*',  # Ensure headers are present on error response as well
            },
            'body': json.dumps({
                'message': 'Failed to start order processing',
                'error': str(e)
            })
        }
