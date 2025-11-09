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