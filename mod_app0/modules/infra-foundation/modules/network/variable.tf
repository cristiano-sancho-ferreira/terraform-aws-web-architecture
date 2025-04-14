variable "region" {
  type = string
}

variable "common_tags" {
  type = map(string)
}

variable "organization_name" {
  description = "Name of the organization"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

# Network configuration
variable "vpc_cidr" {
  type        = string
  description = "VPC IPv4 CIDR"
}

variable "subnet_1_cidr" {
  type        = string
  description = "IPv4 CIDR for Private subnet 1"
}

variable "subnet_2_cidr" {
  type        = string
  description = "IPv4 CIDR for Private subnet 2"
}

variable "subnet_3_cidr" {
  type        = string
  description = "IPv4 CIDR for Public subnet 3"
}

variable "subnet_4_cidr" {
  type        = string
  description = "IPv4 CIDR for Public subnet 4"
}

variable "subnet_5_cidr" {
  type        = string
  description = "IPv4 CIDR for Private subnet 1"
}

variable "subnet_6_cidr" {
  type        = string
  description = "IPv4 CIDR for Private subnet 2"
}

variable "subnet_7_cidr" {
  type        = string
  description = "IPv4 CIDR for Public subnet 3"
}

variable "subnet_8_cidr" {
  type        = string
  description = "IPv4 CIDR for Public subnet 4"
}