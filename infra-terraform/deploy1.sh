
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
