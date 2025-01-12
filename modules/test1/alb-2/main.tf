# Security Group for ALB and EC2 Instances
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP traffic for ALB"
  vpc_id      = var.vpc_id

  # Ingress rule for HTTP (port 80)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress rule for HTTPS (port 443)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rule for all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "alb-sg"
    Environment = "development"
  }
}

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

# Create Target Groups
resource "aws_lb_target_group" "blue" {
  name        = "blue-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "blue-tg"
  }
}

resource "aws_lb_target_group" "green" {
  name        = "green-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "green-tg"
  }
}

resource "aws_lb_target_group" "yellow" {
  name        = "yellow-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "yellow-tg"
  }
}

# Create Target Groups
resource "aws_lb_target_group" "jenkins" {
  name        = "jenkins-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/login"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "jenkins-tg"
    Environment = "development"
  }
}

# HTTP Listener for Redirecting to HTTPS
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      host        = "#{host}"
      path        = "/"
      port        = "443"
      protocol    = "HTTPS"
      query       = "#{query}"
      status_code = "HTTP_301"
    }
  }
}

# HTTPS Listener for Application Traffic
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = "arn:aws:acm:us-east-1:734028878759:certificate/61378820-d819-4acc-9583-3f5ac93bdb59"

  #   Default action (should only be applied if no rules match)
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins.arn
  }
}

# Define Routing Rules for HTTP Listener based on hostname
resource "aws_lb_listener_rule" "blue" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 100

  condition {
    host_header {
      values = ["blue.tccdevops.com"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }
}

resource "aws_lb_listener_rule" "green" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 101

  condition {
    host_header {
      values = ["green.tccdevops.com"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.green.arn
  }
}

resource "aws_lb_listener_rule" "yellow" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 102

  condition {
    host_header {
      values = ["yellow.tccdevops.com"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.yellow.arn
  }
}

# Define Routing Rules for the HTTPS Listener
resource "aws_lb_listener_rule" "jenkins" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 103

  condition {
    host_header {
      values = ["jenkins.tccdovops.com"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins.arn
  }
}