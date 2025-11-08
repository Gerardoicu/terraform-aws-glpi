output "instance_id" {
  value = module.ec2.instance_id
}
output "public_ip" {
  value = module.ec2.public_ip
}
output "glpi_url" {
  value = "http://${module.ec2.public_ip}"
}
