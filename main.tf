################@
# Terraform AWS Application Infrastructure
# Author: Sancho
# Date: 2025-04-06
# Description: This Terraform script creates an S3 bucket and a CloudFront distribution to serve static content.
# The S3 bucket is configured to allow public access to the objects stored in it, and the CloudFront distribution is set up to use the S3 bucket as its origin.
# https://www.youtube.com/watch?v=Irip16eCwwg
#################

locals {
  module_name = "app_ec2_lb_cloudfront" # Change this to the desired module name
}

module "app_instance" {
  count             = local.module_name == "app_instance" ? 1 : 0
  source            = "./modules/app_ec2"
  region            = var.region
  application_name  = var.application_name
  organization_name = var.organization_name
  environment       = var.environment
  common_tags       = var.common_tags
  domain_name       = var.domain_name
  subdomain_name    = var.subdomain_name
}

module "app_lb" {
  count             = local.module_name == "app_lb" ? 1 : 0
  source            = "./modules/app_ec2_lb"
  region            = var.region
  application_name  = var.application_name
  organization_name = var.organization_name
  environment       = var.environment
  common_tags       = var.common_tags
  domain_name       = var.domain_name
  subdomain_name    = var.subdomain_name
}


module "app_s3_cloudfront" {
  count             = local.module_name == "app_s3_cloudfront" ? 1 : 0
  source            = "./modules/app_s3_cloudfront"
  region            = var.region
  application_name  = var.application_name
  organization_name = var.organization_name
  environment       = var.environment
  common_tags       = var.common_tags
  domain_name       = var.domain_name
  subdomain_name    = var.subdomain_name
}

module "app_ec2_cloudfront" {
  count             = local.module_name == "app_ec2_cloudfront" ? 1 : 0
  source            = "./modules/app_ec2_cloudfront"
  region            = var.region
  application_name  = var.application_name
  organization_name = var.organization_name
  environment       = var.environment
  common_tags       = var.common_tags
  domain_name       = var.domain_name
  subdomain_name    = var.subdomain_name
}

module "app_ec2_lb_cloudfront" {
  count             = local.module_name == "app_ec2_lb_cloudfront" ? 1 : 0
  source            = "./modules/app_ec2_lb_cloudfront"
  region            = var.region
  application_name  = var.application_name
  organization_name = var.organization_name
  environment       = var.environment
  common_tags       = var.common_tags
  domain_name       = var.domain_name
  subdomain_name    = var.subdomain_name
}




