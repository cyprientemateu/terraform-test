#!/bin/bash

# Check if lambda_function.zip exists
if [ -f "lambda_function.zip" ]; then
    echo "Removing existing lambda_function.zip..."
    rm lambda_function.zip
fi

# Create a directory for dependencies
echo "Creating package directory..."
mkdir -p package

# Install the dependencies in the package directory
echo "Installing dependencies into package directory..."
pip install --target ./package -r requirements.txt

# Zip the package directory and the lambda_function.py file
echo "Zipping lambda_function.py and dependencies into lambda_function.zip..."
cd package
zip -r ../lambda_function.zip .
cd ..
zip -g lambda_function.zip lambda_function.py

# Initialize Terraform
echo "Initializing Terraform..."
terraform init

# Format Terraform files
echo "Formatting Terraform files..."
terraform fmt

# Plan Terraform deployment
echo "Planning Terraform deployment..."
terraform plan -out=tfplan

# Prompt user for approval to apply Terraform changes
echo "Do you want to apply this plan? Type 'yes' or 'y' to approve and apply, 'no' or 'n' to cancel:"
read approval

# Convert input to lowercase
approval=$(echo "$approval" | tr '[:upper:]' '[:lower:]')

if [[ "$approval" == "yes" || "$approval" == "y" ]]; then
    echo "Applying Terraform plan..."
    terraform apply "tfplan"
else
    echo "Terraform apply canceled."
fi
