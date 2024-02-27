variable "vpc_id" {}

resource "aws_db_subnet_group" "example" {
  name       = "example"
  subnet_ids = module.aws_db_subnet_group.example
  tags = {
    Name = "example"
  }
}

resource "aws_security_group" "tcc_sg" {
  name        = "tcc_sg"
  description = "Example Security Group for Aurora PostgreSQL"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "example"
  }
}

resource "aws_rds_cluster" "tcc_db" {
  cluster_identifier           = "example"
  engine                       = "aurora-postgresql"
  engine_version               = "11.9"
  master_username              = "admin"
  master_password              = random_password.password.result
  db_subnet_group_name         = var.db_subnet_group_name
  vpc_security_group_ids       = [var.vpc_security_group_ids]
  skip_final_snapshot          = true
  backup_retention_period      = 7
  preferred_backup_window      = "02:00-03:00"
  preferred_maintenance_window = "sat:06:00-sat:07:00"
  storage_encrypted            = true
  tags = {
    Name = "example"
  }
}

resource "random_password" "password" {
  length  = 16
  special = true
}
