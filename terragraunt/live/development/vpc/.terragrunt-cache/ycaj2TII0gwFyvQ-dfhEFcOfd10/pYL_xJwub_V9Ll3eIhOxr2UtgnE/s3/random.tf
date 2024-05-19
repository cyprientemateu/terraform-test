resource "random_string" "tcc_random_str_s3" {
  length  = 5
  special = var.random_s3["special"]
  upper   = var.random_s3["upper"]
  numeric = var.random_s3["numeric"]
}