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