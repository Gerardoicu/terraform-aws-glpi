terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" {
  region = var.aws_region
}

# AMI Amazon Linux 2023
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["137112412989"] # Amazon
  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-*-x86_64"]
  }
}

# IAM para SSM
resource "aws_iam_role" "ec2_ssm_role" {
  name = "${var.project_name}-ec2-ssm-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_core" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "${var.project_name}-ec2-ssm-profile"
  role = aws_iam_role.ec2_ssm_role.name
}

# SG: HTTP público y salida
resource "aws_security_group" "web" {
  name        = "${var.project_name}-sg-http"
  description = "Allow HTTP (port 80) and outbound"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 con user_data
resource "aws_instance" "vm" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.web.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssm_profile.name
  associate_public_ip_address = true

  user_data                   = file("${path.module}/${var.user_data_path}")
  user_data_replace_on_change = true

  tags = { Name = "${var.project_name}-server" }

  root_block_device {
    volume_size           = var.root_volume_size_gb
    volume_type           = "gp3"
    delete_on_termination = true
  }
}

# Outputs
output "glpi_url" {
  value       = "http://${aws_instance.vm.public_ip}"
  description = "Public URL glpi-server"
}

output "instance_id" {
  value       = aws_instance.vm.id
  description = "EC2 instance id (for SSM)"
}
# 1️⃣ Inicializa el proyecto Terraform
#terraform init

# 2️⃣ Previsualiza los cambios que aplicará Terraform
#terraform plan

# 3️⃣ Aplica el plan (crea recursos en AWS)
#terraform apply

# 4️⃣ Verifica en la consola AWS
# 5️⃣ (Opcional) Vuelve a mostrar los outputs sin volver a aplicar
#terraform output

# 6️⃣ Destruye todos los recursos creados
#terraform destroy

#  comprobar la persistencia los volumens
# los dos escenarios de arquitectura
# comprobar la versión glpi 11/ ver el chat
# ver costos
# plugins