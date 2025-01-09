#!/bin/bash

# Check if 'zip' is installed
if ! command -v zip &> /dev/null; then
  echo "Error: 'zip' command not found. Please install 'zip' and rerun the script."
  exit 1
fi

# Define the directory containing Lambda functions
LAMBDA_FUNCTIONS_DIR="../backend/functions"

# Define the output directory for the zip files
ZIP_OUTPUT_DIR="../backend/zips"

# Create the output directory if it doesn't exist
mkdir -p "${ZIP_OUTPUT_DIR}"

# Loop through each Python file in the functions directory
for function_file in ${LAMBDA_FUNCTIONS_DIR}/*.py; do
  # Get the base name of the file (e.g., orderPlacement.py -> orderPlacement)
  function_name=$(basename "${function_file}" .py)

  # Create a zip file for the Lambda function
  zip -j "${ZIP_OUTPUT_DIR}/${function_name}.zip" "${function_file}" || {
    echo "Failed to create ZIP for ${function_name}. Exiting."
    exit 1
  }

  echo "Created ${ZIP_OUTPUT_DIR}/${function_name}.zip"
done

# Navigate to frontend folder and build the project
cd ../frontend || exit
npm install
npm run build

# Navigate back to infra folder for Terraform deployment
cd ../infra-terraform || exit

# Initialize and apply Terraform
terraform init
terraform plan -out=tfplan
terraform apply tfplan
