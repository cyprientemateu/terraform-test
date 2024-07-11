terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  alias  = "state"
  region = var.primary_region
}

provider "aws" {
  alias  = "backup"
  region = var.replica_region
}