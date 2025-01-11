# Application Load Balancer
resource "aws_lb" "main" {
  depends_on         = [aws_security_group.alb_sg]
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public-subnets

  enable_deletion_protection = false

  tags = {
    Name = "blue-green-yellow-alb"
  }
}