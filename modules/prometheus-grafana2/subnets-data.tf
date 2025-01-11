data "aws_subnet" "public-01" {
  vpc_id = data.aws_vpc.tcc_vpc.id
  filter {
    name   = "tag:Name"
    values = ["1119-dev-a1-public-subnet-1-us-east-1a"]
  }
  filter {
    name   = "availability-zone"
    values = ["us-east-1a"] # Ensure the availability zone matches your desired subnet
  }
}
