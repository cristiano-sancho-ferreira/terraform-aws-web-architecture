variable "region" {
  type = string
}

variable "common_tags" {
  type = map(string)
}

variable "organization_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

# Customer Gateway

variable "customer_gateway_bgp_asn" {
  type = number
}
variable "customer_gateway_ip_address" {
  type = string
}
variable "customer_gateway_type" {
  type = string
}
variable "customer_gateway_device_name" {
  type = string
}
variable "customer_gateway_certificate_arn" {
  type = string
}



variable "virtual_private_gateways_amazon_side_asn" {
  type = number
}
variable "virtual_private_gateways_availability_zone" {
  type = string
}

