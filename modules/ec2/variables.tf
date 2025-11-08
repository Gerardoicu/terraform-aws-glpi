variable "name_prefix" {
  type = string
}
variable "tags" {
  type = map(string)
  default = {}
}
variable "ami_id" {
  type = string
}
variable "instance_type" {
  type = string
}
variable "security_group_ids" {
  type = list(string)
}
variable "iam_instance_profile" {
  type = string
}
variable "user_data" {
  type = string
}
variable "root_volume_size_gb" {
  type = number
}
