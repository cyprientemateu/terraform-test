resource "aws_security_group" "tcc_sg" {
  vpc_id = aws_vpc.tcc_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.tags, {
    Name = "tcc_sg"
  })
}
resource "aws_security_group_rule" "tcc_sg_rule" {
  for_each          = { for pts, port in var.tcc_ports : pts => port }
  type              = "ingress"
  from_port         = each.value
  to_port           = each.value
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tcc_sg.id

}