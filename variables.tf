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
variable "use_existing_ebs" {
  type    = bool
  default = false
}

variable "existing_volume_id" {
  type    = string
  default = ""
}

variable "device_name" {
  type    = string
  default = "/dev/xvdb"
}
variable "glpi_db_name" {
  type = string
}

variable "glpi_db_user" {
  type = string
}

variable "glpi_db_password" {
  type      = string
  sensitive = true
}