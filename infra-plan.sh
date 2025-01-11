#!/bin/bash

echo "******************************************************"
echo "Deploying s3 backeng module"
echo "******************************************************"
cd resources/DEV/s3-replication
terraform init
terraform fmt
terraform plan
cd -

echo "******************************************************"
echo "Deploying vpc module"
echo "******************************************************"
cd resources/DEV/vpc
terraform init
terraform fmt
terraform plan
cd -

echo "******************************************************"
echo "Deploying the bastion host module"
echo "******************************************************"
cd resources/DEV/ec2
terraform init
terraform fmt
terraform plan
cd -

echo "******************************************************"
echo "Deleting the eks1 module"
echo "******************************************************"
cd resources/DEV/eks1
terraform init
terraform fmt
terraform plan 
cd -