#!/bin/bash

# Navigate to the transit-gateway directory
cd modules/test1/transit-gateway

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