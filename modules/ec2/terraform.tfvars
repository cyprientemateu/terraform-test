aws_region                    = "us-east-1"
ami                           = "ami-0c7217cdde317cfec"
instance_type                 = "t2.micro"
sg_name                       = "test"
instance_name                 = "test"
key_name                      = "terraform"
vpc_security_group_ids        = []
volume_size                   = "10"
enable_termination_protection = false
allowed_ports = [
  22,
]
tags = {
  "id"             = "1119"
  "owner"          = "tcc"
  "teams"          = "Devops"
  "environment"    = "development"
  "project"        = "a3"
  "create_by"      = "Terraform"
  "cloud_provider" = "aws"
}
