# Centraliza parámetros globales del proyecto (instancia, tamaño, user_data, etc).
variable "aws_region" {
  type    = string
  default = "us-east-1"
}
variable "project_name" {
  type    = string
  default = "glpi"
}
variable "instance_type" {
  type    = string
  default = "t3.micro"
}
# Free Tier en us-east-1
variable "root_volume_size_gb" {
  type    = number
  default = 20
}
variable "user_data_path" {
  type    = string
  default = "user_data/glpi.sh"
}
