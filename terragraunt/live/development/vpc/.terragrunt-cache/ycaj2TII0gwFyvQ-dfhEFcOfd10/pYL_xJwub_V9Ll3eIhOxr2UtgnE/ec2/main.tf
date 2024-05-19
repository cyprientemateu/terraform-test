resource "aws_instance" "tcc_ec2" {
  ami           = data.aws_ami.custom_ami.id
  instance_type = var.instance_type
  key_name      = var.key_name
  # vpc_security_group_ids  = [aws_security_group.tcc_sg.id]
  vpc_security_group_ids  = [data.aws_security_group.tcc_sg.id]
  subnet_id               = data.aws_subnet.public-01.id
  disable_api_termination = var.enable_termination_protection

  root_block_device {
    volume_size = var.volume_size
  }
  #   user_data = file("./user-data.sh")
  tags = merge(var.tags, {
    Name = format("%s-%s-%s-${var.instance_name}", var.tags["id"], var.tags["environment"], var.tags["project"])
    },
  )
}

# resource "aws_instance" "tcc_ec2" {
#   ami                    = data.aws_ami.custom_ami.id
#   instance_type          = var.instance_type
#   key_name               = var.key_name
#   vpc_security_group_ids = [aws_security_group.tcc_sg.id]
#   subnet_id              = var.subnet_id
#   root_block_device {
#     volume_size = var.volume_size
#   }

#   user_data = <<-EOF
#               #!/bin/bash
#               sudo yum install -y unzip wget httpd
#               sudo wget https://github.com/utrains/static-resume/archive/refs/heads/main.zip -O /tmp/main.zip
#               sudo unzip /tmp/main.zip -d /var/www/html
#               sudo cp -r /var/www/html/static-resume-main/iPortfolio/* /var/www/html/
#               sudo systemctl start httpd
#               sudo systemctl enable httpd
#               EOF

#   tags = merge(var.tags, {
#     Name = format("%s-%s-%s-tcc-bastion-host", var.tags["id"], var.tags["environment"], var.tags["project"])
#   })
# }
