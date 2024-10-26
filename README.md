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

## AWS Step Functions Definition

```json
{
  "StartAt": "ValidateOrder",
  "States": {
    "ValidateOrder": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-1:202533534284:function:validateOrderFunction",
      "Next": "SaveOrderToDatabase",
      "ResultPath": "$.validationOutput"
    },
    "SaveOrderToDatabase": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-1:202533534284:function:saveOrderFunction",
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
      "Resource": "arn:aws:lambda:us-east-1:202533534284:function:processPaymentFunction",
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
      "Resource": "arn:aws:lambda:us-east-1:202533534284:function:updateInventoryFunction",
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
      "Resource": "arn:aws:lambda:us-east-1:202533534284:function:sendNotificationFunction",
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
      "Resource": "arn:aws:lambda:us-east-1:202533534284:function:generateReceiptFunction",
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
## Frontend Web Application
![Frontend Web Application](https://github.com/user-attachments/assets/b732ef30-45f6-4fc7-89b9-50ad76cac59e)

## Step Functions
![Step Functions](https://github.com/user-attachments/assets/ec394ad8-6e18-4c89-a65c-e5a2b3599383)

## Step Functions-Success
![Step Functions-Success](https://github.com/user-attachments/assets/df9a297e-7f87-4f6a-82d1-8e3aeafcd8c2)

## Step Workflows
![Step Workflows](https://github.com/user-attachments/assets/ed27a678-092f-4562-a79f-b585ad89c5b8)

![Step Workflow Details](https://github.com/user-attachments/assets/f1e7be7b-abc1-4d31-824f-73696975962a)

Order Created : Order NO: 3625
![image](https://github.com/user-attachments/assets/eaf5fa34-fc67-4acd-9ce9-bbc1861c1fa2)

Receipt Generated
![image](https://github.com/user-attachments/assets/643ceba0-b0aa-4279-966f-25d664c0641d)

Step Succssed
![image](https://github.com/user-attachments/assets/2c8cbffb-3a15-4ba5-ad19-ffe99d185429)


## Lambda Functions

OrderPlacementFunction

![image](https://github.com/user-attachments/assets/546ca862-8f5c-4569-9752-c642f8862ed9)

## DynamoDB Tables

![image](https://github.com/user-attachments/assets/d9775b9f-74c1-4dab-b096-0cc16c54612b)

Inventory Table
![image](https://github.com/user-attachments/assets/085bec63-af5e-484b-a470-0e4b7c19d68c)

Order Table
![image](https://github.com/user-attachments/assets/220d1d23-d51c-4d11-9dbc-30e1504019b5)

Order No: 3625 
![image](https://github.com/user-attachments/assets/082e19c2-17a2-4753-87f1-835db68e0866)


## Order Receipt Generated and stored to S3 Table
![image](https://github.com/user-attachments/assets/ae8d98aa-f303-44ac-bb02-2d8ee2360e47)

Order No: 3625 Receipt
![image](https://github.com/user-attachments/assets/cf89d2da-f2a7-403f-9371-05c70d220f2a)

![image](https://github.com/user-attachments/assets/3605cf10-6f72-463e-be41-44314c996c6c)

## CloudWatch Logs

Log Groups
![image](https://github.com/user-attachments/assets/60814ad5-1d4f-48d6-a820-ebeb2d0a383e)

![image](https://github.com/user-attachments/assets/f8d795da-a270-4e33-a969-f14e6a30f0f9)

![image](https://github.com/user-attachments/assets/b0313226-4963-4032-914b-6fd9ac215863)

![image](https://github.com/user-attachments/assets/7c471ab9-9815-472f-915d-cea64705f893)



## JSON Output

```json
{
  "output": {
    "productId": "P001",
    "quantity": 1,
    "customerEmail": "cust@gmail.com",
    "validationOutput": {
      "status": "VALID",
      "OrderId": "3625",
      "productId": "P001",
      "quantity": 1,
      "customerEmail": "cust@gmail.com",
      "amount": 100,
      "paymentMethod": "creditCard"
    },
    "saveOrderOutput": {
      "statusCode": 200,
      "message": "Order successfully saved",
      "OrderId": "3625",
      "amount": 100,
      "customerEmail": "cust@gmail.com",
      "productId": "P001",
      "quantity": 1,
      "paymentMethod": "creditCard"
    },
    "processPaymentOutput": {
      "statusCode": 500,
      "message": "Failed to save order to database",
      "error": "'productId' and 'quantity' are required fields"
    },
    "updateInventoryOutput": {
      "statusCode": 200,
      "body": "{\"message\": \"Inventory updated successfully\", \"OrderId\": \"3625\", \"productId\": \"P001\", \"quantity\": 1}"
    },
    "sendNotificationOutput": {
      "statusCode": 200,
      "body": "{\"message\": \"Notification sent successfully\", \"orderId\": null, \"email\": \"cust@gmail.com\"}"
    },
    "generateReceiptOutput": {
      "statusCode": 200,
      "body": "{\"message\": \"Receipt generated and saved successfully\", \"receiptUrl\": \"s3://order-receipt-2024/receipts/3625.json\"}"
    }
  },
  "outputDetails": {
    "truncated": false
  }
}

## Description of Output

- **productId**: Product identifier for the order.
- **quantity**: Number of items ordered.
- **customerEmail**: Email of the customer placing the order.

### Detailed Outputs

- **validationOutput**:
  - Status of the order validation, including order ID, product details, amount, and payment method.

- **saveOrderOutput**:
  - Status of the order-saving process, indicating success with a 200 status code.

- **processPaymentOutput**:
  - Status of the payment processing; includes a 500 error due to missing fields.

- **updateInventoryOutput**:
  - Confirms successful inventory update with status code 200.

- **sendNotificationOutput**:
  - Indicates successful notification sending with status code 200.

- **generateReceiptOutput**:
  - Confirms that the receipt was generated and saved to S3, with a link to the receipt.


## DevOps Implementation

# GitHub Actions
TO automate the frontend web app deployment to aws S3 for static web content

![image](https://github.com/user-attachments/assets/066a1432-8b7b-4292-94e4-560a04c94f33)

![image](https://github.com/user-attachments/assets/dcdc6d58-5d16-46f2-9f16-b851b8b1b290)

![image](https://github.com/user-attachments/assets/5e05a00f-a665-41f8-a12b-109deec7ba17)

![image](https://github.com/user-attachments/assets/35b64cfd-e987-401f-9fd7-b9efefdb4c93)


## frontend-ci.yml
## Frontend CI Pipeline

This GitHub Actions workflow automates the build and deployment process for the frontend of the order processing system. It runs on every push to the `master` branch, deploying the built artifacts to an S3 bucket.

### Workflow Configuration

```yaml
name: Frontend CI Pipeline

on:
  push:
    branches:
      - master

jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      id-token: write  # Required to generate OIDC token
      contents: read   # Required to read repo contents
    steps:

      # Step 1: Checkout the repository
      - name: Checkout Code
        uses: actions/checkout@v3

      # Step 2: Configure AWS Credentials
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::202533534284:role/awsGitHubActionsRole1
          aws-region: us-east-1

      # Step 3: Set up Node.js environment
      - name: Install Node.js
        uses: actions/setup-node@v2
        with:
          node-version: '14'

      # Step 4: Install dependencies
      - name: Install dependencies
        run: npm install
        working-directory: ./frontend

      # Step 5: Build the frontend
      - name: Build frontend
        run: npm run build
        working-directory: ./frontend

      # Step 6: Upload build artifacts
      - name: Upload Build Artifacts
        uses: actions/upload-artifact@v3
        with:
          name: build
          path: frontend/build/

      # Step 7: Deploy to S3
      - name: Deploy to S3
        run: aws s3 sync ./frontend/build s3://ordeprocess-frontend/ --delete


## Steps Breakdown
# Checkout Code: Uses the actions/checkout@v3 action to pull the repository code.
# Configure AWS Credentials: Uses aws-actions/configure-aws-credentials@v4 to set up AWS credentials for deployment.
# Install Node.js: Sets up Node.js v14 for building the frontend.
# Install Dependencies: Installs the frontend dependencies using npm install.
# Build Frontend: Builds the React application using npm run build.
# Upload Build Artifacts: Uses actions/upload-artifact@v3 to upload the build artifacts for further use.
# Deploy to S3: Deploys the built frontend to the specified S3 bucket.



