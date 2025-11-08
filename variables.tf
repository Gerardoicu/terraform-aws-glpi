variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefijo para nombrar recursos"
  type        = string
  default     = "glpi"
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t2.micro"
}

variable "root_volume_size_gb" {
  description = "Tamaño del volumen raíz (GB)"
  type        = number
  default     = 20
}

variable "user_data_path" {
  description = "Ruta al script user_data"
  type        = string
  default     = "${path.module}/user_data/helloworld.sh"
}
