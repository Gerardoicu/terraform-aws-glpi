variable "path_prefix" {
  type    = string
  default = "/glpi"
}
variable "db_name" {
  type = string
}
variable "db_user" {
  type = string
}
variable "db_password" {
  type      = string
  sensitive = true
}
variable "kms_key_id" {
  type    = string
  default = ""
}
