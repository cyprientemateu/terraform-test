#!/bin/bash

# Check if start_stop_ec2.zip exists
if [ -f "start_stop_ec2.zip" ]; then
    echo "Removing existing start_stop_ec2.zip..."
    rm start_stop_ec2.zip
fi

# Zip the lambda_function.py file
echo "Zipping lambda_function.py into start_stop_ec2.zip..."
zip start_stop_ec2.zip lambda_function.py

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