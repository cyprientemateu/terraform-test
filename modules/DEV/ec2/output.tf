output "instance-ami" {
  value = aws_instance.example.ami
}

output "instance-subnet-id" {
  value = aws_instance.example.subnet_id
}

output "instance-arn" {
  value = aws_instance.example.arn
}

output "instance-az" {
  value = aws_instance.example.availability_zone
}

output "instance-host-id" {
  value = aws_instance.example.host_id
}

output "instance-public-ip" {
  value = aws_instance.example.public_ip
}