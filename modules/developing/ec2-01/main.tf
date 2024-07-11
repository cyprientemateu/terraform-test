module "vpc" {
  source = ".."
  // add any necessary input variables for the VPC module
}

resource "aws_instance" "example" {
  ami                    = data.aws_ami.custom_ami.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [var.vpc_security_group_ids[0]]
  subnet_id              = var.subnet_id
  # vpc_id                 = module.tcc_vpc.vpc_id
  root_block_device {
    volume_size = var.volume_size
  }
  tags = merge(var.tags, {
    Name = format("%s-%s-%s-tcc", var.tags["id"], var.tags["environment"], var.tags["project"])
    },
  )
}