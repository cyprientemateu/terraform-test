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

# Attaching EC2 Instances to respective Target Groups
resource "aws_lb_target_group_attachment" "blue_attachment" {
  target_group_arn = aws_lb_target_group.blue.arn
  target_id        = aws_instance.color_instances[0].id
  port             = 80
}

resource "aws_lb_target_group_attachment" "green_attachment" {
  target_group_arn = aws_lb_target_group.green.arn
  target_id        = aws_instance.color_instances[1].id
  port             = 80
}

resource "aws_lb_target_group_attachment" "yellow_attachment" {
  target_group_arn = aws_lb_target_group.yellow.arn
  target_id        = aws_instance.color_instances[2].id
  port             = 80
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
  certificate_arn = "arn:aws:acm:us-east-1:734028878759:certificate/f6c69630-14a6-4519-aa69-dbf6b99bca5c"

  #   Default action (should only be applied if no rules match)
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }
}

# Define Routing Rules for HTTP Listener based on hostname
resource "aws_lb_listener_rule" "blue" {
  listener_arn = aws_lb_listener.https_listener.arn
  # listener_arn = aws_lb_listener.http.arn
  priority = 100

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
  # listener_arn = aws_lb_listener.http.arn
  priority = 101

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
  # listener_arn = aws_lb_listener.http.arn
  priority = 102

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