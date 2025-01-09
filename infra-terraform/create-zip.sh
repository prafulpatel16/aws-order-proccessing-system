#!/bin/bash

# Define directories
LAMBDA_FUNCTIONS_DIR="../backend/functions"
ZIP_OUTPUT_DIR="../backend/zips"

# Create the output directory if it doesn't exist
mkdir -p "${ZIP_OUTPUT_DIR}"

# Loop through each Python file in the functions directory
for function_file in ${LAMBDA_FUNCTIONS_DIR}/*.py; do
  # Get the base name of the file (e.g., orderPlacement.py -> orderPlacement)
  function_name=$(basename "${function_file}" .py)

  # Create a zip file for the Lambda function
  zip -j "${ZIP_OUTPUT_DIR}/${function_name}.zip" "${function_file}"

  echo "Created ${ZIP_OUTPUT_DIR}/${function_name}.zip"
done