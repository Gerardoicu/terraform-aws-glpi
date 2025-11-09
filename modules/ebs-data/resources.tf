resource "aws_ebs_volume" "data" {
  count = var.use_existing_ebs ? 0 : 1

  availability_zone = var.availability_zone
  size              = var.size_gb
  type              = "gp3"
  encrypted         = true

  tags = {
    Name = "${var.name_prefix}-data"
  }
  lifecycle {
    prevent_destroy = false
  }
}

locals {
  data_volume_id = var.use_existing_ebs ? var.existing_volume_id : aws_ebs_volume.data[0].id
}

resource "aws_volume_attachment" "attach" {
  device_name = var.device_name
  volume_id   = local.data_volume_id
  instance_id = var.instance_id
}
