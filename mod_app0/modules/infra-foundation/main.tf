#############################################################################
# VPN-CacauShow
#############################################################################

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Network
module "network" {
  source            = "./modules/network"
  region            = var.region
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

# module "vpn_connection" {
#   source                                     = "./modules/vpn_connection"
#   region                                     = var.region
#   organization_name                          = var.organization_name
#   environment                                = var.environment
#   common_tags                                = var.common_tags
#   vpc_id                                     = module.network.vpc_id
#   customer_gateway_bgp_asn                   = var.customer_gateway_bgp_asn
#   customer_gateway_ip_address                = var.customer_gateway_ip_address
#   customer_gateway_type                      = var.customer_gateway_type
#   customer_gateway_device_name               = var.customer_gateway_device_name
#   customer_gateway_certificate_arn           = var.customer_gateway_certificate_arn
#   virtual_private_gateways_amazon_side_asn   = var.virtual_private_gateways_amazon_side_asn
#   virtual_private_gateways_availability_zone = var.virtual_private_gateways_availability_zone

#   depends_on = [module.network]
# }

module "s3" {
  source            = "./modules/s3"
  region            = var.region
  organization_name = var.organization_name
  environment       = var.environment
  common_tags       = var.common_tags
}