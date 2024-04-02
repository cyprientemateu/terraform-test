variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "ami" {
  type    = string
  default = "ami-0c7217cdde317cfec"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "key_name" {
  type    = string
  default = "terraform"
}

variable "vpc_security_group_ids" {
  type    = list(string)
  default = ["sg-0fa88e0bcf2d36083"]
}

variable "subnet_id" {
  type    = string
  default = "subnet-02e286c9bdfb33f0b"
}

variable "volume_size" {
  type    = string
  default = "10"
}

variable "tags" {
  type = map(any)
  default = {
    "id"             = "1119"
    "owner"          = "TCC"
    "teams"          = "Devops"
    "environment"    = "development"
    "project"        = "a1"
    "create_by"      = "Terraform"
    "cloud_provider" = "aws"
  }
}

variable "backend" {
  type = map(string)
  default = {
    bucket         = ""
    dynamodb_table = ""
    key            = ""
    region         = ""
  }
}

variable "tcc_ports" {
  type = list(number)
  default = [
    22,
    80,
    8080
  ]
}

variable "vpc_id" {
  description = "aws_vpc.tcc_vpc"
  type        = string
}

variable "vpc_cidr" {
  description = "10.0.0.0/16"
  type        = string
}
