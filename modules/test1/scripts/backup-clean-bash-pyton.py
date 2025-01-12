import boto3
from datetime import datetime
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def create_ami_for_backup_instances():
    # Initialize AWS EC2 client
    ec2 = boto3.client('ec2')

    try:
        # Fetch all instances with the tag 'backup=true'
        instances = ec2.describe_instances(
            Filters=[{'Name': 'tag:backup', 'Values': ['true']},
                     {'Name': 'instance-state-name', 'Values': ['running']}]
        )

        # Check if instances are found
        if not instances['Reservations']:
            logging.info("No running instances with 'backup=true' tag found.")
            return

        # Iterate through instances
        for reservation in instances['Reservations']:
            for instance in reservation['Instances']:
                instance_id = instance['InstanceId']

                # Generate AMI name with timestamp
                date_time = datetime.now().strftime("%Y-%m-%d-%H-%M-%S")
                ami_name = f"jenkins-backup-{date_time}"

                # Create AMI
                logging.info(f"Creating AMI for instance: {instance_id}...")
                ami_response = ec2.create_image(
                    InstanceId=instance_id,
                    Name=ami_name,
                    NoReboot=True
                )
                ami_id = ami_response['ImageId']

                logging.info(f"Successfully created AMI: {ami_id} for instance: {instance_id}")

                # Add tags to the AMI
                ec2.create_tags(
                    Resources=[ami_id],
                    Tags=[{'Key': 'Name', 'Value': ami_name},
                          {'Key': 'CreatedBy', 'Value': 'python script'}]
                )
                logging.info(f"Successfully tagged AMI: {ami_id} with Name={ami_name} and CreatedBy=python script.")

                # Delete older AMIs, keeping only the 2 latest
                delete_old_amis(ec2)

    except Exception as e:
        logging.error(f"An error occurred: {e}")


def delete_old_amis(ec2):
    try:
        # Fetch all AMIs created by the script (CreatedBy=python script)
        amis_python_script = ec2.describe_images(
            Filters=[{'Name': 'tag:CreatedBy', 'Values': ['python script']}]
        )['Images']

        # Fetch all AMIs created by the bash shell script (CreatedBy=bash shell script)
        amis_bash_shell_script = ec2.describe_images(
            Filters=[{'Name': 'tag:CreatedBy', 'Values': ['bash shell script']}]
        )['Images']

        # Combine both lists
        amis = amis_python_script + amis_bash_shell_script

        if len(amis) <= 2:
            logging.info("No old AMIs to delete. Keeping the latest 2 or fewer.")
            return

        # Sort AMIs by creation date (latest first)
        sorted_amis = sorted(amis, key=lambda x: x['CreationDate'], reverse=True)

        # Keep the 2 latest AMIs
        amis_to_delete = sorted_amis[2:]

        # Delete AMIs older than the 2 most recent
        for ami in amis_to_delete:
            ami_id = ami['ImageId']
            logging.info(f"Deleting AMI: {ami_id}...")

            # Deregister the AMI first
            ec2.deregister_image(ImageId=ami_id)
            logging.info(f"Successfully deregistered AMI: {ami_id}")

            # Now delete the associated snapshots
            block_device_mappings = ami.get('BlockDeviceMappings', [])
            for device in block_device_mappings:
                snapshot_id = device.get('Ebs', {}).get('SnapshotId')
                if snapshot_id:
                    logging.info(f"Deleting snapshot: {snapshot_id} associated with AMI: {ami_id}")
                    ec2.delete_snapshot(SnapshotId=snapshot_id)
                    logging.info(f"Successfully deleted snapshot: {snapshot_id}")

    except Exception as e:
        logging.error(f"An error occurred while deleting old AMIs: {e}")


if __name__ == "__main__":
    create_ami_for_backup_instances()
