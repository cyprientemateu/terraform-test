aws_region             = "us-east-1"
ami                    = "ami-0c7217cdde317cfec"
instance_type          = "t2.micro"
key_name               = "terraform"
vpc_security_group_ids = ["sg-0fa88e0bcf2d36083"]
subnet_id              = "subnet-02e286c9bdfb33f0b"
volume_size            = "10"
tags = {
  "id"             = "1119"
  "owner"          = "TCC"
  "teams"          = "Devops"
  "environment"    = "development"
  "project"        = "a3"
  "create_by"      = "Terraform"
  "cloud_provider" = "aws"
}

tcc_ports = [
  22,
  80,
  8080
]
