## 👉Follow Complete Documentation: 📄 [AWS Serverless Order Processing System](https://praful.cloud/aws-serverless-order-processing-system)

## Architecture Diagram:

![Untitled-2024-10-21-2003](https://github.com/user-attachments/assets/6324468f-4c46-421e-801b-64a880d1fec8)


# Real-Time Order Processing System

## Table of Contents
- [Project Use Case](#project-use-case)
- [Architecture Overview](#architecture-overview)
- [Key Requirements](#key-requirements)
- [Tech Stack](#tech-stack)
- [Step-by-Step Implementation](#step-by-step-implementation)
  - [1. Frontend (React + API Gateway)](#frontend-react--api-gateway)
  - [2. API Gateway Setup](#api-gateway-setup)
  - [3. AWS Step Functions](#aws-step-functions)
  - [4. Order Validation Lambda](#order-validation-lambda)
  - [5. Payment Processing Lambda](#payment-processing-lambda)
  - [6. Update Inventory Lambda](#update-inventory-lambda)
  - [7. Send Notification (SNS)](#send-notification-sns)
  - [8. Generate and Store Receipt (S3)](#generate-and-store-receipt-s3)
  - [9. Monitoring and Error Handling](#monitoring-and-error-handling)
- [AWS Step Functions Workflow Example](#aws-step-functions-workflow-example)
- [Benefits of this Approach](#benefits-of-this-approach)
- [Project Structure](#project-structure)
- [Project Implementation](#project-implementation)
  - [DynamoDB Setup](#dynamodb-setup)
  - [Lambda Function Deployment](#lambda-function)
  - [S3 Frontend Deployment](#s3---static-webapp)
- [Challenges & Troubleshooting](#challenges--troubleshooting)
- [WebApp Test](#webapp-test)
- [DevOps](#devops)
  - [Source Code Management (Version Control)](#phase-1-source-code-management-version-control)
  - [Continuous Integration (CI)](#phase-2-continuous-integration-ci)
  - [Configure Secrets](#configure-secrets)
- [Conclusion](#conclusion)

## Project Use Case
This project demonstrates a real-time order processing system built using serverless architecture on AWS. It manages order placement, validation, payment, inventory updates, notifications, and receipt generation.

## Architecture Overview
The system is designed using AWS services such as API Gateway, Lambda, Step Functions, DynamoDB, SNS, and S3. The architecture ensures scalability, availability, and real-time order processing.

## Key Requirements
- Real-time order processing with low latency.
- Secure and reliable API integration.
- Seamless interaction between microservices.
- Scalable and cost-effective solution.

## Tech Stack
- **Frontend:** React
- **Backend:** AWS Lambda, API Gateway, Step Functions
- **Database:** DynamoDB
- **Storage:** S3 for static assets and receipts
- **Messaging:** SNS for notifications
- **Infrastructure as Code:** AWS CloudFormation, Terraform

## Step-by-Step Implementation

### 1. Frontend (React + API Gateway)
- Set up the React frontend to interact with the backend via API Gateway.
- Deploy the frontend to S3 with CloudFront for content delivery and caching.

### 2. API Gateway Setup
- Create REST API endpoints to trigger the Lambda functions.

### 3. AWS Step Functions
- Design a Step Functions workflow to orchestrate the order processing tasks.

### 4. Order Validation Lambda
- Implement a Lambda function to validate order data received from the frontend.

### 5. Payment Processing Lambda
- Create a Lambda function to handle payment processing and integration with a mock payment service.

### 6. Update Inventory Lambda
- Add a Lambda function to update inventory in the DynamoDB table after order placement.

### 7. Send Notification (SNS)
- Use SNS to send order confirmation notifications to customers.

### 8. Generate and Store Receipt (S3)
- Generate an order receipt and store it in S3 for later retrieval.

### 9. Monitoring and Error Handling
- Implement CloudWatch for monitoring Lambda functions, API Gateway, and Step Functions.

## AWS Step Functions Workflow Example
```json
{
  "StartAt": "ValidateOrder",
  "States": {
    "ValidateOrder": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-1:20534284:function:validateOrderFunction",
      "Next": "SaveOrderToDatabase",
      "ResultPath": "$.validationOutput"
    },
    "SaveOrderToDatabase": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-1:202534284:function:saveOrderFunction",
      "Parameters": {
        "OrderId.$": "$.validationOutput.OrderId",
        "customerEmail.$": "$.validationOutput.customerEmail",
        "productId.$": "$.validationOutput.productId",
        "quantity.$": "$.validationOutput.quantity",
        "amount.$": "$.validationOutput.amount",
        "paymentMethod.$": "$.validationOutput.paymentMethod"
      },
      "Next": "ProcessPayment",
      "ResultPath": "$.saveOrderOutput"
    },
    "ProcessPayment": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-1:225334284:function:processPaymentFunction",
      "Parameters": {
        "amount.$": "$.saveOrderOutput.amount",
        "paymentMethod.$": "$.saveOrderOutput.paymentMethod",
        "OrderId.$": "$.saveOrderOutput.OrderId",
        "customerEmail.$": "$.saveOrderOutput.customerEmail"
      },
      "Next": "UpdateInventory",
      "ResultPath": "$.processPaymentOutput"
    },
    "UpdateInventory": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-1:203534284:function:updateInventoryFunction",
      "Parameters": {
        "OrderId.$": "$.saveOrderOutput.OrderId",
        "productId.$": "$.saveOrderOutput.productId",
        "quantity.$": "$.saveOrderOutput.quantity"
      },
      "Next": "SendNotification",
      "ResultPath": "$.updateInventoryOutput"
    },
    "SendNotification": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-1:20253284:function:sendNotificationFunction",
      "Parameters": {
        "email.$": "$.customerEmail",
        "productId.$": "$.productId",
        "quantity.$": "$.quantity"
      },
      "Next": "GenerateReceipt",
      "ResultPath": "$.sendNotificationOutput"
    },
    "GenerateReceipt": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-1:20253384:function:generateReceiptFunction",
      "Parameters": {
        "OrderId.$": "$.saveOrderOutput.OrderId",
        "email.$": "$.saveOrderOutput.customerEmail",
        "productId.$": "$.saveOrderOutput.productId",
        "quantity.$": "$.saveOrderOutput.quantity"
      },
      "End": true,
      "ResultPath": "$.generateReceiptOutput"
    }
  }
}









