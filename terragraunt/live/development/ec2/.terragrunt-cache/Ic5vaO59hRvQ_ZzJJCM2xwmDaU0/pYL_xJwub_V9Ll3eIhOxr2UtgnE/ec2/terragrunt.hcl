terraform {
  source = "../../../../modules/DEV//ec2"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependencies {
  paths = [
    "${get_terragrunt_dir()}/../vpc", 
    ]
}

inputs = {
  aws_region             = "us-east-1"
  ami                    = "ami-0c7217cdde317cfec"
  instance_type          = "t2.micro"
  key_name               = "terraform"
  vpc_security_group_ids = ["sg-0fa88e0bcf2d36083"]
  subnet_id              = "subnet-02e286c9bdfb33f0b"
  enable_termination_protection = false
  volume_size            = "10"
  allowed_ports = [
    22
  ]
  tags = {
    "id"             = "1119"
    "owner"          = "tcc"
    "teams"          = "Devops"
    "environment"    = "development"
    "project"        = "a1"
    "create_by"      = "Terraform"
    "cloud_provider" = "aws"
  }
} 
