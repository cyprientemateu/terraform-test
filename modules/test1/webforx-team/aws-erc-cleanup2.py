import boto3
import re
from datetime import datetime, timezone, timedelta

# Configuration
REGION = 'us-east-1'  # update as needed
EXCLUDE_TAGS = ['base_image']
EXCLUDE_PATTERN = re.compile(r'^v\d+(\.\d+)*$')
DAYS_OLD = 15
DRY_RUN = True  # Set to False to enable deletions

# Clients
ecr = boto3.client('ecr', region_name=REGION)
logs = []

def should_exclude(tag):
    return tag in EXCLUDE_TAGS or EXCLUDE_PATTERN.match(tag)

def lambda_handler(event, context):
    repositories = ecr.describe_repositories()['repositories']
    cutoff = datetime.now(timezone.utc) - timedelta(days=DAYS_OLD)

    for repo in repositories:
        repo_name = repo['repositoryName']
        print(f"Scanning repository: {repo_name}")
        next_token = None

        while True:
            kwargs = {'repositoryName': repo_name, 'filter': {'tagStatus': 'TAGGED'}}
            if next_token:
                kwargs['nextToken'] = next_token

            response = ecr.list_images(**kwargs)
            image_ids = response['imageIds']
            if not image_ids:
                break

            details = ecr.batch_get_image(repositoryName=repo_name, imageIds=image_ids)
            for image_detail in details.get('images', []):
                image_tags = image_detail.get('imageId', {}).get('imageTag')
                if not image_tags:
                    continue

                if should_exclude(image_tags):
                    continue

                # Get image pushed time
                describe = ecr.describe_images(repositoryName=repo_name, imageIds=[image_detail['imageId']])
                image = describe['imageDetails'][0]
                pushed_at = image.get('imagePushedAt')

                if pushed_at and pushed_at < cutoff:
                    logs.append(f"Deleting: {repo_name}:{image_tags} (pushed {pushed_at})")
                    if not DRY_RUN:
                        ecr.batch_delete_image(
                            repositoryName=repo_name,
                            imageIds=[image_detail['imageId']]
                        )
            next_token = response.get('nextToken')
            if not next_token:
                break

    # Logging
    for log in logs:
        print(log)
    print(f"Total deletions (dry run={DRY_RUN}): {len(logs)}")
