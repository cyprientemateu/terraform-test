#!/bin/bash

echo "******************************************************"
echo "Deleting the eks1 module"
echo "******************************************************"
sleep 3
cd resources/DEV/eks1
terraform init
terraform destroy --auto-approve
cd -

echo "******************************************************"
echo "Deleting the bastion host module"
echo "******************************************************"
sleep 3
cd resources/DEV/ec2
terraform init
terraform destroy --auto-approve
cd -

echo "******************************************************"
echo "Deleting vpc module"
echo "******************************************************"
sleep 3
cd resources/DEV/vpc
terraform init 
terraform destroy --auto-approve
cd -

echo "******************************************************"
echo "Deleting s3 backeng module"
echo "******************************************************"
cd resources/DEV/s3-replication
terraform init
terraform destroy --auto-approve
