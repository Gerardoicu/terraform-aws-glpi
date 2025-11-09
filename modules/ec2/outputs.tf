output "public_ip" {
  value = aws_instance.vm.public_ip
}

output "instance_id" {
  value = aws_instance.vm.id
}

output "availability_zone" {
  value = aws_instance.vm.availability_zone
}