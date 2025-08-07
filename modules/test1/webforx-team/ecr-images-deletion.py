import json
import boto3
import logging
from datetime import datetime, timedelta
import re
import os

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS clients
ecr_client = boto3.client('ecr')

def lambda_handler(event, context):
    """
    ECR Image Cleanup - 1 MINUTE RETENTION TESTING
    Deletes images older than 1 minute (except base_image and v.* tags)
    """
    try:
        # Get configuration from environment variables
        dry_run = os.environ.get('DRY_RUN', 'true').lower() == 'true'
        retention_minutes = int(os.environ.get('RETENTION_MINUTES', '1'))
        
        logger.info(f"🚀 Starting ECR cleanup - 1 MINUTE RETENTION TEST")
        logger.info(f"   DRY_RUN: {dry_run}")
        logger.info(f"   RETENTION: {retention_minutes} minute(s)")
        logger.info(f"   TIME: {datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')}")
        
        # Get all ECR repositories
        repositories = get_ecr_repositories()
        
        total_deleted = 0
        cleanup_summary = []
        
        for repo in repositories:
            repo_name = repo['repositoryName']
            logger.info(f"📦 Processing repository: {repo_name}")
            
            deleted_count = process_repository(repo_name, retention_minutes, dry_run)
            total_deleted += deleted_count
            
            cleanup_summary.append({
                'repository': repo_name,
                'images_deleted': deleted_count
            })
        
        # Log final summary
        action_text = "would be deleted" if dry_run else "deleted"
        logger.info(f"✅ Cleanup completed. Total images {action_text}: {total_deleted}")
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': f"ECR cleanup completed - 1 minute retention test",
                'dry_run': dry_run,
                'retention_minutes': retention_minutes,
                'total_deleted': total_deleted,
                'summary': cleanup_summary,
                'timestamp': datetime.now().isoformat()
            })
        }
        
    except Exception as e:
        logger.error(f"❌ Error during ECR cleanup: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': f"ECR cleanup failed: {str(e)}",
                'timestamp': datetime.now().isoformat()
            })
        }

def get_ecr_repositories():
    """Get all ECR repositories in the current account/region"""
    repositories = []
    try:
        paginator = ecr_client.get_paginator('describe_repositories')
        
        for page in paginator.paginate():
            repositories.extend(page['repositories'])
        
        logger.info(f"📋 Found {len(repositories)} ECR repositories")
        return repositories
        
    except Exception as e:
        logger.error(f"❌ Error fetching repositories: {str(e)}")
        return []

def process_repository(repo_name, retention_minutes, dry_run):
    """Process a single ECR repository for cleanup"""
    try:
        # Get all images in the repository
        images = get_repository_images(repo_name)
        
        if not images:
            logger.info(f"📭 No images found in repository: {repo_name}")
            return 0
        
        # Filter images for deletion
        images_to_delete = filter_images_for_deletion(images, retention_minutes)
        
        if not images_to_delete:
            logger.info(f"✋ No images to delete in repository: {repo_name}")
            return 0
        
        # Log what will be deleted
        action_text = "Would delete" if dry_run else "Deleting"
        logger.info(f"🗑  Repository {repo_name}: {action_text} {len(images_to_delete)} images")
        
        # Log details of each image
        for image in images_to_delete:
            log_image_details(repo_name, image, dry_run)
        
        # Perform deletion if not dry run
        if not dry_run:
            delete_images(repo_name, images_to_delete)
        
        return len(images_to_delete)
        
    except Exception as e:
        logger.error(f"❌ Error processing repository {repo_name}: {str(e)}")
        return 0

def get_repository_images(repo_name):
    """Get all images from a repository with their details"""
    images = []
    try:
        paginator = ecr_client.get_paginator('describe_images')
        
        for page in paginator.paginate(repositoryName=repo_name):
            images.extend(page['imageDetails'])
        
        logger.info(f"📊 Repository {repo_name} has {len(images)} images")
        return images
        
    except Exception as e:
        logger.error(f"❌ Error fetching images for {repo_name}: {str(e)}")
        return []

def filter_images_for_deletion(images, retention_minutes):
    """
    Filter images based on 1-MINUTE retention rules:
    - Keep images with 'base_image' tag
    - Keep images with versioning pattern 'v.*'
    - DELETE images older than 1 minute
    """
    cutoff_date = datetime.now() - timedelta(minutes=retention_minutes)
    logger.info(f"🕒 CUTOFF TIME: {cutoff_date.strftime('%Y-%m-%d %H:%M:%S')} UTC")
    logger.info(f"🕒 Images older than this will be deleted (unless preserved)")
    
    images_to_delete = []
    
    for image in images:
        # Skip images without imagePushedAt
        if 'imagePushedAt' not in image:
            logger.warning(f"⚠  Image missing push date, skipping: {image.get('imageDigest', 'unknown')}")
            continue
        
        # Calculate image age
        image_date = image['imagePushedAt'].replace(tzinfo=None)
        age_seconds = (datetime.now() - image_date).total_seconds()
        age_minutes = age_seconds / 60
        
        # Check if image is older than retention period
        if image_date >= cutoff_date:
            logger.info(f"🚫 KEEPING (too recent): age {age_minutes:.1f}m - {image.get('imageTags', ['untagged'])}")
            continue  # Image is too new, skip
        
        # Check preservation rules
        if should_preserve_image(image):
            logger.info(f"🛡  PRESERVING (protected tag): age {age_minutes:.1f}m - {image.get('imageTags', ['untagged'])}")
            continue  # Image should be preserved, skip
        
        # Image meets deletion criteria
        logger.info(f"✅ WILL DELETE: age {age_minutes:.1f}m - {image.get('imageTags', ['untagged'])}")
        images_to_delete.append(image)
    
    return images_to_delete

def should_preserve_image(image):
    """
    Check if an image should be preserved based on tag rules
    Returns True if image should be preserved, False if it can be deleted
    """
    # Get image tags
    tags = image.get('imageTags', [])
    
    # If no tags, it can be deleted (if old enough)
    if not tags:
        return False
    
    for tag in tags:
        # Preserve images with 'base_image' tag
        if tag == 'base_image':
            return True
        
        # Preserve images following versioning pattern v.*
        if re.match(r'^v\d+\..*', tag):
            return True
    
    return False

def log_image_details(repo_name, image, dry_run):
    """Log details of images being deleted for audit purposes"""
    tags = image.get('imageTags', ['<untagged>'])
    digest = image.get('imageDigest', 'unknown')
    pushed_at = image.get('imagePushedAt', 'unknown')
    size_mb = round(image.get('imageSizeInBytes', 0) / 1024 / 1024, 2)
    
    action = "WOULD DELETE" if dry_run else "DELETING"
    
    logger.info(f"  {action} - Repository: {repo_name}")
    logger.info(f"    Tags: {tags}")
    logger.info(f"    Digest: {digest[:19]}...")
    logger.info(f"    Size: {size_mb} MB")
    logger.info(f"    Pushed: {pushed_at}")

def delete_images(repo_name, images_to_delete):
    """Delete images from ECR repository in batches"""
    batch_size = 100
    
    for i in range(0, len(images_to_delete), batch_size):
        batch = images_to_delete[i:i + batch_size]
        
        # Prepare image identifiers for deletion
        image_ids = []
        for image in batch:
            if 'imageTags' in image and image['imageTags']:
                # Delete by tag if available
                for tag in image['imageTags']:
                    image_ids.append({'imageTag': tag})
            else:
                # Delete by digest if no tags
                image_ids.append({'imageDigest': image['imageDigest']})
        
        try:
            response = ecr_client.batch_delete_image(
                repositoryName=repo_name,
                imageIds=image_ids
            )
            
            deleted = response.get('imageIds', [])
            failures = response.get('failures', [])
            
            logger.info(f"✅ Successfully deleted {len(deleted)} images from {repo_name}")
            
            if failures:
                logger.warning(f"⚠  Failed to delete {len(failures)} images from {repo_name}")
                for failure in failures:
                    logger.warning(f"   Failure: {failure}")
                
        except Exception as e:
            logger.error(f"❌ Error deleting batch from {repo_name}: {str(e)}")