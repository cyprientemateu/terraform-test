import boto3
import re
from datetime import datetime, timezone, timedelta

# Configuration
REGION = 'us-east-1'  # Update as needed
EXCLUDE_TAGS = ['base_image', 'latest', 'tcc', 'prod', 'production', 'test', 'testing', '5']
EXCLUDE_PATTERN = re.compile(r'^v\d+(\.\d+)*$')
DAYS_OLD = 15
DRY_RUN = False  # Set to False to perform actual deletions

# Initialize AWS clients
ecr = boto3.client('ecr', region_name=REGION)

# Logs for auditing
logs = []

def should_exclude(tag):
    """Determine if a tag should be excluded based on predefined rules."""
    return tag in EXCLUDE_TAGS or EXCLUDE_PATTERN.match(tag)

def lambda_handler(event=None, context=None):
    """Main function to perform ECR cleanup based on rules."""
    try:
        repositories = ecr.describe_repositories()['repositories']
    except Exception as e:
        print(f"Error listing repositories: {e}")
        return

    cutoff_date = datetime.now(timezone.utc) - timedelta(days=DAYS_OLD)

    for repo in repositories:
        repo_name = repo['repositoryName']
        print(f"\nProcessing repository: {repo_name}")

        next_token = None
        while True:
            try:
                list_kwargs = {
                    'repositoryName': repo_name,
                    'filter': {'tagStatus': 'TAGGED'},
                    'filter': {'tagStatus': 'ANY'},
                    'maxResults': 1000
                }
                if next_token:
                    list_kwargs['nextToken'] = next_token

                response = ecr.list_images(**list_kwargs)
                image_ids = response.get('imageIds', [])
            except Exception as e:
                print(f"Error listing images in {repo_name}: {e}")
                break

            if not image_ids:
                break

            try:
                # Batch get image details
                describe_response = ecr.batch_get_image(
                    repositoryName=repo_name,
                    imageIds=image_ids
                )
                images = describe_response.get('images', [])
            except Exception as e:
                print(f"Error describing images in {repo_name}: {e}")
                break

            for image in images:
                image_tags = image.get('imageTags', [])
                image_digest = image.get('imageId', {}).get('imageDigest')
                image_pushed_at = image.get('imagePushedAt')

                # If no tags, skip
                if not image_tags:
                    continue

                # Check if any tag should exclude the image
                if any(should_exclude(tag) for tag in image_tags):
                    continue

                # Check age
                if not image_pushed_at:
                    print(f"Image {image_digest} in {repo_name} has no push date, skipping.")
                    continue

                if image_pushed_at < cutoff_date:
                    for tag in image_tags:
                        log_msg = f"Would delete: {repo_name}:{tag} (pushed at {image_pushed_at})"
                        if DRY_RUN:
                            logs.append(log_msg)
                        else:
                            try:
                                ecr.batch_delete_image(
                                    repositoryName=repo_name,
                                    imageIds=[{'imageDigest': image_digest}]
                                )
                                logs.append(f"Deleted: {repo_name}:{tag} (pushed at {image_pushed_at})")
                            except Exception as e:
                                logs.append(f"Error deleting {repo_name}:{tag}: {e}")

            next_token = response.get('nextToken')
            if not next_token:
                break

    # Output logs
    print("\n--- Cleanup Summary ---")
    for log in logs:
        print(log)
    print(f"\nTotal images marked for deletion (dry run={DRY_RUN}): {len(logs)}")

# Uncomment below if you want to run the script outside AWS Lambda
# if __name__ == "__main__":
#     lambda_handler()
