locals {
  p_name     = "${var.path_prefix}/db_name"
  p_user     = "${var.path_prefix}/db_user"
  p_password = "${var.path_prefix}/db_password"
}

resource "aws_ssm_parameter" "db_name" {
  name  = local.p_name
  type  = "String"
  value = var.db_name
}

resource "aws_ssm_parameter" "db_user" {
  name  = local.p_user
  type  = "String"
  value = var.db_user
}

resource "aws_ssm_parameter" "db_password" {
  name   = local.p_password
  type   = "SecureString"
  value  = var.db_password
  key_id = var.kms_key_id != "" ? var.kms_key_id : null
}
