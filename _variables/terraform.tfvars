region            = "us-east-1"
application_name  = "App-Website"
organization_name = "ecurso"
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
vpc_cidr      = "10.11.0.0/16"
subnet_1_cidr = "10.11.0.0/22"
subnet_2_cidr = "10.11.4.0/22"
subnet_3_cidr = "10.11.12.0/22"
subnet_4_cidr = "10.11.16.0/22"
subnet_5_cidr = "10.11.24.0/22"
subnet_6_cidr = "10.11.28.0/22"
subnet_7_cidr = "10.11.36.0/22"
subnet_8_cidr = "10.11.40.0/22"