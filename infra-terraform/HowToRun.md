# 🚀 Step-by-Step Guide to Automate Terraform Infrastructure Deployment with 2deploy.sh

This guide explains how to use the `2deploy.sh` shell script to create a Terraform-managed infrastructure, upload AWS Lambda function packages to S3, and deploy a frontend project. Follow the steps below to ensure smooth execution.

---

## 🛠️ Prerequisites

Before running the script, ensure the following:

1. **AWS CLI Installed**:
   - Verify with: `aws --version`
   - [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) if not installed.

2. **Terraform Installed**:
   - Verify with: `terraform version`
   - [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) if not installed.

3. **Node.js and npm Installed**:
   - Verify with: `node -v` and `npm -v`
   - [Install Node.js and npm](https://nodejs.org/en/download/) if not installed.

4. **Create the S3 Bucket**:
   - Run the following command to create the bucket:
     ```bash
     aws s3 mb s3://ops-lambda-bucket-tf
     ```
   - Replace `ops-lambda-bucket-tf` with the desired bucket name.

5. **Backend and Frontend Directories**:
   - Ensure the backend contains Python files for Lambda functions in `../backend/functions`.
   - Ensure the frontend is a Node.js project ready for deployment.

---

## 📋 Step-by-Step Execution

### **Step 1: Clone and Navigate to the Repository**
Ensure you are in the root directory of the repository containing the script. If not, navigate to the directory with:
```bash
cd path/to/repository
