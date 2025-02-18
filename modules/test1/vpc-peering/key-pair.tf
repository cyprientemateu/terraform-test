resource "tls_private_key" "example_primary" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_private_key" "example_secondary" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key_primary" {
  key_name   = "terraform-key-primary"
  public_key = tls_private_key.example_primary.public_key_openssh
}

resource "aws_key_pair" "generated_key_secondary" {
  provider   = aws.secondary
  key_name   = "terraform-key-secondary"
  public_key = tls_private_key.example_secondary.public_key_openssh
}

resource "local_file" "private_key_primary" {
  content  = tls_private_key.example_primary.private_key_pem
  filename = "C:/Users/cypri/Downloads/terraform-key-primary.pem"
}

resource "local_file" "private_key_secondary" {
  content  = tls_private_key.example_secondary.private_key_pem
  filename = "C:/Users/cypri/Downloads/terraform-key-secondary.pem"
}
