variable "vpc_id" {
  default = "vpc-026a1034816688c1d" # Replace with your VPC ID
}

variable "public-subnets" {
  default = [
    "subnet-02e286c9bdfb33f0b",
    "subnet-011cf4a50c2518de6",
    "subnet-06024f887faf3709b"
  ] # Replace with your subnet IDs
}

variable "private-subnets" {
  default = [
    "subnet-02e286c9bdfb33f0b",
    "subnet-011cf4a50c2518de6",
    "subnet-06024f887faf3709b"
  ] # Replace with your subnet IDs
}