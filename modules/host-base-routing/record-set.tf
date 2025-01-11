resource "aws_route53_record" "blue_cname" {
  zone_id = "Z05958021N024GP778US8"
  name    = "blue.tccdevops.com"
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.main.dns_name]
}

resource "aws_route53_record" "green_cname" {
  zone_id = "Z05958021N024GP778US8"
  name    = "green.tccdevops.com"
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.main.dns_name]
}

resource "aws_route53_record" "yellow_cname" {
  zone_id = "Z05958021N024GP778US8"
  name    = "yellow.tccdevops.com"
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.main.dns_name]
}