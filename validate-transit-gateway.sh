#!/bin/bash
#!/bin/bash

# Navigate to the transit-gateway directory
cd modules/test1/transit-gateway

# Initialize Terraform
terraform init

# Validate the entire directory
echo "Validating the transit-gateway configuration..."
terraform validate
if [ $? -ne 0 ]; then
  echo "Validation failed."
  exit 1
fi

echo "All files validated successfully."