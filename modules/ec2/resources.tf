resource "aws_instance" "vm" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  vpc_security_group_ids      = var.security_group_ids
  iam_instance_profile        = var.iam_instance_profile
  associate_public_ip_address = true

  user_data                   = var.user_data
  user_data_replace_on_change = true

  tags = merge(var.tags, { Name = "${var.name_prefix}-server" })

  root_block_device {
    volume_size           = var.root_volume_size_gb
    volume_type           = "gp3"
    delete_on_termination = true
  }
}
