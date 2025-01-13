import boto3
import json
import os


# Environment Variables
SNS_TOPIC_ARN = os.getenv('SNS_TOPIC_ARN')
BUDGET_NAME = os.getenv('BUDGET_NAME')
ACCOUNT_ID = os.getenv('ACCOUNT_ID')

def lambda_handler(event, context):
    client = boto3.client('budgets')

    # Retrieve budget details
    try:
        response = client.describe_budget(
            Account_id=ACCOUNT_ID,
            BudgetName=BUDGET_NAME
        )

        budget = response['Budget']
        actual_spend = budget['CalculatedSpend']['ActualSpend']
        forecasted_spend = budget['CalculatedSpend']['ForecastedSpend']

        message = f"""
        Budget Alert:
        Actual Spend: {actual_spend['Amount']} {actual_spend['Unit']}
        Forecasted Spend: {forecasted_spend['Amount']} {forecasted_spend['Unit']}
        Budget Limit: {budget['BudgetLimit']['Amount']} {budget['BudgetLimit']['Unit']}
        """
        print(message)

        if float(actual_spend['Amount']) > float(budget['BudgetLimit']['Amount']):
            sns_client = boto3.client('sns')
            sns_client.publish(
                TopicArn=SNS_TOPIC_ARN,
                Message=message,
                Subject="AWS Budget Exceeded!"
            )
            print("Notification sent.")

    except Exception as e:
        print(f"Error retrieving budget: {e}")
        raise
        
        