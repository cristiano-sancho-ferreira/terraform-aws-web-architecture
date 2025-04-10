variable "region" {
  description = "AWS region"
}

variable "application_name" {
  description = "Name of the application"
}

variable "organization_name" {
  description = "Name of the organization"
}

variable "environment" {
  description = "Environment name"
}

variable "common_tags" {
  type = map(string)
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
}

variable "subdomain_name" {
  description = "Subdomain name for the application"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "subnet_1_cidr" {
  description = "CIDR block for subnet 1"
  type        = string
}

variable "subnet_2_cidr" {
  description = "CIDR block for subnet 2"
  type        = string
}

variable "subnet_3_cidr" {
  description = "CIDR block for subnet 3"
  type        = string
} 

variable "subnet_4_cidr" {
  description = "CIDR block for subnet 4"
  type        = string
} 

variable "subnet_5_cidr" {
  description = "CIDR block for subnet 5"
  type        = string
}

variable "subnet_6_cidr" {
  description = "CIDR block for subnet 6"
  type        = string
}

variable "subnet_7_cidr" {
  description = "CIDR block for subnet 7"
  type        = string
}

variable "subnet_8_cidr" {
  description = "CIDR block for subnet 8"
  type        = string
}