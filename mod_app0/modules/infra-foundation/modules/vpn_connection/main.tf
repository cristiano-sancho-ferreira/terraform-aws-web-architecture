#############################################################################
# VPN Gateway
# fonte: https://awstip.com/aws-site-to-site-vpn-using-terraform-324b61b14cb0
#############################################################################

resource "aws_customer_gateway" "customer_gateway" {
  bgp_asn         = var.customer_gateway_bgp_asn
  ip_address      = var.customer_gateway_ip_address
  type            = var.customer_gateway_type
  device_name     = "${var.organization_name}_${var.customer_gateway_device_name}"
  certificate_arn = var.customer_gateway_certificate_arn

  tags = merge(var.common_tags, {
    Name = "cgw-${var.organization_name}-${var.environment}-a"
    Env  = var.environment
  })
}


resource "aws_vpn_gateway" "virtual_private_gateways" {
  vpc_id            = var.vpc_id
  amazon_side_asn   = var.virtual_private_gateways_amazon_side_asn
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = merge(var.common_tags, {
    Name = "vgw-${var.organization_name}-${var.environment}"
    Env  = var.environment
  })
}


# resource "aws_vpn_connection" "vpn_connection" {
#   vpn_gateway_id      = aws_vpn_gateway.virtual_private_gateways.id
#   customer_gateway_id = aws_customer_gateway.customer_gateway.id
#   type                = "ipsec.1"
#   static_routes_only  = true

#   tags = merge(var.common_tags, {
#     Name = "vpn-${var.organization_name}-${var.environment}-to-aws"
#     Env  = var.environment
#   })
# }

