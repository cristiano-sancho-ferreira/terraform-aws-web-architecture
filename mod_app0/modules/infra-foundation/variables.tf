variable "region" {
  description = "The AWS region to deploy resources"
  type        = string
}

variable "common_tags" {
  description = "Common tags of the project"
  type        = map(string)
}


variable "organization_name" {
  description = "Name of the organization"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}


variable "application_name" {
  description = "Name of the application"
  type        = string
  default     = "sdlf"
}


variable "repo_default_branch" {
  description = "Name of the branch repository"
  type        = string
  default     = "main"
}


# variable "package_buildspec" {
#   description = "The buildspec to be used for the Package stage (default: buildspec.yml)"
#   type        = string
# }


variable "build_privileged_override" {
  description = "Set the build privileged override to 'true' if you are not using a CodeBuild supported Docker base image. This is only relevant to building Docker images"
  default     = "false"
}

# variable "build_timeout" {
#   description = "The time to wait for a CodeBuild to complete before timing out in minutes (default: 5)"
#   type        = string
# }


# variable "build_compute_type" {
#   description = "The build instance type for CodeBuild (default: BUILD_GENERAL1_SMALL)"
#   type        = string
# }


# variable "build_image" {
#   description = "The build image for CodeBuild to use (default: aws/codebuild/nodejs:6.3.1)"
#   type        = string
# }

variable "force_artifact_destroy" {
  description = "Force the removal of the artifact S3 bucket on destroy (default: false)."
  default     = "true"
}

variable "artifact_type" {
  default     = "CODEPIPELINE"
  description = "The build output artifact's type. Valid values for this parameter are: CODEPIPELINE, NO_ARTIFACTS or S3."
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

# variable "customer_gateway_bgp_asn" {
#   description = "The ASN of your customer gateway device. The Border Gateway Protocol (BGP) Autonomous System Number (ASN) in the range of 1 – 2,147,483,647 is supported."
#   type        = number
# }
# variable "customer_gateway_ip_address" {
#   description = "Specify the internet-routable IP address for your gateway's external interface; the address must be static and may be behind a device performing network address translation (NAT)."
#   type        = string
#   default     = null
# }
# variable "customer_gateway_type" {
#   description = "(Required) The type of customer gateway. The only type AWS supports at this time is \"ipsec.1\"."
#   type        = string
# }
# variable "customer_gateway_device_name" {
#   description = "(Optional) Enter a name for the customer gateway device."
#   type        = string
#   default     = null
# }
# variable "customer_gateway_certificate_arn" {
#   description = "(Optional) The ARN of a private certificate provisioned in AWS Certificate Manager (ACM)."
#   type        = string
#   default     = null
# }



# variable "virtual_private_gateways_amazon_side_asn" {
#   description = "(Optional) The Autonomous System Number (ASN) for the Amazon side of the gateway. If you don't specify an ASN, the virtual private gateway is created with the default ASN."
#   type        = number
#   default     = null
# }
# variable "virtual_private_gateways_availability_zone" {
#   description = "(Optional) The Availability Zone for the virtual private gateway."
#   type        = string
#   default     = null
# }
