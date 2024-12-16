# output "instance-ami" {
#   value = aws_instance.tcc_ec2.ami
# }

# output "ami_id" {
#   value = data.aws_ami.custom_ami.id
# }

output "instance-subnet-id" {
  value = aws_instance.tcc_ec2.subnet_id
}

output "instance-arn" {
  value = aws_instance.tcc_ec2.arn
}

output "instance-az" {
  value = aws_instance.tcc_ec2.availability_zone
}

output "instance-host-id" {
  value = aws_instance.tcc_ec2.host_id
}

output "instance-public-ip" {
  value = aws_instance.tcc_ec2.public_ip
}