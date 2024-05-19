#!/bin/bash

echo "******************************************************"
echo "Deploying s3 backeng module"
echo "******************************************************"
cd resources/s3-replication
terraform init
terraform fmt
terraform plan
cd -

echo "******************************************************"
echo "Deploying vpc module"
echo "******************************************************"
cd resources/vpc
terraform init
terraform fmt
terraform plan
cd -

echo "******************************************************"
echo "Deploying the bastion host module"
echo "******************************************************"
cd resources/ec2
terraform init
terraform fmt
terraform plan
cd -

echo "******************************************************"
echo "Deleting the eks1 module"
echo "******************************************************"
cd resources/eks1
terraform init
terraform fmt
terraform plan 
cd -