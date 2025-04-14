
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}


# Buscar uma imagem AMI ubuntu mais recente para o tipo de instância especificado.
data "aws_ami" "latest" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's AWS account ID for public Ubuntu AMIs
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}


data "aws_vpc" "default" {
  filter {
    name   = "tag:Name"
    values = ["${var.organization_name}-${var.environment}-vpc"]
  }
}

data "aws_subnets" "default" {
  filter {
    name   = "tag:Name"
    values = ["${var.organization_name}-${var.environment}-pub-dmz-*"]
  }
}




