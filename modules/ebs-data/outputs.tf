output "volume_id" {
  value = aws_ebs_volume.data.id
}

output "device_name" {
  value = aws_volume_attachment.attach.device_name
}