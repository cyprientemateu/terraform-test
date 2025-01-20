import boto3
import os

def lambda_handler(event, context):
    action = event.get("action")
    tag_key = os.environ["TAG_KEY"]
    tag_value = os.environ["TAG_VALUE"]

    ec2 = boto3.client("ec2")
    instances = ec2.describe_instances(Filters=[
        {"Name": f"tag:{tag_key}", "Values": [tag_value]},
        {"Name": "instance-state-name", "Values": ["running" if action == "stop" else "stopped"]}
    ])

    instance_ids = [i["InstanceId"] for r in instances["Reservations"] for i in r["Instances"]]

    if not instance_ids:
        print(f"No instances to {action}.")
        return

    if action == "start":
        ec2.start_instances(InstanceIds=instance_ids)
        print(f"Started instances: {instance_ids}")
    elif action == "stop":
        ec2.stop_instances(InstanceIds=instance_ids)
        print(f"Stopped instances: {instance_ids}")
    else:
        print(f"Invalid action: {action}")
