# Subnets
resource "aws_subnet" "primary_subnets" {
  count             = 2
  vpc_id            = aws_vpc.primary_vpc.id
  cidr_block        = "10.1.${count.index}.0/24"
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index)
}

resource "aws_subnet" "secondary_subnets" {
  provider          = aws.secondary
  count             = 2
  vpc_id            = aws_vpc.secondary_vpc.id
  cidr_block        = "10.2.${count.index}.0/24"
  availability_zone = element(["us-west-2a", "us-west-2b"], count.index)
}