#!/bin/bash

echo "******************************************************"
echo "Deploying s3 backeng module"
echo "******************************************************"
sleep 3
cd resources/DEV/s3-replication
terraform apply --auto-approve
cd -

echo "******************************************************"
echo "Deploying vpc module"
echo "******************************************************"
sleep 3
cd resources/DEV/vpc
terraform apply --auto-approve
cd -

echo "******************************************************"
echo "Deploying the bastion host module"
echo "******************************************************"
sleep 3
cd resources/DEV/ec2
terraform apply --auto-approve
cd -

echo "******************************************************"
echo "Deleting the eks1 module"
echo "******************************************************"
sleep 3
cd resources/DEV/eks1
terraform apply --auto-approve
cd -