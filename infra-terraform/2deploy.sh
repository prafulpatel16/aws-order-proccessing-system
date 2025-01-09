#!/bin/bash
# Define directories
LAMBDA_FUNCTIONS_DIR="../backend/functions"
ZIP_OUTPUT_DIR="../backend/zips"
S3_BUCKET="order-processing-lambda-buckettf"


# Create the output directory if it doesn't exist
mkdir -p "${ZIP_OUTPUT_DIR}"

# Loop through each Python file in the functions directory
for function_file in ${LAMBDA_FUNCTIONS_DIR}/*.py; do
  # Get the base name of the file (e.g., orderPlacement.py -> orderPlacement)
  function_name=$(basename "${function_file}" .py)

  # Create a zip file for the Lambda function
  zip -j "${ZIP_OUTPUT_DIR}/${function_name}.zip" "${function_file}"

  # Upload the zip file to S3
  aws s3 cp "${ZIP_OUTPUT_DIR}/${function_name}.zip" "s3://${S3_BUCKET}/"
  echo "Uploaded ${ZIP_OUTPUT_DIR}/${function_name}.zip to S3 bucket ${S3_BUCKET}"
done

# Navigate to frontend folder and build the project
cd ../frontend || exit
npm install
npm run build

# Navigate back to infra folder for Terraform deployment
cd ../infra-terraform || exit

# Create a Terraform variables file to store the S3 bucket name
# cat <<EOL > terraform.tfvars
# s3_bucket = "${S3_BUCKET}"
# EOL

# Initialize and apply Terraform
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars" -auto-approve
