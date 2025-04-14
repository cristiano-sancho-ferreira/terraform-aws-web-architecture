provider "aws" {
  region = var.region
  # assume_role {
  #   role_arn = "arn:aws:iam::${var.account_client}:role/${var.application_name}-cross-account-role"
  # }
}

