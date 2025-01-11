resource "aws_route53_record" "appone" {
  zone_id = "Z02628573J1LNVJ1YWLC4"
  name    = "cyprien.tcclearning.cf"
  type    = "A"

  alias {
    name                   = "a29ea98fc4cec42ed8fc16588a6a2807-416594819.us-east-1.elb.amazonaws.com"
    zone_id                = "Z35SXDOTRQ7X7K" # Replace with correct Zone ID for your region
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "appthree" {
  zone_id = "Z02628573J1LNVJ1YWLC4"
  name    = "carlos.tcclearning.cf"
  type    = "A"

  alias {
    name                   = "a754f563c02784ec6b97290156b73b1e-1904144852.us-east-1.elb.amazonaws.com"
    zone_id                = "Z35SXDOTRQ7X7K" # Replace with correct Zone ID for your region
    evaluate_target_health = false
  }
}