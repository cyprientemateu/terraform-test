aws_region    = "us-east-1"
root_volume   = 8
volume_type   = "gp3"
resource_type = "prometheus-grafana-server"
instance_type = "t3.medium"
key_name      = "terraform"

tags = {
  "id"             = "1119"
  "owner"          = "tcc"
  "teams"          = "Devops"
  "environment"    = "dev"
  "project"        = "a1"
  "create_by"      = "Terraform"
  "cloud_provider" = "aws"
}