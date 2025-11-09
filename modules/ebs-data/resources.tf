resource "aws_ebs_volume" "data" {
  availability_zone = var.availability_zone
  size = var.size_gb      # <= ~30 GB Free Tier)
  type              = "gp3"
  encrypted         = true
  tags = {
    Name = "${var.name_prefix}-data"
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_volume_attachment" "attach" {
  device_name = var.device_name
  volume_id   = aws_ebs_volume.data.id
  instance_id = var.instance_id
}