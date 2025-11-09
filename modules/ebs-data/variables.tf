variable "name_prefix" {
  type = string
}

variable "size_gb" {
  type = number
}

variable "instance_id" {
  type = string
}

variable "availability_zone" {
  type = string
}

variable "device_name" {
  type    = string
  default = "/dev/xvdb"
}

# DUAL: crear o reusar volumen
variable "use_existing_ebs" {
  type    = bool
  default = false
}

variable "existing_volume_id" {
  type    = string
  default = ""
  validation {
    condition     = var.use_existing_ebs == false || length(var.existing_volume_id) > 0
    error_message = "Con use_existing_ebs=true debes pasar existing_volume_id (vol-...)."
  }
}
