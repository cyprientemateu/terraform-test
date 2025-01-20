provider "aws" {
  region = "us-east-1" # Change this to your desired AWS region
}

resource "aws_instance" "example" {
  ami           = "ami-0454e52560c7f5c55" # Replace with the AMI ID you want to use
  instance_type = "t2.micro"              # Replace with your desired instance type

  # Optional: Add a tag to the instance
  tags = {
    Name    = "MyEC2Instance"
    backup  = true
    jenkins = true
  }

  # Optional: Create a security group that allows SSH access
  vpc_security_group_ids = [
    aws_security_group.sg.id,
  ]
}

# Optional: Create a security group that allows SSH access
resource "aws_security_group" "sg" {
  name_prefix = "allow_ssh_"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
