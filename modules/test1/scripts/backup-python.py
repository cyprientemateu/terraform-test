import boto3
from datetime import datetime
import sys

def create_ami_for_backup_instances():
    # Initialize AWS EC2 client
    ec2 = boto3.client('ec2')

    try:
        # Fetch all instances with the tag 'backup=true'
        instances = ec2.describe_instances(
            Filters=[
                {'Name': 'tag:backup', 'Values': ['true']},
                {'Name': 'instance-state-name', 'Values': ['running']}
            ]
        )

        # Iterate through instances
        for reservation in instances['Reservations']:
            for instance in reservation['Instances']:
                instance_id = instance['InstanceId']

                # Generate AMI name
                date_time = datetime.now().strftime("%Y-%m-%d-%H-%M-%S")
                ami_name = f"jenkins-backup-{date_time}"

                # Create AMI
                ami_id = ec2.create_image(
                    InstanceId=instance_id,
                    Name=ami_name,
                    NoReboot=True
                )['ImageId']

                print(f"Successfully created AMI: {ami_id} for instance: {instance_id}")

                # Add tags to the AMI
                ec2.create_tags(
                    Resources=[ami_id],
                    Tags=[
                        {'Key': 'Name', 'Value': ami_name},
                        {'Key': 'CreatedBy', 'Value': 'python script'}
                    ]
                )
                print(f"Successfully tagged AMI: {ami_id} with Name={ami_name} and CreatedBy=python script.")

    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    create_ami_for_backup_instances()
