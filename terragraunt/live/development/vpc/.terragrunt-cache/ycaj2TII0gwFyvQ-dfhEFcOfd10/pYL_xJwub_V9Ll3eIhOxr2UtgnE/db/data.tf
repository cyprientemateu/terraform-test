data "aws_secretsmanager_secret_version" "database_password" {
  secret_id = "tcc-db-creds"
}

locals {
  tcc-db-creds = jsondecode(
    data.aws_secretsmanager_secret_version.database_password.secret_string
  )
}