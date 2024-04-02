data "aws_ami" "custom_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Jenkins-Master"]
  }

  owners = ["734028878759"]
}