# Transit Gateway in Primary Region
resource "aws_ec2_transit_gateway" "primary_tgw" {
  description     = "Primary Region Transit Gateway"
  amazon_side_asn = 64512

  tags = {
    Name = "Primary-TGW"
  }
}

# Transit Gateway in Secondary Region
resource "aws_ec2_transit_gateway" "secondary_tgw" {
  provider        = aws.secondary
  description     = "Secondary Region Transit Gateway"
  amazon_side_asn = 64513

  tags = {
    Name = "Secondary-TGW"
  }
}

# Transit Gateway Peering Connection
resource "aws_ec2_transit_gateway_peering_attachment" "tgw_peering" {
  transit_gateway_id      = aws_ec2_transit_gateway.primary_tgw.id
  peer_transit_gateway_id = aws_ec2_transit_gateway.secondary_tgw.id
  peer_region             = "us-west-2"

  tags = {
    Name = "TGW-Peering"
  }
}

# Accept Peering in Secondary Region
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "tgw_peering_accepter" {
  provider                      = aws.secondary
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.tgw_peering.id

  tags = {
    Name = "TGW-Peering-accepter"
  }

  depends_on = [
    aws_ec2_transit_gateway_peering_attachment.tgw_peering
  ]
}

# Attach Primary VPC to Primary TGW
resource "aws_ec2_transit_gateway_vpc_attachment" "primary_tgw_attachment" {
  transit_gateway_id = aws_ec2_transit_gateway.primary_tgw.id
  vpc_id             = aws_vpc.primary_vpc.id
  subnet_ids         = aws_subnet.primary_subnets[*].id

  tags = {
    Name = "primary-vpc-tgw"
  }
}

# Attach Secondary VPC to Secondary TGW
resource "aws_ec2_transit_gateway_vpc_attachment" "secondary_tgw_attachment" {
  provider           = aws.secondary
  transit_gateway_id = aws_ec2_transit_gateway.secondary_tgw.id
  vpc_id             = aws_vpc.secondary_vpc.id
  subnet_ids         = aws_subnet.secondary_subnets[*].id

  tags = {
    Name = "secondary-vpc-tgw"
  }
}