# Inter-Region VPC Peering with AWS Transit Gateway

This Terraform project sets up **inter-region VPC peering** using **AWS Transit Gateway**, along with two EC2 instances in different AWS regions (**us-east-1** and **us-west-2**) to test connectivity.

## **Prerequisites**
- **Terraform** installed (v1.0+)
- **AWS CLI** configured with appropriate IAM permissions
- **SSH key pair** created in AWS (`your-key-pair`)

## **Project Structure**

📂 terraform-vpc-peering ├── main.tf # Main Terraform configuration ├── variables.tf # Input variables ├── outputs.tf # Terraform output values ├── README.md # Project documentation

# Overview of the Setup
 1. Creates a Transit Gateway in a primary region.
 2. Attaches VPCs from different regions to the Transit Gateway.
 3. Establishes routing between the VPCs via the Transit Gateway.

# Explanation
 1. Creates a Transit Gateway (aws_ec2_transit_gateway).
 2. Creates two VPCs (one in each region).
 3. Attaches both VPCs to the Transit Gateway (aws_ec2_transit_gateway_vpc_attachment).
 4. Configures routing in both VPCs so they can communicate with each other.
 5. Uses provider aliasing to work with multiple AWS regions in the same script.

# Next Steps
 1. Run terraform init to initialize the Terraform workspace.
 2. Run terraform apply to provision the resources.
 3. This setup enables secure inter-region connectivity between VPCs using AWS Transit Gateway instead of traditional VPC Peering.

# Terraform configuration to launch two EC2 instances in different regions and attach them to the VPCs connected via AWS Transit Gateway for testing connectivity.

```hcl
provider "aws" {
  region = "us-east-1" # Primary region
}

provider "aws" {
  alias  = "secondary"
  region = "us-west-2" # Secondary region
}

# Create Transit Gateway in Primary Region
resource "aws_ec2_transit_gateway" "tgw" {
  description = "Inter-Region Transit Gateway"
  amazon_side_asn = 64512

  tags = {
    Name = "InterRegion-TGW"
  }
}

# Create a VPC in Primary Region
resource "aws_vpc" "primary_vpc" {
  cidr_block = "10.1.0.0/16"
}

# Create a VPC in Secondary Region
resource "aws_vpc" "secondary_vpc" {
  provider   = aws.secondary
  cidr_block = "10.2.0.0/16"
}

# Attach Primary VPC to Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "primary_tgw_attachment" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = aws_vpc.primary_vpc.id
  subnet_ids         = aws_subnet.primary_subnets[*].id

  tags = {
    Name = "Primary-VPC-Attachment"
  }
}

# Attach Secondary VPC to Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "secondary_tgw_attachment" {
  provider            = aws.secondary
  transit_gateway_id  = aws_ec2_transit_gateway.tgw.id
  vpc_id              = aws_vpc.secondary_vpc.id
  subnet_ids          = aws_subnet.secondary_subnets[*].id

  tags = {
    Name = "Secondary-VPC-Attachment"
  }
}

# Route Table in Primary VPC
resource "aws_route_table" "primary_route_table" {
  vpc_id = aws_vpc.primary_vpc.id

  route {
    cidr_block         = "10.2.0.0/16"
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }

  tags = {
    Name = "Primary-VPC-RouteTable"
  }
}

# Route Table in Secondary VPC
resource "aws_route_table" "secondary_route_table" {
  provider = aws.secondary
  vpc_id   = aws_vpc.secondary_vpc.id

  route {
    cidr_block         = "10.1.0.0/16"
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }

  tags = {
    Name = "Secondary-VPC-RouteTable"
  }
}

# Associate Route Table with Subnets
resource "aws_route_table_association" "primary_rt_association" {
  subnet_id      = aws_subnet.primary_subnets[0].id
  route_table_id = aws_route_table.primary_route_table.id
}

resource "aws_route_table_association" "secondary_rt_association" {
  provider       = aws.secondary
  subnet_id      = aws_subnet.secondary_subnets[0].id
  route_table_id = aws_route_table.secondary_route_table.id
}

# Subnets in Primary VPC
resource "aws_subnet" "primary_subnets" {
  count = 2

  vpc_id            = aws_vpc.primary_vpc.id
  cidr_block        = "10.1.${count.index}.0/24"
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index)
}

# Subnets in Secondary VPC
resource "aws_subnet" "secondary_subnets" {
  provider = aws.secondary
  count    = 2

  vpc_id            = aws_vpc.secondary_vpc.id
  cidr_block        = "10.2.${count.index}.0/24"
  availability_zone = element(["us-west-2a", "us-west-2b"], count.index)
}
```

```hcl
# EC2 Instance in Primary Region (us-east-1)
resource "aws_instance" "primary_instance" {
  ami             = "ami-0fc5d935ebf8bc3bc"  # Replace with the latest Amazon Linux AMI ID
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.primary_subnets[0].id
  key_name        = "your-key-pair"  # Replace with your key pair
  security_groups = [aws_security_group.primary_sg.name]

  tags = {
    Name = "Primary-Region-EC2"
  }
}

# EC2 Instance in Secondary Region (us-west-2)
resource "aws_instance" "secondary_instance" {
  provider        = aws.secondary
  ami             = "ami-0d3f515e98297798f"  # Replace with the latest Amazon Linux AMI ID in us-west-2
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.secondary_subnets[0].id
  key_name        = "your-key-pair"  # Replace with your key pair
  security_groups = [aws_security_group.secondary_sg.name]

  tags = {
    Name = "Secondary-Region-EC2"
  }
}

# Security Group for Primary Region EC2
resource "aws_security_group" "primary_sg" {
  name        = "primary-sg"
  vpc_id      = aws_vpc.primary_vpc.id
  description = "Allow ICMP and SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Primary-SG"
  }
}

# Security Group for Secondary Region EC2
resource "aws_security_group" "secondary_sg" {
  provider    = aws.secondary
  name        = "secondary-sg"
  vpc_id      = aws_vpc.secondary_vpc.id
  description = "Allow ICMP and SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Secondary-SG"
  }
}
```
## Difference Between AWS Transit Gateway and VPC Peering  

AWS offers **VPC Peering** and **Transit Gateway** for inter-VPC communication, but they differ significantly in architecture, scalability, and use cases.  

| Feature            | **VPC Peering** | **AWS Transit Gateway (TGW)** |
|--------------------|----------------|-------------------------------|
| **Architecture**  | Direct connection between two VPCs | Centralized hub for multiple VPCs |
| **Scalability**  | Limited to a mesh of peer connections (complex for many VPCs) | Easily connects hundreds of VPCs via a single TGW |
| **Routing**  | Manually configure route tables in each VPC | TGW manages routes centrally |
| **Multi-Region Support** | Supports inter-region peering, but each connection must be explicitly configured | Natively supports multi-region peering and scales easily |
| **Performance**  | Low latency and direct communication | Uses AWS backbone, optimized for high throughput |
| **Security**  | No additional security controls beyond NACLs and Security Groups | Can use AWS Resource Access Manager (RAM) for permissions and segmentation |
| **Cost**  | No additional charge (only inter-VPC traffic) | Charged based on attachments and data processing |

### **When to Use What?**  
✅ **Use VPC Peering** when connecting a **small number** of VPCs with minimal management overhead.  

✅ **Use AWS Transit Gateway** when connecting **many VPCs** across multiple regions, especially in a hub-and-spoke architecture.  

