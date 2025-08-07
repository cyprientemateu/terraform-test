#!/bin/bash

# Navigate to the webforx-team directory
cd modules/test1/webforx-team
# Check if the lambda directory exists
if [ ! -d "lambda" ]; then
  echo "Lambda directory does not exist. Please check the path."
  exit 1
fi
# Navigate to the lambda directory
cd lambda
# Check if the cleanup.py file exists
if [ ! -f "cleanup.py" ]; then
  echo "cleanup.py file does not exist. Please check the path."
  exit 1
fi

# Check if lambda_function_payload.zip exists
if [ -f "../lambda_function_payload.zip" ]; then
    echo "Removing existing lambda_function_payload.zip..."
    rm ../lambda_function_payload.zip
fi
# Create a zip file of the lambda function
zip ../lambda_function_payload.zip cleanup.py
# Check if the zip command was successful
if [ $? -ne 0 ]; then
  echo "Failed to create the zip file."
  exit 1
fi
echo "Lambda function payload zip created successfully."
# Navigate back to the parent directory
cd ..

# Navigate to the webforx-team directory
cd /modules/test1/webforx-team

# Initialize Terraform
terraform init

# Run Terraform plan
echo "Running terraform plan..."
terraform plan -out=tfplan

# Check if the plan was successful
if [ $? -ne 0 ]; then
  echo "Terraform plan failed."
  exit 1
fi

# Ask for manual approval
read -p "Do you want to apply these changes? (yes/no): " approval

if [ "$approval" == "yes" ]; then
  # Apply the Terraform plan
  terraform apply tfplan
  if [ $? -ne 0 ]; then
    echo "Terraform apply failed."
    exit 1
  fi
  echo "Terraform apply succeeded."
else
  echo "Terraform apply canceled."
fi