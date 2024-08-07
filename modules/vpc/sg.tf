resource "aws_security_group" "tcc_sg" {
  description = "Security group for my EC2 instance"
  vpc_id      = aws_vpc.tcc_vpc.id
  tags = merge(var.tags, {
    Name = format("%s-%s-%s-tcc-sg", var.tags["id"], var.tags["environment"], var.tags["project"])
    },
  )

  // Inbound rules
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // Allow SSH access from anywhere
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // Allow HTTP access from anywhere
  }

  // Outbound rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] // Allow all outbound traffic
  }
}
