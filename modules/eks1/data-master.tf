data "aws_vpc" "vpc" {
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
}

data "aws_subnet" "public-02" {
  filter {
    name   = "tag:Name"
    values = ["1119-dev-a1-public-subnet-2-us-east-1b"]
  }
}

data "aws_subnet" "public-03" {
  filter {
    name   = "tag:Name"
    values = ["1119-dev-a1-public-subnet-3-us-east-1c"]
  }
}
