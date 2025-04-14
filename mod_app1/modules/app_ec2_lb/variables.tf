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