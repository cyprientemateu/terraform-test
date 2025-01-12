#!/bin/bash

# Fetch all instance IDs with the tag "backup=true"
INSTANCE_IDS=$(aws ec2 describe-instances \
  --filters "Name=tag:backup,Values=true" "Name=instance-state-name,Values=running" \
  --query "Reservations[*].Instances[*].InstanceId" --output text)

# Exit if no instances found
if [ -z "$INSTANCE_IDS" ]; then
  echo "No instances found with the tag backup=true."
  exit 1
fi

# Iterate over each instance ID
for INSTANCE_ID in $INSTANCE_IDS; do
  # Generate AMI name
  DATE_TIME=$(date +"%Y-%m-%d-%H-%M-%S")
  AMI_NAME="jenkins-backup-$DATE_TIME"

  # Create AMI
  AMI_ID=$(aws ec2 create-image \
    --instance-id "$INSTANCE_ID" \
    --name "$AMI_NAME" \
    --no-reboot \
    --query "ImageId" --output text)

  if [ $? -eq 0 ]; then
    echo "Successfully created AMI: $AMI_ID for instance: $INSTANCE_ID"

    # Add a tag to the AMI
    aws ec2 create-tags \
      --resources "$AMI_ID" \
      --tags Key=Name,Value="$AMI_NAME" Key=CreatedBy,Value="bash shell script"

    if [ $? -eq 0 ]; then
      echo "Successfully tagged AMI: $AMI_ID with Name=$AMI_NAME and CreatedBy=bash shell script."
    else
      echo "Failed to tag AMI: $AMI_ID."
    fi
  else
    echo "Failed to create AMI for instance: $INSTANCE_ID."
  fi

done
