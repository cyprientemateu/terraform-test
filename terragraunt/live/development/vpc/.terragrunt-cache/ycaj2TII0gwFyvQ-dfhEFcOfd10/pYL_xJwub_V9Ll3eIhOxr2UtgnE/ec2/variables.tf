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
  default = []
}

variable "vpc_id" {
  type    = string
  default = "vpc-026a1034816688c1d"
}

# variable "subnet_id" {
#   type    = string
#   default = "subnet-02e286c9bdfb33f0b"
# }

variable "volume_size" {
  type    = string
  default = "10"
}

variable "instance_name" {
  type    = string
  default = "test"
}

variable "sg_name" {
  type    = string
  default = "tcc-sg"
}

variable "enable_termination_protection" {
  type    = bool
  default = false
}

variable "allowed_ports" {
  description = "List of allowed ports"
  type        = list(number)
  default = [
    22,
    80,
    8080
  ]
}

variable "tags" {
  type = map(any)
  default = {
    "id"             = "1119"
    "owner"          = "tcc"
    "teams"          = "Devops"
    "environment"    = "dev"
    "project"        = "a1"
    "create_by"      = "Terraform"
    "cloud_provider" = "aws"
  }
}
