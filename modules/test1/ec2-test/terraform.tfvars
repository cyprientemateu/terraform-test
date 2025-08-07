aws_region    = "us-east-1"
instance_type = "t3.medium"
key_name      = "terraform"
instance_name = "my-ec2-instance"

# Storage configuration
root_volume_size       = 30    # Root volume size in GB
root_volume_type       = "gp3" # gp3, gp2, io1, io2
additional_volume_size = 0     # Additional volume in GB (0 to disable)
additional_volume_type = "gp3" # Type for additional volume