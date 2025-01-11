variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "tags" {
  type = map(string)
}

variable "root_volume" {
  description = "Size of the root EBS volume in GiB"
  type        = number
}

variable "resource_type" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string
}

variable "volume_type" {
  type = string
}