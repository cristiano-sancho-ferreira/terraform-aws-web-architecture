################@
# Terraform AWS Application Infrastructure
# Author: Sancho
# Date: 2025-04-06
# Description: This Terraform script creates an S3 bucket and a CloudFront distribution to serve static content.
# The S3 bucket is configured to allow public access to the objects stored in it, and the CloudFront distribution is set up to use the S3 bucket as its origin.
# https://www.youtube.com/watch?v=Irip16eCwwg
#################

module "foundation" {
  source            = "./modules/infra-foundation"
  region            = var.region
  application_name  = var.application_name
  organization_name = var.organization_name
  environment       = var.environment
  common_tags       = var.common_tags
  vpc_cidr          = var.vpc_cidr
  subnet_1_cidr     = var.subnet_1_cidr
  subnet_2_cidr     = var.subnet_2_cidr
  subnet_3_cidr     = var.subnet_3_cidr
  subnet_4_cidr     = var.subnet_4_cidr
  subnet_5_cidr     = var.subnet_5_cidr
  subnet_6_cidr     = var.subnet_6_cidr
  subnet_7_cidr     = var.subnet_7_cidr
  subnet_8_cidr     = var.subnet_8_cidr
}
