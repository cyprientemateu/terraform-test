# data "aws_ami" "custom_ami" {
#   most_recent = true

#   filter {
#     name   = "name"
#     values = ["Jenkins-Master"]
#   }

#   owners = ["734028878759"]
# }

data "aws_vpc" "tcc_vpc" {
  filter {
    name   = "tag:Name"
    values = ["1119-dev-a1-vpc"]
  }
  filter {
    name   = "tag:environment"
    values = ["dev"]
  }
  filter {
    name   = "tag:project"
    values = ["a1"]
  }
}

data "aws_subnet" "public-01" {
  filter {
    name   = "tag:Name"
    values = ["1119-dev-a1-public-subnet-1-us-east-1a"]
  }
  # filter {
  #   name   = "tag:environment"
  #   values = ["dev"]
  # }
  # filter {
  #   name   = "tag:project"
  #   values = ["a1"]
  # }
}

data "aws_security_group" "tcc_sg" {
  filter {
    name   = "tag:Name"
    values = ["1119-dev-a1-tcc-sg"]
  }
  filter {
    name   = "tag:environment"
    values = ["dev"]
  }
  filter {
    name   = "tag:project"
    values = ["a1"]
  }
}