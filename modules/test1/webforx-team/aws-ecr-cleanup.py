import boto3
import re
from datetime import datetime, timezone, timedelta

ecr = boto3.client('ecr')
region = 'us-east-1'  # Replace with your region
dry_run = True  # Set to False for actual deletion

# Patterns to exclude from deletion
EXCLUDE_TAGS = ['base_image']
EXCLUDE_REGEX = r'^v\d+(\.\d+)*$'  # Matches v1, v1.0, v2.3.1, etc.

def list_repositories():
    repos = []
    paginator = ecr.get_paginator('describe_repositories')
    for page in paginator.paginate():
        for repo in page['repositories']:
            repos.append(repo['repositoryName'])
    return repos

def should_preserve(tag):
    if tag in EXCLUDE_TAGS:
        return True
    if re.match(EXCLUDE_REGEX, tag):
        return True
    return False

def cleanup_images(repo):
    now = datetime.now(timezone.utc)
    deleted = []

    paginator = ecr.get_paginator('list_images')
    for page in paginator.paginate(repositoryName=repo, filter={'tagStatus': 'TAGGED'}):
        image_ids = page['imageIds']
        if not image_ids:
            continue

        describe_response = ecr.batch_get_image(repositoryName=repo, imageIds=image_ids)
        for img in describe_response['images']:
            tags = img.get('imageId', {}).get('imageTag', '')
            if should_preserve(tags):
                continue

        # Get image details (for timestamp)
        describe = ecr.describe_images(repositoryName=repo, imageIds=image_ids)
        for detail in describe['imageDetails']:
            tags = detail.get('imageTags', [])
            pushed_at = detail['imagePushedAt']
            age_days = (now - pushed_at).days

            if age_days > 15:
                if any(should_preserve(tag) for tag in tags):
                    continue
                for tag in tags:
                    print(f"[DRY RUN] Deleting {repo}:{tag} pushed at {pushed_at}") if dry_run else None
                    if not dry_run:
                        ecr.batch_delete_image(repositoryName=repo, imageIds=[{'imageTag': tag}])
                        deleted.append(f"{repo}:{tag}")
    
    return deleted

def lambda_handler(event, context):
    repos = list_repositories()
    log = []

    for repo in repos:
        deleted_images = cleanup_images(repo)
        log.extend(deleted_images)

    print("Deleted Images:" if not dry_run else "Dry Run Deleted Images:")
    for image in log:
        print(image)
