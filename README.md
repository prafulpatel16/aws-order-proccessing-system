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


# Real-Time Order Processing System

## Architecture Overview

The real-time order processing system is designed with a serverless architecture using AWS services to ensure scalability, availability, and high performance. The following components are used:

### User Interface (UI)
- **Frontend:** Built with React, hosted on AWS S3, and delivered via AWS CloudFront for global reach and caching.
- **Purpose:** Provides a seamless user experience for order placement and status updates.

### Backend
- **API Gateway:** Serves as the entry point for all API requests from the frontend.
- **AWS Lambda:** Used for serverless processing of various backend operations, including order validation, payment processing, and inventory management.
- **Step Functions:** Orchestrates the entire order processing workflow, ensuring tasks are executed in the correct sequence.
- **DynamoDB:** Serves as the database for storing order details, inventory data, and transaction logs.

### Additional Services
- **SNS (Simple Notification Service):** Sends order confirmation notifications to users via email.
- **S3 (Simple Storage Service):** Stores order receipts and other related files.
- **CloudWatch:** Provides monitoring and logging for tracking workflow execution, errors, and performance metrics.

## Key Requirements

### Real-time Order Submission
- **Users can place orders** via the e-commerce frontend, which sends requests to the backend through API Gateway.
- **Order requests** are sent to AWS Lambda functions for further processing.

### Order Validation
- **Validate incoming orders** by checking product availability in DynamoDB.
- **Payment verification** is conducted to ensure successful transactions before proceeding.

### Inventory Management
- **Once an order is placed,** inventory is deducted from the database using Lambda functions to maintain accuracy.
- **Step Functions** manage the workflow to ensure inventory updates occur only after successful payment.

### Payment Processing
- **Integrates with third-party payment gateways** to process user payments.
- **Lambda functions** handle payment verification and capture the transaction result.

### Notification
- **Users receive order confirmation** via email notifications using Amazon SNS after successful order processing.

### Store Order Receipts
- **Receipts are generated** for each order and stored in S3 for secure storage.
- **Receipts can be accessed later** for order tracking and record-keeping.

### Monitoring
- **CloudWatch** is used to monitor various components of the system.
  - **Flow Monitoring:** Tracks the progress of order processing through Step Functions.
  - **Error Handling:** Logs any errors that occur during Lambda function execution.
  - **Execution Times:** Monitors execution times for Lambda functions to identify performance bottlenecks.

## Conclusion
The architecture ensures a seamless, scalable, and reliable order processing system with real-time data handling, secure transactions, and effective user notifications. The integration of AWS services enables cost-effective scaling, while monitoring tools ensure robust error handling and performance tracking.


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









