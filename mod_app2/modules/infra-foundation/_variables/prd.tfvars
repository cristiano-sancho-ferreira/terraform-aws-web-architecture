region             = "us-east-1"
organization_name  = "cacaushow"
environment        = "prd"
package_buildspec  = "buildspec.yaml"
build_timeout      = "30"
build_compute_type = "BUILD_GENERAL1_SMALL"
build_image        = "aws/codebuild/standard:7.0"
common_tags = {
  "Name"    = "SDLF"
  "Projeto" = "AWS with Terraform"
  "Fase"    = "Network"
}



#############################################################################
# VPN Connection
#############################################################################
customer_gateway_bgp_asn                 = 65000
customer_gateway_ip_address              = "185.99.19.89" # Solicitar ao cliente
customer_gateway_type                    = "ipsec.1"      #(Required) The only type AWS supports at this time is ipsec.1
customer_gateway_device_name             = "CGW"
virtual_private_gateways_amazon_side_asn = 65001 #Solicitar ao cliente

#############################################################################
