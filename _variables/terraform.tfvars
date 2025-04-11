region            = "us-east-1"
application_name  = "App-Website"
organization_name = "sancho"
environment       = "dev"
domain_name       = "cursosancho.com"
subdomain_name    = "app"
common_tags = {
  "Project" = "App-Website"
  "Owner"   = "Sancho"
  "Env"     = "dev"
}

#############################################################################
# Network Configuration
#############################################################################
vpc_cidr      = "10.15.0.0/16"
subnet_1_cidr = "10.15.0.0/22"
subnet_2_cidr = "10.15.4.0/22"
subnet_3_cidr = "10.15.12.0/22"
subnet_4_cidr = "10.15.16.0/22"
subnet_5_cidr = "10.15.24.0/22"
subnet_6_cidr = "10.15.28.0/22"
subnet_7_cidr = "10.15.36.0/22"
subnet_8_cidr = "10.15.40.0/22"