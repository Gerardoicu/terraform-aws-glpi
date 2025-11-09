data "aws_ami" "al2023" {
  most_recent = true
  owners = ["137112412989"]
  filter {
    name = "name"
    values = ["al2023-ami-*-kernel-*-x86_64"]
  }
}

module "iam_ssm" {
  source      = "./modules/iam-ssm"
  name_prefix = local.name_prefix
  tags        = local.common_tags
}

module "sg_http" {
  source      = "./modules/sg-http"
  name_prefix = local.name_prefix
  tags        = local.common_tags
}

module "ec2" {
  source               = "./modules/ec2"
  name_prefix          = local.name_prefix
  tags                 = local.common_tags
  ami_id               = data.aws_ami.al2023.id
  instance_type        = var.instance_type
  security_group_ids   = [module.sg_http.id]
  iam_instance_profile = module.iam_ssm.instance_profile_name
  user_data            = file("${path.root}/${var.user_data_path}")
  root_volume_size_gb  = var.root_volume_size_gb
}

module "ebs_data" {
  source             = "./modules/ebs-data"
  name_prefix        = local.name_prefix
  size_gb            = 10
  instance_id        = module.ec2.instance_id
  availability_zone  = module.ec2.availability_zone
  device_name        = var.device_name

  use_existing_ebs   = var.use_existing_ebs
  existing_volume_id = var.existing_volume_id
}


#  comprobar la persistencia los volumens
# los dos escenarios de arquitectura
# comprobar la versión glpi 11/ ver el chat
# ver costos
# plugins